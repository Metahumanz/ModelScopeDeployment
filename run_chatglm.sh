#!/usr/bin/env bash
set -euo pipefail

QUESTIONS_FILE="${QUESTIONS_FILE:-prompts/semantic_understanding.json}"
MAX_NEW_TOKENS="${MAX_NEW_TOKENS:-256}"
TEMPERATURE="${TEMPERATURE:-0.2}"
TOP_P="${TOP_P:-0.9}"

show_help() {
  cat <<'EOF'
Usage:
  bash run_chatglm.sh

Optional environment variables:
  QUESTIONS_FILE=path       Question JSON file. Default: prompts/semantic_understanding.json
  MAX_NEW_TOKENS=number     Max generated tokens per answer. Default: 256
  TEMPERATURE=number        Sampling temperature. Default: 0.2
  TOP_P=number              Top-p sampling value. Default: 0.9
  MODELSCOPE_CACHE_DIR=dir  Optional ModelScope cache directory.

Example:
  bash run_chatglm.sh
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

echo "[chatglm] This script only runs ChatGLM3-6B."
echo "[chatglm] If the model is already cached, it will reuse the existing files."
echo "[chatglm] Question file: $QUESTIONS_FILE"
echo "[chatglm] Results folder: results/chatglm3-6b/"
echo
echo "================================================================"
echo "[chatglm] Running chatglm3-6b"
echo "[chatglm] Model: ZhipuAI/chatglm3-6b"
echo "[chatglm] The model will answer every question, then save Markdown and JSON results."
echo "================================================================"

python scripts/run_eval.py \
  --model ZhipuAI/chatglm3-6b \
  --label chatglm3-6b \
  --questions "$QUESTIONS_FILE" \
  --output-dir results \
  --max-new-tokens "$MAX_NEW_TOKENS" \
  --temperature "$TEMPERATURE" \
  --top-p "$TOP_P" \
  "${cache_args[@]}"

echo
echo "[chatglm] Done. Results are saved under results/chatglm3-6b/."
