#!/usr/bin/env bash
set -euo pipefail

QUESTIONS_FILE="${QUESTIONS_FILE:-prompts/semantic_understanding.json}"
MAX_NEW_TOKENS="${MAX_NEW_TOKENS:-1024}"
TEMPERATURE="${TEMPERATURE:-0}"
TOP_P="${TOP_P:-0.9}"
TORCH_DTYPE="${TORCH_DTYPE:-float32}"
TORCH_NUM_THREADS="${TORCH_NUM_THREADS:-4}"

show_help() {
  cat <<'EOF'
Usage:
  bash run_tests.sh

Optional environment variables:
  QUESTIONS_FILE=path       Question JSON file. Default: prompts/semantic_understanding.json
  MAX_NEW_TOKENS=number     Max generated tokens per answer. Default: 1024
  TEMPERATURE=number        Sampling temperature. Default: 0 for faster greedy decoding.
  TOP_P=number              Top-p sampling value. Default: 0.9
  TORCH_DTYPE=value         auto, float32, bfloat16, or float16. Default: float32
  TORCH_NUM_THREADS=number  CPU threads used by torch. Default: 4
  MODELSCOPE_CACHE_DIR=dir  Optional ModelScope cache directory.

Examples:
  bash run_tests.sh
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
  "qwen/Qwen2-0.5B-Instruct|qwen2-0.5b|$MAX_NEW_TOKENS"
  "qwen/Qwen1.5-0.5B-Chat|qwen1.5-0.5b|$MAX_NEW_TOKENS"
  "qwen/Qwen2.5-1.5B-Instruct|qwen2.5-1.5b|$MAX_NEW_TOKENS"
)

echo "[tests] This script runs all configured model evaluations."
echo "[tests] It only runs small CPU-friendly models."
echo "[tests] Question file: $QUESTIONS_FILE"
echo "[tests] Results folder: results/<label>/"
echo "[tests] Total model tests: ${#tests[@]}"
echo "[tests] Max new tokens per answer: $MAX_NEW_TOKENS"
echo "[tests] Temperature: $TEMPERATURE"
echo "[tests] Torch dtype: $TORCH_DTYPE"
echo "[tests] Torch CPU threads: $TORCH_NUM_THREADS"

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
    --torch-dtype "$TORCH_DTYPE" \
    --torch-num-threads "$TORCH_NUM_THREADS" \
    "${cache_args[@]}"
done

echo
echo "[tests] Done. Results are saved under results/<label>/."
