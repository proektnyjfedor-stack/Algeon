const chat = document.getElementById("chat");
const input = document.getElementById("messageInput");
const button = document.getElementById("sendButton");

const API_URL = "http://127.0.0.1:8000/chat";
let isSending = false;

function addMessage(text, sender) {
  const div = document.createElement("div");
  div.className = `message ${sender}`;
  div.textContent = text;
  chat.appendChild(div);
  chat.scrollTop = chat.scrollHeight;
}

async function sendMessage() {
  const text = input.value.trim();
  if (!text) return;

  addMessage(text, "user");
  input.value = "";

  const loadingDiv = document.createElement("div");
  loadingDiv.className = "message bot";
  loadingDiv.textContent = "Думаю...";
  chat.appendChild(loadingDiv);
  chat.scrollTop = chat.scrollHeight;

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: text,
        user_id: "demo-user",
        grade: 5
      })
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();

    loadingDiv.remove();
    addMessage(data.reply || "Нет ответа от сервера", "bot");
  } catch (error) {
    loadingDiv.remove();
    addMessage(
      "Ошибка подключения к backend. Проверь, что сервер FastAPI запущен на 127.0.0.1:8000.",
      "bot"
    );
    console.error(error);
  }
}

button.addEventListener("click", sendMessage);
input.addEventListener("keydown", (e) => {
  if (e.key === "Enter") sendMessage();
});