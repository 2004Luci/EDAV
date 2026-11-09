#!/usr/bin/env bash
# Renders the code-visible submission PDF and the code-hidden printout PDF.
# Run from this folder. Uses quarto on PATH, else the copy bundled with
# RStudio; set QUARTO=/path/to/quarto to override.
set -euo pipefail
RSTUDIO_QUARTO="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto"
if [ -z "${QUARTO:-}" ]; then
  if command -v quarto >/dev/null 2>&1; then
    QUARTO="quarto"
  elif [ -x "$RSTUDIO_QUARTO" ]; then
    QUARTO="$RSTUDIO_QUARTO"
  else
    echo "quarto not found: install it or set QUARTO=/path/to/quarto" >&2
    exit 1
  fi
fi

mkdir -p outputs/submission outputs/printout
"$QUARTO" render PSet2-ms7556.qmd --to typst --output-dir outputs/submission

awk '
BEGIN { changed = 0 }
$0 == "  echo: true" && changed == 0 { print "  echo: false"; changed = 1; next }
{ print }
END { if (changed == 0) exit 1 }
' PSet2-ms7556.qmd > PSet2-ms7556-printout.qmd
"$QUARTO" render PSet2-ms7556-printout.qmd --to typst \
  --output-dir outputs/printout
rm -f PSet2-ms7556-printout.qmd

echo "Created outputs/submission/PSet2-ms7556.pdf"
echo "Created outputs/printout/PSet2-ms7556-printout.pdf"
