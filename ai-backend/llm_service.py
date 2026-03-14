import re
import asyncio


def generate_reply(message: str) -> str:
    message = message.strip()

    try:
        if re.match(r"^[0-9+\-*/(). ]+$", message):
            result = eval(message)
            return f"Решаем пример: {message}\nОтвет: {result}"
        return "Я пока умею решать только простые математические выражения."
    except Exception:
        return "Не получилось решить пример."


async def stream_reply(message: str):
    reply = generate_reply(message)
    words = reply.split()

    for word in words:
        yield word + " "
        await asyncio.sleep(0.08)