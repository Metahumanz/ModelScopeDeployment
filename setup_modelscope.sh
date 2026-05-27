#!/usr/bin/env bash
set -euo pipefail

echo "[setup] This script prepares the ModelScope Notebook environment."
echo "[setup] It checks Python, upgrades packaging tools, and installs dependencies."
echo

echo "[1/4] Check Python version"
python --version

echo
echo "[2/4] Check pip version"
python -m pip --version

echo
echo "[3/4] Upgrade packaging tools"
echo "[setup] Updating pip, setuptools, and wheel helps avoid install errors."
python -m pip install -U pip setuptools wheel

echo
echo "[4/4] Install project dependencies"
echo "[setup] Installing packages listed in requirements.txt."
python -m pip install -r requirements.txt

echo
echo "[setup] Installed runtime versions:"
python - <<'PY'
import importlib.metadata as metadata

for package in ("torch", "transformers", "modelscope"):
    try:
        print(f"{package}: {metadata.version(package)}")
    except metadata.PackageNotFoundError:
        print(f"{package}: not installed")
PY

echo
echo "[setup] Done. Next step:"
echo "bash run_tests.sh"
