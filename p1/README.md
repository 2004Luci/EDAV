# PSet 1: The Price of Housing

Exploratory analysis of HUD Fair Market Rents (FMR) for fiscal year 2027
(effective October 1, 2026). The deliverable is a `.qmd` file with exactly
10 figures and its rendered PDF, as described in `PSet1-housing.pdf`.

## Files

| File | What it is |
|---|---|
| `PSet1-housing.qmd` | The Quarto source. This is what gets submitted. |
| `fmr2027.csv` | The data from the assignment (not modified). |
| `outputs/submission/PSet1-housing.pdf` | Rendered with the R code shown. Submit this one. |
| `outputs/printout/PSet1-housing.pdf` | Same document with the code hidden. Print this one. |
| `README.md` | This file. |

## How to render

You need R, Quarto (1.4 or newer), and the `tidyverse` package.
Quarto's built-in Typst is used for the PDF, so no LaTeX is needed.

```r
install.packages("tidyverse")
```

Open a terminal in the project folder (the one with `fmr2027.csv` in it).
The `.qmd` reads the csv with a relative path, so it has to be rendered
from there.

**Submission version (code visible)**

```
quarto render PSet1-housing.qmd
```

The YAML already says `echo: true`.

**Printout version (code hidden)**

Do what the assignment says: in the YAML of `PSet1-housing.qmd` change

```
execute:
  echo: true
```

to `echo: false`, render again, and print. Then change it back to `true`
before you submit. If you would rather not edit the file, this does the
same thing on a temporary copy (Mac/Linux):

```
sed 's/echo: true/echo: false/' PSet1-housing.qmd > PSet1-housing-printout.qmd
quarto render PSet1-housing-printout.qmd
rm PSet1-housing-printout.qmd
```

The only difference between the two PDFs is the code. The figure code is
identical, and the jitter in Figure 5 uses `seed = 1`, so the plots match.

I rendered both versions here with R 4.3.3, ggplot2 3.4.4 and Quarto 1.6.42.
The file name is set once at the top (`data_file`), so a newer year only needs that one line changed. Please render once on your own computer too before submitting, and check
the figures look right in your versions of R and ggplot2.

## The data

Source: U.S. Department of Housing and Urban Development (HUD), downloaded
from HUD User, via the assignment. FMRs are listed by number of bedrooms for
counties, county equivalents and New England towns.

Checked directly from the csv: **23,820 rows and 11 columns**. That is
4,764 geographic records x 5 bedroom sizes (0 to 4). The 4,764 records fall
in 2,606 HUD FMR areas and 56 states/territories.

| Column | Meaning | Notes from the data |
|---|---|---|
| `fips` | ID of the geographic record | 10 digits with leading zeros, so read as text. Unique per record. Ending in `99999` means a whole county (3,161 records); anything else is a town/subdivision (1,603 records, all in CT, MA, ME, NH, RI, VT). |
| `stusps` | State/territory abbreviation | 56 values, includes DC, PR, VI, GU, AS, MP |
| `state` | State FIPS code | Same information as `stusps`, as text |
| `countyname` | County name | |
| `county_town_name` | Town name for sub-county records | 15,795 missing (66%), see below |
| `hud_area_code`, `hud_area_name` | The HUD FMR area the record belongs to | 2,606 distinct. This is the level at which HUD sets the rent. |
| `metro` | 1 = metropolitan, 0 = nonmetropolitan | Matches the area code: every `METRO...` code is 1, every `NCNTY...` code is 0 |
| `pop2024` | Population of the record | 0 to 9.8 million |
| `bedrooms` | Unit size, 0 (studio) to 4 | |
| `fmr` | Fair Market Rent in dollars per month | $450 to $5,748 |

### What FMR is (and is not)

FMR is a rent standard HUD publishes for the housing voucher program. It is
not the average rent, not the median rent, not asking rents, and not a
measure of how affordable housing is for any household. From HUD's
Federal Register FMR notices (earlier fiscal years), FMRs are estimates of
a *gross* rent (rent plus utilities) near the low end of the local market
(the 40th percentile), they have a statewide minimum for low-rent areas,
and the other bedroom sizes are computed from the 2-bedroom estimate using
ratios. I did not find the FY2027 methodology document, so I treat these as
likely explanations, not facts about this file.

## What I checked

All of this is in the "Data checks" section at the end of the `.qmd`.

- **No duplicates.** No duplicated rows and no duplicated `fips` + `bedrooms`.
  Every record has all 5 bedroom sizes.
- **No missing values** except `county_town_name`. It is missing for 3,159 of
  3,161 county-level records and for none of the 1,603 town records, so it
  is just "no town name because this is a whole county". It is not an error.
  Two county-level records do have a name (Petersburg Census Area, AK, and
  Sullivan part, MO).
- **`fmr` is the same for every record in a HUD area** (checked for all
  area/bedroom combinations). So rows are not independent markets.
- **Rents never go down as bedrooms go up.** In 8 records (e.g. several
  Montana counties) two neighboring sizes have the same rent.
- **34 records have `pop2024` = 0.** All are in ME (11), NH (17) and VT (6),
  all town-level records. Names such as "Marshall Island UT" and
  "Penobscot Indian Island Reservation" suggest unorganized territories and
  reservations. I kept them. No HUD area has zero population in total.

