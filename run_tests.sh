#!/usr/bin/env bash
set -euo pipefail

QUESTIONS_FILE="${QUESTIONS_FILE:-prompts/semantic_understanding.json}"
MAX_NEW_TOKENS="${MAX_NEW_TOKENS:-256}"
TEMPERATURE="${TEMPERATURE:-0.2}"
TOP_P="${TOP_P:-0.9}"

show_help() {
  cat <<'EOF'
Usage:
  bash run_tests.sh

Optional environment variables:
  RUN_LARGE_MODELS=1        Also run ChatGLM3-6B.
  CHATGLM_MAX_NEW_TOKENS=n  Max generated tokens for ChatGLM3-6B. Default: MAX_NEW_TOKENS.
  QUESTIONS_FILE=path       Question JSON file. Default: prompts/semantic_understanding.json
  MAX_NEW_TOKENS=number     Max generated tokens per answer. Default: 256
  TEMPERATURE=number        Sampling temperature. Default: 0.2
  TOP_P=number              Top-p sampling value. Default: 0.9
  MODELSCOPE_CACHE_DIR=dir  Optional ModelScope cache directory.

Examples:
  bash run_tests.sh
  RUN_LARGE_MODELS=1 bash run_tests.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

cache_args=()
if [[ -n "${MODELSCOPE_CACHE_DIR:-}" ]]; then
  cache_args=(--cache-dir "$MODELSCOPE_CACHE_DIR")
fi

tests=(
  "qwen/Qwen2.5-0.5B-Instruct|qwen2.5-0.5b|$MAX_NEW_TOKENS"
  "qwen/Qwen2.5-1.5B-Instruct|qwen2.5-1.5b|$MAX_NEW_TOKENS"
)

if [[ "${RUN_LARGE_MODELS:-0}" == "1" ]]; then
  tests+=("ZhipuAI/chatglm3-6b|chatglm3-6b|${CHATGLM_MAX_NEW_TOKENS:-$MAX_NEW_TOKENS}")
fi

echo "[tests] This script runs all configured model evaluations."
echo "[tests] Question file: $QUESTIONS_FILE"
echo "[tests] Results folder: results/<label>/"
echo "[tests] Total model tests: ${#tests[@]}"
echo "[tests] Large models enabled: ${RUN_LARGE_MODELS:-0}"

for item in "${tests[@]}"; do
  IFS="|" read -r model label tokens <<<"$item"
  echo
  echo "================================================================"
  echo "[tests] Running $label"
  echo "[tests] Model: $model"
  echo "[tests] The model will answer every question, then save Markdown and JSON results."
  echo "================================================================"

  python scripts/run_eval.py \
    --model "$model" \
    --label "$label" \
    --questions "$QUESTIONS_FILE" \
    --output-dir results \
    --max-new-tokens "$tokens" \
    --temperature "$TEMPERATURE" \
    --top-p "$TOP_P" \
    "${cache_args[@]}"
done

echo
echo "[tests] Done. Results are saved under results/<label>/."
