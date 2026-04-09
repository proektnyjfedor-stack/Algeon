from openai import OpenAI

from config import settings

api_key = settings.deepseek_api_key
if not api_key:
    raise RuntimeError("DEEPSEEK_API_KEY not found in .env")

client = OpenAI(
    api_key=api_key,
    base_url="https://api.deepseek.com",
)

SYSTEM_PROMPT = """
Ты доброжелательный AI-репетитор по математике для школьников.
Объясняй просто, пошагово и понятно.
Не перегружай ответ.
Если задача простая, сначала кратко объясни ход решения, потом дай ответ.
Если пользователь просит только ответ, всё равно дай короткое объяснение.
"""


def generate_reply(message: str) -> str:
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": message},
        ],
        temperature=0.3,
        max_tokens=500,
    )
    return response.choices[0].message.content or "Не удалось получить ответ."


def stream_reply(message: str):
    stream = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": message},
        ],
        temperature=0.3,
        max_tokens=500,
        stream=True,
    )

    for chunk in stream:
        delta = chunk.choices[0].delta
        if delta and delta.content:
            yield delta.content