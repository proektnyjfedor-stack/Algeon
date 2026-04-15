#!/usr/bin/env python3
"""Подставляет 5 вариантов FormulaOGE (PDF + задания 6–19) в exam_bundle.json.
Запуск: python3 tool/merge_formulaoge_pdfs.py
Перед этим: dart run tool/generate_exam_bundle.dart (чтобы были oge_v6–v10)."""
from __future__ import annotations

import json
import re
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
PDF_DIR = ROOT / "assets" / "exams" / "formulaoge"
BUNDLE = ROOT / "assets" / "exams" / "exam_bundle.json"

HEADER_RE = re.compile(r"ОГЭ\s*2026.*?formulaoge", re.I | re.S)


def clean_pdf_text(raw: str) -> str:
    t = HEADER_RE.sub("", raw)
    t = t.replace("\u00a0", " ")
    t = re.sub(r"(\d),(\d)", r"\1.\2", t)
    t = re.sub(r"\s+", " ", t)
    return t.strip()


def extract_full(reader: PdfReader) -> str:
    return " ".join(clean_pdf_text(p.extract_text() or "") for p in reader.pages)


def split_task_block(text: str, n: int) -> str | None:
    m = re.search(rf"\b{n}\.\s", text)
    if not m:
        return None
    rest = text[m.end() :]
    stops: list[int] = []
    mm = re.search(r"\bЧасть\b", rest)
    if mm:
        stops.append(mm.start())
    for k in range(n + 1, 26):
        mm = re.search(rf"\b{k}\.\s", rest)
        if mm:
            stops.append(mm.start())
    cut = min(stops) if stops else len(rest)
    chunk = rest[:cut]
    chunk = re.sub(r"\s*Ответ:\s*$", "", chunk).strip()
    return chunk


# (вариант, номер) -> ("text", ответ) или ("mc", индекс_с_1, [опции])
KEY: dict[tuple[int, int], tuple] = {
    # ——— Вариант 1 ———
    (1, 6): ("text", "19.84"),
    (1, 7): ("mc", 3, ["55/19", "64/19", "72/19", "79/19"]),
    (1, 8): ("text", "3"),
    (1, 9): ("text", "0.5"),
    (1, 10): ("text", "0.5"),
    (1, 11): ("text", "213"),
    (1, 12): ("text", "3"),
    (1, 13): (
        "mc",
        2,
        ["(-2; 10)", "(-∞;-2)∪(10; +∞)", "(10; +∞)", "(-2; +∞)"],
    ),
    (1, 14): ("text", "46"),
    (1, 15): ("text", "18"),
    (1, 16): ("text", "60"),
    (1, 17): ("text", "40.5"),
    (1, 18): ("text", "5"),
    (1, 19): ("text", "1"),
    # ——— Вариант 2 ———
    (2, 6): ("text", "0.8"),
    (2, 7): ("mc", 2, ["Точка A", "Точка B", "Точка C", "Точка D"]),
    (2, 8): ("text", "64"),
    (2, 9): ("text", "3.5"),
    (2, 10): ("text", "0.95"),
    (2, 11): ("text", "231"),
    (2, 12): ("text", "98"),
    (2, 13): ("mc", 1, ["[2; 2.6]", "(-∞; 2.6]", "(-∞; 2]∪[2.6; +∞)", "[2; +∞)"]),
    (2, 14): ("text", "-60"),
    (2, 15): ("text", "30"),
    (2, 16): ("text", "4096"),
    (2, 17): ("text", "17"),
    (2, 18): ("text", "6"),
    (2, 19): ("text", "3"),
    # ——— Вариант 3 ———
    (3, 6): ("text", "6"),
    (3, 7): ("mc", 2, ["3/11", "7/11", "8/11", "13/11"]),
    (3, 8): ("text", "1048576/49"),
    (3, 9): ("text", "3"),
    (3, 10): ("text", "0.98"),
    (3, 12): ("text", "85"),
    (3, 13): ("mc", 4, ["(0; 1)", "(0; +∞)", "(1; +∞)", "(-∞; 0)∪(1; +∞)"]),
    (3, 14): ("text", "10"),
    (3, 15): ("text", "0.2"),
    (3, 16): ("text", "122"),
    (3, 17): ("text", "12"),
    (3, 18): ("text", "8"),
    (3, 19): ("text", "2"),
    # ——— Вариант 4 ———
    (4, 6): ("text", "2.1"),
    (4, 7): ("mc", 2, ["Точка A", "Точка B", "Точка C", "Точка D"]),
    (4, 8): ("text", "0.8"),
    (4, 9): ("text", "0"),
    (4, 10): ("text", "83/206"),
    (4, 11): ("text", "123"),
    (4, 12): ("text", "50"),
    (4, 13): ("mc", 1, ["x²-6x<0", "x²-6x>0", "x²-36<0", "x²-36>0"]),
    (4, 14): ("text", "5"),
    (4, 15): ("text", "31"),
    (4, 16): ("text", "18"),
    (4, 17): ("text", "10"),
    (4, 18): ("text", "6"),
    (4, 19): ("text", "13"),
    # ——— Вариант 5 ———
    (5, 6): ("text", "15.3"),
    (5, 7): ("mc", 2, ["5/9", "11/9", "13/9", "14/9"]),
    (5, 8): ("text", "2√21"),
    (5, 9): ("text", "10"),
    (5, 10): ("text", "0.96"),
    (5, 11): ("text", "132"),
    (5, 12): ("text", "20"),
    (5, 13): ("mc", 4, ["(-9; 1)", "нет решений", "(-9; +∞)", "(-∞; 1)"]),
    (5, 14): ("text", "486"),
    (5, 15): ("text", "16"),
    (5, 16): ("text", "108"),
    (5, 17): ("text", "10"),
    (5, 18): ("text", "15"),
    (5, 19): ("text", "1"),
}


