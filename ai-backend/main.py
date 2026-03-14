import logging
import os
import time
import re
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from config import settings
from fastapi.responses import StreamingResponse
from llm_service import generate_reply, stream_reply
from session_service import get_history, add_message, clear_history


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
    os.makedirs("logs", exist_ok=True)
    logger.info(f"Сервер запускается (env={settings.app_env})")
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
    logger.info(f"chat request: user_id={payload.user_id}, grade={payload.grade}")

    history = get_history(payload.user_id)

    add_message(payload.user_id, "user", payload.message)

    reply = generate_reply(payload.message)

    add_message(payload.user_id, "assistant", reply)

    return {
        "reply": reply,
        "user_id": payload.user_id,
        "grade": payload.grade,
        "mode": "math",
        "history_length": len(get_history(payload.user_id))
    }


@app.post("/chat/stream")
@limiter.limit(f"{settings.rate_limit_per_minute}/minute")
async def chat_stream(request: Request, payload: ChatRequest):
    async def event_generator():
        async for chunk in stream_reply(payload.message):
            yield f"data: {chunk}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
    )
@app.get("/history/{user_id}")
async def history(user_id: str):
    return {
        "user_id": user_id,
        "history": get_history(user_id)
    }
@app.delete("/history/{user_id}")
async def delete_history(user_id: str):
    clear_history(user_id)
    return {
        "status": "cleared",
        "user_id": user_id
    }