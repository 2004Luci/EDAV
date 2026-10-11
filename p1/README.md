# PSet 1: The Price of Housing

This project uses the FY2027 Fair Market Rent (`fmr2027.csv`) data supplied with the assignment. The aim is to explore the rents, compare bedroom sizes and geographies, and look for unusual data patterns that an analyst should notice before making claims about housing affordability.

The analysis is written in R using `tidyverse` and `ggplot2`, following the class examples for histograms, boxplots, bar charts, dot plots, scatterplots, and faceting. It uses **exactly 10 final graphs**. The source also contains a short first-pass check of dimensions, types, missing values, duplicates, key completeness, zero-population rows, and consistency of FMR values within each HUD area and bedroom size. The code is intentionally kept direct: read the data, make a few small derived tables, and build each graph with familiar `ggplot()` layers.

## Files

- `PSet1-housing.qmd` — main Quarto source. The YAML setting `echo: true` makes code visible in the submission render.
- `fmr2027.csv` — source dataset; do not edit it manually.
- `PSet1-housing-assignment.pdf` — copy of the assignment handout for reference.
- `render_pdfs.sh` — renders the code-visible and code-hidden versions when R and Quarto are installed.
- `outputs/submission/` — destination for the submission PDF with code visible.
- `outputs/printout/` — destination for the class printout PDF with code hidden.
- `outputs/preview/` — preview PDFs assembled from the same dataset for checking the proposed figure set and layout. They are not native Quarto renders.
- `preview_figures/` — figure images used to preview the proposed 10-graph selection in this environment.

The PDFs marked **preview** in the downloadable deliverables were assembled for visual review because this environment does not have R or Quarto installed. For the authoritative Quarto renders, run `render_pdfs.sh` from the project folder on a computer with the required software.

## Dataset and rows

The handout describes the CSV as FY2027 Fair Market Rents from HUD User, effective October 1, 2026, for U.S. counties, county equivalents, and New England towns by bedroom count.

The file has **23,820 rows and 11 columns**. Every `fips` value has five rows, one for each `bedrooms` value from 0 to 4. There are 4,764 distinct geographic records (`fips`) and 2,606 distinct HUD FMR areas (`hud_area_code`). In other words, the file contains more geographic records than distinct rent schedules. Many geographic records share a HUD area and therefore share its FMR schedule.

| Column | Meaning used in this analysis |
|---|---|
| `fips` | Geographic identifier, kept as text so leading zeroes are preserved. |
| `stusps` | State or territory abbreviation. |
| `state` | State identifier in the supplied data. |
| `countyname` | County or county-equivalent name. |
| `county_town_name` | Town/sub-county name when supplied; often missing for county-level records. |
| `hud_area_code` | Identifier for the HUD FMR area / rent schedule. |
| `hud_area_name` | Name of the HUD FMR area. |
| `metro` | Indicator in the source data: 0 is treated as nonmetro and 1 as metro. |
| `pop2024` | Population value supplied for the geographic record. Its exact source definition is not included in the assignment handout. |
| `bedrooms` | Bedroom category, from 0 through 4. |
| `fmr` | Fair Market Rent value in dollars. |

## Data checks and things to keep in mind

The checks on the supplied file found no fully duplicated rows and no duplicated `(fips, bedrooms)` pairs. All 4,764 geographic records have all five bedroom categories. For each `hud_area_code` and `bedrooms` combination, the FMR value is the same across its records. The analysis therefore creates `area_rents` by keeping one rent per HUD area and bedroom size for charts whose unit is a HUD area.

`county_town_name` is missing for 15,795 rows (66.3%). This is not automatically a problem: among the two-bedroom rows, 3,159 of 3,161 county-code records have a missing town name, while all 1,603 sub-county-code records have a name. There are two exceptions to the county-code pattern, so the missingness should be described rather than “fixed” by deleting rows.

There are 170 rows with `pop2024 == 0`, but the same population value is repeated across five bedroom rows. That corresponds to **34 geographic records** at the two-bedroom row level: 17 in New Hampshire, 11 in Maine, and 6 in Vermont. Those observations are not discarded. The population-versus-rent scatterplot uses a logarithmic x-axis, so it includes only positive populations; the zero-population records are shown separately in Figure 8.

Fair Market Rent should not be interpreted as the rent every household pays or as a complete measure of housing affordability. These data can describe HUD FMR schedules and geographic differences, but they do not by themselves explain why a place is expensive or show what an individual household can afford.

## The 10 final graphs

The figure numbers below match the captions in the Quarto source.

1. **Two-bedroom FMR histogram.** Uses one value per HUD area. It shows the distribution's shape, spread, right tail, and concentrations around repeated rent values.
2. **FMR boxplots by bedroom count.** Compares medians, spread, and high-value outliers for the five bedroom categories on the same dollar scale.
3. **Bedroom-to-two-bedroom rent ratios.** For each HUD area, compares the FMR for 0-, 1-, 3-, and 4-bedroom units with its two-bedroom FMR. Faceting keeps the categories separate while using the same scale.
4. **Two-bedroom FMR by metro status.** Uses one rent per HUD area and compares metro and nonmetro distributions without mixing bedroom sizes.
5. **Two-bedroom FMR across states.** Shows each HUD area as a point, colored by metro status. The points show within-state spread instead of hiding it in a single state average. HUD areas that cross state boundaries can appear for each state they cover.
6. **Population versus two-bedroom FMR.** A scatterplot separated by the FIPS-based record type. A log population axis makes a wide range of positive values visible. Repeated FMR schedules mean the points are geographic records, not independent housing markets.
7. **Missing town names by record type.** A proportional bar chart makes the strong relationship between record type and missing `county_town_name` visible.
8. **Zero-population records by state.** Shows where the zero values occur, counted once per geographic record by taking the two-bedroom rows.
9. **Geographic records versus distinct HUD areas by state.** Paired points make it clear that record counts and counts of distinct rent schedules are not the same, especially where county/town records share a HUD area.
10. **Highest and lowest two-bedroom FMR areas.** Shows the 10 areas at each end of the two-bedroom FMR distribution, with every selected area's full five-bedroom schedule.

## How to render the PDFs

Required software: R, Quarto, and the R packages `tidyverse` and `knitr`. The `scales` package is used through `ggplot2` for axis labels and is installed as a dependency of `tidyverse`. From the project folder, install the R packages once if necessary:

```r
install.packages(c("tidyverse", "knitr"))
```

Then render both versions:

```bash
bash render_pdfs.sh
```

The script renders the source once with `echo: true` to `outputs/submission/PSet1-housing.pdf`. It makes a temporary copy of the same source with only `echo: false` changed and renders that to `outputs/printout/PSet1-housing.pdf`. It removes the temporary source after rendering. The data, transformations, figures, and figure numbering are otherwise the same.

You can render just the submission version manually with:

```bash
quarto render PSet1-housing.qmd --to typst --output-dir outputs/submission --output PSet1-housing.pdf
```

## Reading the graphs critically

The important unit-of-analysis choice is whether a question concerns a geographic record or a distinct HUD FMR area. A county/town record is not necessarily an independent rent schedule. The state point plot and the paired count plot show why simply counting rows or averaging every row can be misleading. Similarly, the population variable describes the geography represented in a row; it is not household income, demand, or an affordability measure.

For the in-class questions, be ready to describe what is visible, identify unusual observations, and separate those observations from possible explanations. The graphs can show association and variation, but the CSV alone usually cannot tell us the causes.
