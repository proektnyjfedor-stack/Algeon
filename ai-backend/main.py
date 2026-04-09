import logging
import os
import time
from contextlib import asynccontextmanager
from typing import Optional

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from config import settings
from session_service import add_message, clear_history, get_history


os.makedirs("logs", exist_ok=True)

logging.basicConfig(
    level=logging.DEBUG if settings.app_debug else logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("logs/server.log", encoding="utf-8"),
    ],
)
logger = logging.getLogger(__name__)

limiter = Limiter(key_func=get_remote_address)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Сервер запускается (env=%s)", settings.app_env)
    yield
    logger.info("Сервер останавливается")


app = FastAPI(
    title="Algeon AI Tutor",
    version="0.1.0",
    lifespan=lifespan,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=settings.max_message_length)
    user_id: str = Field(..., min_length=1, max_length=100)
    grade: Optional[int] = None


@app.get("/")
async def root():
    return {"status": "Algeon backend running"}


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "env": settings.app_env,
        "timestamp": int(time.time()),
    }


@app.post("/chat")
@limiter.limit(f"{settings.rate_limit_per_minute}/minute")
async def chat(request: Request, payload: ChatRequest):
    logger.info("chat request: user_id=%s, grade=%s", payload.user_id, payload.grade)

    add_message(payload.user_id, "user", payload.message)

    from llm_service import generate_reply
    reply = generate_reply(payload.message)

    add_message(payload.user_id, "assistant", reply)

    return {
        "reply": reply,
        "user_id": payload.user_id,
        "grade": payload.grade,
        "mode": "ai",
        "history_length": len(get_history(payload.user_id)),
    }


@app.post("/chat/stream")
@limiter.limit(f"{settings.rate_limit_per_minute}/minute")
async def chat_stream(request: Request, payload: ChatRequest):
    from llm_service import stream_reply

    add_message(payload.user_id, "user", payload.message)

    collected_chunks = []

    async def event_generator():
        for chunk in stream_reply(payload.message):
            collected_chunks.append(chunk)
            yield f"data: {chunk}\n\n"

        full_reply = "".join(collected_chunks).strip()
        if full_reply:
            add_message(payload.user_id, "assistant", full_reply)

        yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
    )


@app.get("/history/{user_id}")
async def history(user_id: str):
    return {
        "user_id": user_id,
        "history": get_history(user_id),
    }


@app.delete("/history/{user_id}")
async def delete_history(user_id: str):
    clear_history(user_id)
    return {
        "status": "cleared",
        "user_id": user_id,
    }