#!/usr/bin/env bash
set -euo pipefail

QUESTIONS_FILE="${QUESTIONS_FILE:-prompts/semantic_understanding.json}"
MAX_NEW_TOKENS="${MAX_NEW_TOKENS:-256}"
TEMPERATURE="${TEMPERATURE:-0.2}"
TOP_P="${TOP_P:-0.9}"
TORCH_DTYPE="${TORCH_DTYPE:-auto}"

show_help() {
  cat <<'EOF'
Usage:
  bash run_deepseek7b.sh

Optional environment variables:
  QUESTIONS_FILE=path       Question JSON file. Default: prompts/semantic_understanding.json
  MAX_NEW_TOKENS=number     Max generated tokens per answer. Default: 256
  TEMPERATURE=number        Sampling temperature. Default: 0.2
  TOP_P=number              Top-p sampling value. Default: 0.9
  TORCH_DTYPE=value         auto, float32, bfloat16, or float16. Default: auto
  MODELSCOPE_CACHE_DIR=dir  Optional ModelScope cache directory.

Example:
  bash run_deepseek7b.sh
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

echo "[deepseek7b] Running old DeepSeek LLM 7B Chat, without R1-style thinking."
echo "[deepseek7b] If the model is already cached, existing files will be reused."
echo "[deepseek7b] Question file: $QUESTIONS_FILE"
echo "[deepseek7b] Results folder: results/deepseek-llm-7b-chat/"

python scripts/run_eval.py \
  --model deepseek-ai/deepseek-llm-7b-chat \
  --label deepseek-llm-7b-chat \
  --questions "$QUESTIONS_FILE" \
  --output-dir results \
  --max-new-tokens "$MAX_NEW_TOKENS" \
  --temperature "$TEMPERATURE" \
  --top-p "$TOP_P" \
  --torch-dtype "$TORCH_DTYPE" \
  "${cache_args[@]}"

echo
echo "[deepseek7b] Done. Results are saved under results/deepseek-llm-7b-chat/."
