#!/usr/bin/env python3
"""Run a small Chinese semantic-understanding evaluation on ModelScope models."""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pathlib import Path
from typing import Any


SYSTEM_PROMPT = (
    "你是一个中文语义理解能力测试助手。请直接回答问题，"
    "重点解释歧义、指代关系和推理过程，避免无关展开。"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Chinese QA evaluation for one LLM.")
    parser.add_argument("--model", required=True, help="ModelScope model id or local model path.")
    parser.add_argument("--label", default=None, help="Output folder label. Defaults to a safe model name.")
    parser.add_argument("--questions", default="prompts/semantic_understanding.json", help="Question JSON file.")
    parser.add_argument("--output-dir", default="results", help="Directory for generated result folders.")
    parser.add_argument("--cache-dir", default=None, help="Optional ModelScope cache directory.")
    parser.add_argument("--max-new-tokens", type=int, default=64, help="Maximum generated tokens per answer.")
    parser.add_argument("--temperature", type=float, default=0, help="Sampling temperature. 0 uses faster greedy decoding.")
    parser.add_argument("--top-p", type=float, default=0.9, help="Top-p sampling value.")
    parser.add_argument(
        "--torch-dtype",
        default="float32",
        choices=["auto", "float32", "bfloat16", "float16"],
        help="Torch dtype used when loading the model.",
    )
    return parser.parse_args()


def safe_name(value: str) -> str:
    value = value.strip().replace("\\", "/").rstrip("/")
    value = value.split("/")[-1] or "model"
    return re.sub(r"[^A-Za-z0-9_.-]+", "-", value).strip("-") or "model"


def load_questions(path: str) -> list[dict[str, Any]]:
    with open(path, "r", encoding="utf-8") as file:
        data = json.load(file)
    if not isinstance(data, list):
        raise ValueError("Question file must contain a JSON list.")
    return data


def resolve_model(model: str, cache_dir: str | None) -> str:
    local_path = Path(model).expanduser()
    if local_path.exists():
        return str(local_path)

    try:
        from modelscope import snapshot_download

        print(f"[modelscope] Downloading or locating: {model}")
        return snapshot_download(model, cache_dir=cache_dir)
    except Exception as exc:  # noqa: BLE001 - fall back to Transformers loader.
        print(f"[warn] ModelScope snapshot_download failed: {exc}")
        print("[warn] Falling back to Transformers model id/path.")
        return model


def resolve_torch_dtype(torch_module: Any, value: str) -> Any:
    if value == "auto":
        return "auto"
    if value == "float32":
        return torch_module.float32
    if value == "bfloat16":
        return torch_module.bfloat16
    if value == "float16":
        return torch_module.float16
    raise ValueError(f"Unsupported torch dtype: {value}")


def load_model_and_tokenizer(model_path: str, torch_dtype_value: str):
    import torch
    import transformers
    from transformers import AutoModel, AutoModelForCausalLM, AutoTokenizer

    print(f"[load] torch: {torch.__version__}")
    print(f"[load] transformers: {transformers.__version__}")
    print(f"[load] tokenizer: {model_path}")
    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)

    common_kwargs = {
        "trust_remote_code": True,
        "torch_dtype": resolve_torch_dtype(torch, torch_dtype_value),
        "low_cpu_mem_usage": True,
    }

    print(f"[load] model: {model_path}")
    try:
        model = AutoModelForCausalLM.from_pretrained(model_path, **common_kwargs)
    except Exception as exc:  # noqa: BLE001 - some remote-code models use AutoModel.
        print(f"[warn] AutoModelForCausalLM failed: {exc}")
        print("[load] retry with AutoModel")
        model = AutoModel.from_pretrained(model_path, **common_kwargs)

    model.eval()
    if hasattr(model, "config"):
        model.config.use_cache = True
    return tokenizer, model


def build_prompt(tokenizer: Any, question: str) -> str:
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": question},
    ]

    chat_template = getattr(tokenizer, "chat_template", None)
    if chat_template:
        return tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)

    return f"{SYSTEM_PROMPT}\n\n用户：{question}\n助手："