def norm(s: str) -> str:
    return (
        s.replace("−", "-")
        .replace("–", "-")
        .replace("∞", "∞")
        .strip()
    )


def build_variant(v: int) -> dict:
    pdf_name = f"o6-formulaoge-v{v}.pdf"
    path = PDF_DIR / pdf_name
    reader = PdfReader(str(path))
    text = extract_full(reader)
    tasks: list[dict] = []
    for num in range(6, 20):
        body = split_task_block(text, num)
        key = (v, num)
        if not body or key not in KEY:
            continue
        spec = KEY[key]
        q = f"Задание {num}. {body}"
        tid = f"oge_v{v}_{num:02d}"
        if spec[0] == "text":
            tasks.append(
                {
                    "id": tid,
                    "grade": 9,
                    "topic": "ОГЭ",
                    "question": q,
                    "type": "textInput",
                    "options": None,
                    "answer": spec[1],
                    "hint": None,
                    "imageAsset": None,
                    "explanationSteps": [],
                }
            )
        else:
            _, idx1, opts = spec
            opts = [norm(o) for o in opts]
            tasks.append(
                {
                    "id": tid,
                    "grade": 9,
                    "topic": "ОГЭ",
                    "question": q,
                    "type": "multipleChoice",
                    "options": opts,
                    "answer": opts[idx1 - 1],
                    "hint": None,
                    "imageAsset": None,
                    "explanationSteps": [],
                }
            )
    return {
        "id": f"oge_v{v}",
        "title": f"ОГЭ Вариант {v} (FormulaOGE)",
        "subtitle": "PDF — задания 1–5 с чертежами и часть 2. Здесь: задания 6–19.",
        "timeMinutes": 235,
        "pdfAsset": f"assets/exams/formulaoge/{pdf_name}",
        "tasks": tasks,
    }


def main() -> None:
    new5 = [build_variant(v) for v in range(1, 6)]
    data = json.loads(BUNDLE.read_text(encoding="utf-8"))
    old = data["oge"]
    tail = [
        x
        for x in old
        if int(re.match(r"oge_v(\d+)", x["id"]).group(1)) > 5
    ]
    data["oge"] = new5 + tail
    data["meta"]["ogeVariants"] = len(data["oge"])
    data["meta"]["formulaoge"] = (
        "Варианты 1–5: сборник FormulaOGE (ОГЭ 2026), vk.com/formulaoge; PDF в приложении."
    )
    BUNDLE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print("OK:", len(new5), "formulaoge +", len(tail), "others. Total oge:", len(data["oge"]))


if __name__ == "__main__":
    main()