## The figures

Unless it says otherwise, figures use one row per **HUD area** (the real unit
HUD sets rents for), and the single-size figures use 2 bedrooms.

1. **Records and HUD areas per state** (Cleveland dot plot, log axis). Shows
   why you cannot count rows as markets. Maine has 529 records but 19 HUD
   areas, MA 351 vs 20, CT 169 vs 8, RI 39 vs 3. Most states have about the
   same number of each. DC, GU, MP and AS have 1 area each.
2. **Histograms of `fmr` by bedrooms** (areas). All sizes are right-skewed
   with a long tail of expensive areas. The 2-bedroom histogram has a very tall bin
   just above $1,000.
3. **Boxplots of `fmr` by bedrooms and metro** (areas). Rents rise with
   bedrooms. Metro areas are higher and more spread out than nonmetro, and
   most of the very high values are metro.
4. **`fmr` divided by the 2-bedroom `fmr`, by bedroom size** (areas). The
   ratios sit in narrow ranges (0.69-0.88 for studios, 0.76-0.92 for
   1-bedrooms, 1.19-1.39 for 3, 1.31-1.68 for 4) and pile up at the ends:
   994 areas sit at the lowest 1-bedroom ratio, 439 at the lowest 3-bedroom,
   411 at the lowest 4-bedroom. This looks like HUD's bedroom adjustment
   rules, not real market data (my guess, not verified).
5. **2-bedroom `fmr` by state** (dots for areas, colored by metro, bar for the
   state median). States are sorted by median. DC, HI, NJ, MA are at the top
   (area medians of about $2,438, $2,326, $2,233, $2,038) and PR is far
   below everyone else ($577). LA, MS, AR, KY, OK are next lowest (about $900).
   California has the widest range.
6. **`fmr` vs population** (scatter, log x, areas; the x-axis is just `pop2024`, but it is the total of all records in each HUD area, so know this for the in-class questions). Among metro areas bigger
   population goes with higher rent (Spearman 0.58). Among nonmetro areas
   there is almost no relationship (0.11). Nonmetro rents are mostly stuck near $1,000
   at any population. A group of metro areas at the bottom is Puerto Rico.
   Small expensive places like Nantucket ($3,583, pop. 14,483) show that
   population is not the whole story.
7. **`pop2024` histogram by record type** (records, log x with +1). County
   records have a median population of 25,483; town records 2,622, and
   they are the only ones with zeros (the bar at 1 is the 34 zero-population
   records).
8. **Density of 2-bedroom `fmr`, records vs HUD areas.** The same data counted
   two ways. HUD areas have a sharp peak near $1,000 and a median of $1,017;
   counting records moves the median to $1,228 (because big metro areas
   contain many counties and New England has many town rows). Both are
   "correct", they answer different questions.
9. **12 cheapest and 12 most expensive HUD areas** (2 bedrooms, all five sizes
   shown). The cheapest 12 are all in Puerto Rico. The top is California
   (Santa Cruz at $4,254, San Francisco $3,697), plus Nantucket, Boston, New York.
   The five bedroom sizes spread out much more at the top than at the bottom.
10. **The 15 HUD areas with the most records.** Boston-Cambridge-Quincy has
    114 records (towns in MA and NH), Aroostook County ME 71, Hartford 55,
    Penobscot County ME (part) 53, Washington County ME 48. All of the top
    15 are in New England. The 2,439 records that sit in a shared area
    (out of 4,764) all carry the same rent as their neighbors.

## Main takeaways

- The row is not the right unit for most questions. 2,606 areas, not 4,764
  records, are the real rent decisions, and New England counts are inflated
  by towns.
- Rent increases with bedrooms, and the increase is close to a formula
  (Figure 4).
- Metro is more expensive and more variable than nonmetro. Nonmetro areas
  cluster around $1,000. 372 areas (14%) have exactly the same 2-bedroom
  FMR of $1,014, 351 of them nonmetro, across 20 states. That looks like a
  statewide minimum or similar rule, but I can't confirm that from this file.
- Puerto Rico is far below the states. The data cannot say why.
- State comparisons change depending on whether you use records, areas or
  population. Example: Maryland's median is $1,875 across its 24 records and
  $1,320 across its 15 areas.

## Concerns and what I can't answer

- **Why** rents differ (jobs, income, supply, regulation): the file has none of
  that, so any explanation would be a guess.
- **Affordability:** there is no income or household data. FMR is not
  what people actually pay.
- **Zero-population towns:** probably unorganized territory, but I can't
  confirm that from the file. It is unclear how HUD got these populations.
- **Spikes** at $1,014 and in the bedroom ratios: probably caused by HUD rules
  (state minimums, bedroom adjustments), not verified for FY2027.
- **Multi-state areas:** 36 HUD areas cover more than one state, so a state's
  count of "areas" in Figures 1, 5 includes shared areas. The population in
  Figure 6 is the area total.
- **Large outliers:** I kept all of them. The highest ones are real
  high-cost places, not obvious typos, but I can't verify individual values.
- `pop2024` is the population of the record, not a count of renters or
  households.
