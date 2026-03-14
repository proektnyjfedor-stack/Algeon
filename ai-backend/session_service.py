from typing import Dict, List

# Простая временная память в оперативке
# Потом можно заменить на Redis без изменения main.py
sessions: Dict[str, List[dict]] = {}


def get_history(user_id: str) -> List[dict]:
    return sessions.get(user_id, [])


def add_message(user_id: str, role: str, content: str) -> None:
    if user_id not in sessions:
        sessions[user_id] = []

    sessions[user_id].append({
        "role": role,
        "content": content
    })

    # Ограничиваем историю, чтобы не росла бесконечно
    sessions[user_id] = sessions[user_id][-20:]


def clear_history(user_id: str) -> None:
    sessions[user_id] = []