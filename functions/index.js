const functions = require("firebase-functions");
const https = require("https");

// API ключ хранится через:  firebase functions:config:set openai.key="sk-proj-..."
// Работает на Spark плане (без Blaze / Secret Manager)

exports.aiProxy = functions
  .region("us-central1")
  .https.onRequest((req, res) => {
    // CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const apiKey = functions.config().openai && functions.config().openai.key;
    if (!apiKey) {
      res.status(500).json({ error: "OpenAI API key not configured. Run: firebase functions:config:set openai.key=YOUR_KEY" });
      return;
    }

    const body = req.body;
    const payload = JSON.stringify({
      model: body.model || "gpt-4o-mini",
      messages: body.messages || [],
      max_tokens: body.max_tokens || 1000,
      temperature: body.temperature !== undefined ? body.temperature : 0.7,
    });

    const options = {
      hostname: "api.openai.com",
      path: "/v1/chat/completions",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
        "Content-Length": Buffer.byteLength(payload),
      },
    };

    const proxyReq = https.request(options, (proxyRes) => {
      let data = "";
      proxyRes.on("data", (chunk) => { data += chunk; });
      proxyRes.on("end", () => {
        try {
          res.status(proxyRes.statusCode).json(JSON.parse(data));
        } catch {
          res.status(500).json({ error: "Invalid response from OpenAI" });
        }
      });
    });

    proxyReq.on("error", (err) => {
      console.error("Proxy error:", err);
      res.status(500).json({ error: err.message });
    });

    proxyReq.write(payload);
    proxyReq.end();
  });
