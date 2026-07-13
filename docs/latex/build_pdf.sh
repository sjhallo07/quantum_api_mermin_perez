#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEX_FILE="$ROOT_DIR/docs/latex/quantum_api_mermin_perez.tex"
OUT_DIR="$ROOT_DIR/docs/latex"

if command -v latexmk >/dev/null 2>&1; then
  cd "$ROOT_DIR"
  latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory="$OUT_DIR" "$TEX_FILE"
  exit 0
fi

if ! command -v pdflatex >/dev/null 2>&1; then
  echo "pdflatex/latexmk not found. Install texlive-latex-base to generate the PDF artifact." >&2
  exit 1
fi

cd "$ROOT_DIR"
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$OUT_DIR" "$TEX_FILE" >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$OUT_DIR" "$TEX_FILE" >/dev/null
