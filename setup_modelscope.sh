#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Python version"
python --version

echo "[2/4] Pip version"
python -m pip --version

echo "[3/4] Upgrade packaging tools"
python -m pip install -U pip setuptools wheel

echo "[4/4] Install project dependencies"
python -m pip install -r requirements.txt

echo
echo "Done. Try:"
echo "bash run_tests.sh"