def generate_answer(tokenizer: Any, model: Any, question: str, args: argparse.Namespace) -> str:
    import torch

    # Some remote-code models expose chat(), which handles tokenization itself.
    if hasattr(model, "chat"):
        chat_question = f"{SYSTEM_PROMPT}\n\n问题：{question}"
        try:
            chat_result = model.chat(
                tokenizer,
                chat_question,
                history=[],
                max_length=max(args.max_new_tokens + 512, 1024),
                do_sample=args.temperature > 0,
                temperature=args.temperature,
                top_p=args.top_p,
            )
            response = chat_result[0] if isinstance(chat_result, tuple) else chat_result
            return str(response).strip()
        except TypeError as exc:
            print(f"[warn] model.chat failed with TypeError: {exc}")
            print("[warn] Retrying model.chat with fewer arguments.")
            try:
                chat_result = model.chat(
                    tokenizer,
                    chat_question,
                    history=[],
                    max_length=max(args.max_new_tokens + 512, 1024),
                    temperature=args.temperature,
                    top_p=args.top_p,
                )
                response = chat_result[0] if isinstance(chat_result, tuple) else chat_result
                return str(response).strip()
            except TypeError as retry_exc:
                print(f"[warn] model.chat retry failed: {retry_exc}")
                print("[warn] Falling back to model.generate.")

    prompt = build_prompt(tokenizer, question)
    inputs = tokenizer(prompt, return_tensors="pt")

    generation_kwargs: dict[str, Any] = {
        "max_new_tokens": args.max_new_tokens,
        "do_sample": args.temperature > 0,
        "pad_token_id": tokenizer.eos_token_id,
    }
    if args.temperature > 0:
        generation_kwargs["temperature"] = args.temperature
        generation_kwargs["top_p"] = args.top_p

    print(f"[eval] Generating answer with max_new_tokens={args.max_new_tokens}.")
    started_at = time.perf_counter()
    with torch.inference_mode():
        output_ids = model.generate(**inputs, **generation_kwargs)
    elapsed = time.perf_counter() - started_at
    print(f"[eval] Generation finished in {elapsed:.1f}s.")

    prompt_length = inputs["input_ids"].shape[-1]
    answer_ids = output_ids[0][prompt_length:]
    return tokenizer.decode(answer_ids, skip_special_tokens=True).strip()


def write_outputs(output_dir: str, label: str, model_name: str, results: list[dict[str, Any]]) -> Path:
    out_dir = Path(output_dir) / label
    out_dir.mkdir(parents=True, exist_ok=True)

    payload = {
        "model": model_name,
        "label": label,
        "created_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "results": results,
    }

    with open(out_dir / "results.json", "w", encoding="utf-8") as file:
        json.dump(payload, file, ensure_ascii=False, indent=2)

    lines = [
        f"# {label} 问答测试结果",
        "",
        f"- 模型：`{model_name}`",
        f"- 时间：{payload['created_at']}",
        "",
    ]
    for item in results:
        lines.extend(
            [
                f"## {item['id']}. {item['focus']}",
                "",
                f"**问题：** {item['question']}",
                "",
                "**回答：**",
                "",
                item["answer"],
                "",
            ]
        )

    with open(out_dir / "results.md", "w", encoding="utf-8") as file:
        file.write("\n".join(lines).strip() + "\n")

    return out_dir


def main() -> None:
    args = parse_args()
    label = args.label or safe_name(args.model)

    print("[eval] Loading question set.")
    questions = load_questions(args.questions)
    print(f"[eval] Loaded {len(questions)} questions from {args.questions}.")
    print("[eval] Resolving model path. This may download the model if it is not cached.")
    model_path = resolve_model(args.model, args.cache_dir)
    print(f"[eval] Loading tokenizer and model into CPU memory with torch dtype: {args.torch_dtype}.")
    try:
        tokenizer, model = load_model_and_tokenizer(model_path, args.torch_dtype)
    except ValueError as exc:
        message = str(exc)
        if "torch.load" in message and "torch to at least v2.6" in message:
            print("[error] This model uses legacy .bin weights, but the installed Transformers")
            print("[error] refuses to load .bin files with torch<2.6.")
            print("[error] Run `bash setup_modelscope.sh` to install the pinned compatible")
            print("[error] Transformers version from requirements.txt, then run this model script again.")
            sys.exit(2)
        raise
    print("[eval] Model is ready. Starting question answering.")

    results: list[dict[str, Any]] = []
    for index, item in enumerate(questions, start=1):
        question = item["question"]
        focus = item.get("focus", "语义理解")
        print("\n" + "=" * 80)
        print(f"[{index}/{len(questions)}] {focus}")
        print(question)
        print("-" * 80)
        answer = generate_answer(tokenizer, model, question, args)
        print(answer)

        results.append(
            {
                "id": item.get("id", index),
                "focus": focus,
                "question": question,
                "answer": answer,
            }
        )

    print("[eval] Writing result files.")
    out_dir = write_outputs(args.output_dir, label, args.model, results)
    print("\n" + "=" * 80)
    print(f"[eval] Saved Markdown and JSON results to: {out_dir}")


if __name__ == "__main__":
    main()
