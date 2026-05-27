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
  bash run_llama31_8b.sh

Optional environment variables:
  QUESTIONS_FILE=path       Question JSON file. Default: prompts/semantic_understanding.json
  MAX_NEW_TOKENS=number     Max generated tokens per answer. Default: 256
  TEMPERATURE=number        Sampling temperature. Default: 0.2
  TOP_P=number              Top-p sampling value. Default: 0.9
  TORCH_DTYPE=value         auto, float32, bfloat16, or float16. Default: auto
  MODELSCOPE_CACHE_DIR=dir  Optional ModelScope cache directory.

Example:
  bash run_llama31_8b.sh
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

echo "[llama31_8b] Running Meta Llama 3.1 8B Instruct."
echo "[llama31_8b] If the model is already cached, existing files will be reused."
echo "[llama31_8b] Question file: $QUESTIONS_FILE"
echo "[llama31_8b] Results folder: results/llama3.1-8b-instruct/"

python scripts/run_eval.py \
  --model LLM-Research/Meta-Llama-3.1-8B-Instruct \
  --label llama3.1-8b-instruct \
  --questions "$QUESTIONS_FILE" \
  --output-dir results \
  --max-new-tokens "$MAX_NEW_TOKENS" \
  --temperature "$TEMPERATURE" \
  --top-p "$TOP_P" \
  --torch-dtype "$TORCH_DTYPE" \
  "${cache_args[@]}"

echo
echo "[llama31_8b] Done. Results are saved under results/llama3.1-8b-instruct/."
