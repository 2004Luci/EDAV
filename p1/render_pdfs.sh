#!/usr/bin/env bash
set -euo pipefail

# Run this script from the project folder after installing R, tidyverse,
# knitr, and Quarto.

mkdir -p outputs/submission outputs/printout

quarto render PSet1-housing.qmd --to typst \
  --output-dir outputs/submission --output PSet1-housing.pdf

# Make a temporary copy with only the code-visibility setting changed.
awk '
BEGIN { changed = 0 }
$0 == "  echo: true" && changed == 0 { print "  echo: false"; changed = 1; next }
{ print }
END { if (changed == 0) exit 1 }
' PSet1-housing.qmd > PSet1-housing-printout-temp.qmd

quarto render PSet1-housing-printout-temp.qmd --to typst \
  --output-dir outputs/printout --output PSet1-housing.pdf
rm -f PSet1-housing-printout-temp.qmd

echo "Created outputs/submission/PSet1-housing.pdf and outputs/printout/PSet1-housing.pdf"
