const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

// API ключ хранится в Firebase Secret Manager
// Установка: firebase functions:secrets:set OPENAI_API_KEY
const openaiKey = defineSecret("OPENAI_API_KEY");

exports.aiProxy = onRequest(
  {
    cors: true,
    region: "us-central1",
    maxInstances: 10,
    secrets: [openaiKey],
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const apiKey = openaiKey.value();
    if (!apiKey) {
      res.status(500).json({ error: "OpenAI API key not configured" });
      return;
    }

    try {
      const body = req.body;

      const response = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: body.model || "gpt-4o-mini",
          messages: body.messages || [],
          max_tokens: body.max_tokens || 1000,
          temperature: body.temperature ?? 0.7,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        res.status(response.status).json(data);
        return;
      }

      res.status(200).json(data);
    } catch (error) {
      console.error("AI Proxy error:", error);
      res.status(500).json({ error: error.message });
    }
  }
);
