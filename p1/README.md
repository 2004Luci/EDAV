# PSet 1 — The Price of Housing

Exploratory data analysis of HUD Fair Market Rents (fiscal year 2027), done in
R and Quarto for a graduate Data Visualization / EDA course.

This README is written so that someone who has never seen the assignment or
the conversation that produced this project can understand it, reproduce it,
and defend it. It is long on purpose: the in-class part of the assignment
asks you questions that no printout can answer for you, so Section 5 and
Section 9 are as much a study guide as documentation.

**Conventions used throughout**

- *Assignment says* = stated in `PSet1-housing.pdf` (the handout).
- *HUD documents* = stated in HUD's own FY2027 documentation (listed in
  [Section 11](#11-sources)). I read these while building the project.
- *Computed* = calculated from `fmr2027.csv` by the code in
  `PSet1-housing-analysis.qmd`. Every number in this README is either
  computed or quoted from one of the two sources above.
- *Hypothesis* = my reasoning about why something looks the way it does. It
  is labelled as such wherever it appears and is not established by the data.

---

## Contents

1. [Project overview](#1-project-overview)
2. [Assignment requirements](#2-assignment-requirements)
3. [The dataset](#3-the-dataset)
4. [What Fair Market Rent is, and is not](#4-what-fair-market-rent-is-and-is-not)
5. [Analytical methodology](#5-analytical-methodology)
6. [Final visualization guide (Figures 1–9)](#6-final-visualization-guide-figures-19)
7. [Key findings](#7-key-findings)
8. [Data-quality concerns and limitations](#8-data-quality-concerns-and-limitations)
9. [Preparing for the in-class questions](#9-preparing-for-the-in-class-questions)
10. [Reproduction instructions](#10-reproduction-instructions)
11. [Sources](#11-sources)
12. [Project file guide](#12-project-file-guide)
13. [Academic and analytical caveats](#13-academic-and-analytical-caveats)
14. [Judgment calls on the graph rules](#14-judgment-calls-on-the-graph-rules)

---

## 1. Project overview

### The scenario

The assignment puts you in the position of an applicant for a data-analyst
job at a state agency that advises a legislature on housing affordability. As
a first-round screen the agency sends every applicant one dataset and one
instruction: explore it and choose up to 10 graphs that summarize it. Applicants
may bring a printout of those graphs to the screening — nothing else — and are
then given 30 minutes of written questions about the data.

The questions are expected to be unannounced: what do your graphs show, why do
the data look the way they do, and do you have concerns about data accuracy?

### What this project delivers

| Deliverable | Where |
| --- | --- |
| Quarto source (the `.qmd` to submit) | `PSet1-housing-analysis.qmd` |
| Submission PDF — R code **visible** | `outputs/submission/PSet1-housing-analysis.pdf` |
| Class printout PDF — R code **hidden** | `outputs/printout/PSet1-housing-analysis.pdf` |
| This documentation | `README.md` |

The analysis ends in **nine** final graphs. Ten is a maximum, not a target; I
cut candidates that duplicated what other graphs already showed or that
misled (see [Section 5.10](#510-how-the-final-graphs-were-chosen)).

### Why EDA and visualization matter for housing data

Housing data are a good example of data that look simple and are not. A table
with one rent per county per bedroom count invites you to average the rows,
rank the states, and move on. This dataset shows why that is risky:

- Just over **half of the geographic records** (2,439 of 4,764, i.e. 51.2%) belong to a HUD
  area that appears on more than one row, so rows are not independent markets.
- **One state (Maine) contributes 529 records but only 19 distinct HUD areas.**
  A "state average over rows" would be dominated by Maine's repeated schedules.
- **14.3% of HUD areas have exactly the same two-bedroom rent ($1,014)**, which
  looks like a data error until you learn HUD imposes a minimum rent.
- Population means different things on different rows (a whole county on some
  rows, a single town on others), so a population-versus-rent scatterplot of
  raw rows gives a correlation near zero even though the relationship is clearly
  positive within each kind of record.

None of these is visible in a summary table. Graphs found every one of them, and
a good analyst needs to know about them *before* a legislator asks.

---

## 2. Assignment requirements

Summarized from `PSet1-housing.pdf`. I have not added course requirements that
are not in the handout.

**The task.** Explore the data thoroughly using techniques from class; look for
patterns and unusual features. Choose **up to 10 graphs** that together give the
best summary of the dataset and that will best let you answer potential questions
from "the agency."

**What to submit.** By Sunday, October 11, 11:59 pm: a `.qmd` file and its
rendered `.pdf` file, on Gradescope. A printout of the graphs goes to class on
Monday, October 12; during the first 30 minutes of class you answer written
questions.

**Two versions of the output.** The submitted version and the printed version
should be identical **except** that code is shown in the submission and hidden in
the printout. The handout says to change `execute: echo: true` to `echo: false`
in the YAML and render again before printing.

**Rules for the graphs.** The data should "speak for themselves":

- No titles, subtitles, captions, annotations, or text labels on the plots.
- Axis labels may contain only variable names and units, e.g. `fmr ($)`.
- No added theme elements other than changing the basic theme, e.g.
  `+ theme_minimal(12)`.
- Number figures by adding the figure number as a caption:
  `+ labs(caption = "Figure 1")`.

**Grading components named in the handout.**

- *Graphs:* good graph forms for the data, good parameter choices, general best
  practices from class.
- *Code:* reproducible (would it run with an updated dataset with the same
  column names? would it run on someone else's computer?), up to date (no
  deprecated functions), simple and elegant within reason, formatted so it is
  easy to read and not cut off.
- *In-class:* understanding of the main trends; understanding of oddities and
  of what you *don't* understand; recognizing questions the data cannot answer.

**Tips from the handout.** Have a basic understanding of how the data were
collected, by whom, and for what purpose; know what each column measures; and
experiment with graphs both to learn about the data and to improve them.

---

## 3. The dataset

### Source facts

- **File:** `fmr2027.csv`.
- **Source organization:** U.S. Department of Housing and Urban Development
  (HUD), downloaded from HUD User (*assignment says*).
- **Contents:** Fair Market Rents for fiscal year 2027 (effective
  October 1, 2026) for U.S. counties, county equivalents, and New England
  towns, by number of bedrooms (*assignment says*).
- **Size (computed):** 23,820 rows × 11 columns.

### Shape of the data

Each row is one *geographic record* × one *bedroom count*.

- 4,764 distinct geographic records (distinct `fips`), each with exactly five
  rows — bedrooms 0, 1, 2, 3, 4 (4,764 × 5 = 23,820). No record is missing a
  bedroom size.
- Those 4,764 records map to only **2,606 distinct HUD FMR areas**
  (`hud_area_code`).
- 56 distinct `stusps` values: the 50 states, DC, Puerto Rico, and four other
  territories (AS, GU, MP, VI).
- **3,161 records are whole counties or county equivalents** and **1,603 are
  sub-county records**, all in six New England states: ME 529, MA 351, NH 259,
  VT 256, CT 169, RI 39. The sub-county records are towns (and similar units).

### Column dictionary

Types are as read by the code (`readr` with explicit `col_types`). "Unique" and
"missing" are computed.

| Column | Type | Unique | Missing | What it represents |
| --- | --- | ---: | ---: | --- |
| `fips` | character (identifier) | 4,764 | 0 | 10-digit geographic ID. Read as **text** because leading zeros matter (`0100199999`). Computed: first 2 digits always equal `state`; the last 5 are `99999` for whole-county records and another code for sub-county records. This interpretation is consistent with the data but is not stated in the handout. |
| `stusps` | character (geographic) | 56 | 0 | USPS state/territory abbreviation. |
| `state` | character (geographic) | 56 | 0 | Two-digit state FIPS code, e.g. `"01"`. One-to-one with `stusps` (verified). Text, not number, to keep leading zeros. |
| `countyname` | character (geographic) | 1,966 | 0 | County (or equivalent) name. **Not unique** — many states have a "Washington County" — and not a reliable key. Use `fips`. |
| `county_town_name` | character (geographic) | 1,255 | **15,795 (66.31%)** | Town/subdivision name. Missing for whole-county records; see below. |
| `hud_area_code` | character (identifier) | 2,606 | 0 | HUD's FMR-area identifier. Codes begin `METRO` or `NCNTY`. |
| `hud_area_name` | character (geographic) | 2,606 | 0 | Name of the FMR area. One-to-one with `hud_area_code` (both have 2,606 unique values). |
| `metro` | integer (binary category) | 2 | 0 | 1 = record belongs to a HUD metropolitan FMR area; 0 = nonmetropolitan county. Verified: `metro == 1` exactly when `hud_area_code` starts with `METRO` (1,976 records) and `metro == 0` exactly when it starts with `NCNTY` (2,788 records). |
| `pop2024` | numeric (count) | 4,467 | 0 | Population of the geographic record. Range 0 to 9,808,667; total across records 338,534,180. The handout does not define its source or vintage beyond the column name. |
| `bedrooms` | integer (ordinal) | 5 | 0 | Unit size, 0 (efficiency/studio) through 4. |
| `fmr` | numeric ($/month) | 1,965 | 0 | Fair Market Rent in dollars. Range $450 to $5,748. |

### Missing values

The **only** column with missing values is `county_town_name`: 15,795 of 23,820
rows (66.31%). This is *structural*, not random:

- It is missing for 3,159 whole-county records (3,159 × 5 = 15,795) and present
  for all 1,603 sub-county records.
- Two further county-level records (`fips` ending `99999`) *do* carry a town
  name:
  - Petersburg Borough, AK → "Petersburg Census Area".
  - "Sullivan part", MO → "Sullivan city part of Crawford County". This is a
    **county split across two HUD areas**: Crawford County, MO is a nonmetro
    record ($962 for two bedrooms, pop 21,870), while the Sullivan-city portion
    sits in the St. Louis metro area ($1,349, pop 927).

The literal text `NA` appears in the CSV for the missing names, and `readr`
reads it as a real missing value. That is correct here; no state abbreviation or
place name is "NA".

### Other computed integrity checks (all passed)

- 0 fully duplicated rows; 0 duplicated `(fips, bedrooms)` keys.
- Every `fips` has all five bedroom sizes.
- For every `fips`, `countyname`, `pop2024`, `metro`, and `hud_area_code` take a
  single value across its five rows.
- For every `(hud_area_code, bedrooms)` pair, `fmr` takes a single value — a HUD
  area has one rent per bedroom size regardless of how many records it covers.
- 4,764 of 4,764 records have rents that never decrease with bedroom count;
  4,756 are *strictly* increasing. See [Section 8](#8-data-quality-concerns-and-limitations)
  for the eight ties.

---

## 4. What Fair Market Rent is, and is not

### What HUD documents

- FMRs are "estimates of 40th percentile gross rents for standard quality units
  within a metropolitan area or nonmetropolitan county" (24 CFR 888.113, quoted
  on HUD User).
- *Gross rent* includes utilities as well as shelter rent. "Standard quality"
  excludes substandard units (complete plumbing and kitchen facilities, meals not
  included, ten acres or less).
- HUD estimates FMRs for OMB-defined metropolitan areas, some HUD-defined
  subdivisions of metropolitan areas, and each nonmetropolitan county. That is
  why the 4,764 records collapse into 2,606 **FMR areas**.
- FMRs exist to set program limits: the Housing Choice Voucher payment standard,
  some project-based contract rents, HOME and Emergency Solutions Grants rent
  ceilings, Continuum of Care limits, and public-housing flat rents.
- HUD calculates the **two-bedroom** FMR first and derives the other sizes from
  *bedroom ratios* that are constrained to fixed intervals (0-bedroom roughly
  0.70–0.88 of the 2-bedroom value; 1-bedroom 0.76–0.92; 3-bedroom 1.10–1.27 and
  4-bedroom 1.22–1.55 before adjustment, followed by upward adjustments of 8.7%
  and 7.7% for 3- and 4-bedroom units).
- Every area's two-bedroom FMR must be at least a **minimum rent**: the lower of
  (a) the population-weighted median two-bedroom FMR of the state's
  nonmetropolitan counties and (b) the national nonmetropolitan equivalent,
  which is **$1,014** for FY2027.
- FMRs are built from American Community Survey rents, adjusted for recent
  movers, inflated and trended forward to the fiscal year, and subject to a
  limit on year-over-year declines (no less than 90% of the prior year).

### What FMR is *not*

FMR is a **program benchmark estimated by HUD**, not an observation. It is not:

- the average or median rent households actually pay;
- the asking rent of apartments currently listed;
- a transaction price;
- a measure of homeownership costs;
- a measure of affordability (which would require incomes and burdens);
- a household-level quantity.

Because FMRs include imposed floors, ratio intervals, and forward trending,
part of what the CSV shows is the **rule that produced the numbers**, not the
market. The pile-up at $1,014 and the pile-ups in the bedroom ratios
(Figures 2, 3, 4, and 8) are examples.

### Hypotheses I flagged but cannot confirm from the file

- The *reason* any particular area has a high or low FMR (wages, supply,
  amenities, regulation, tourism, …). The graphs establish **that** rents are high
  or low, never **why**.
- Where `pop2024` comes from. HUD's notice mentions using county population
  to weight medians but does not tie that to this column.

---

## 5. Analytical methodology

The code follows the order below. Section and chunk names refer to
`PSet1-housing-analysis.qmd`. The qmd is arranged so the **nine final figures come
first** and the supporting checks come after a page break; that way the
printout's figure pages contain graphs only.

### 5.1 Import and structural checks

*What:* read the CSV with explicit column types; confirm there are no parsing
problems; confirm `metro` is only 0/1 and that the reference bedroom count exists.

*Why:* `fips` and `state` must stay text (leading zeros). Explicit types also
make the script fail loudly if an updated file changes shape, instead of silently
producing different numbers.

### 5.2 Missing-value analysis

Counted `NA` per column, then cross-tabulated the one column that has any
(`county_town_name`) against record type. Result: missingness is entirely
explained by record type (whole-county records have no town), except for the two
named county-level exceptions above. Nothing was dropped or imputed.

### 5.3 Duplicate and key checks

Checked full-row duplicates, duplicated `(fips, bedrooms)` keys, completeness of
the five bedroom sizes per record, and that identifier columns are consistent
within a record. All clean. `countyname` was *not* used as a key because it is
not unique.

### 5.4 Geographic structure and repeated schedules — the most important check

*What:* built an **area-level table** (one row per `hud_area_code` × `bedrooms`)
by collapsing records, after first verifying that `fmr` is constant within an
area. The area table carries `fmr`, the number of records in the area
(`n_records`), and the summed `pop2024` (`pop`).

*Why:* if many records share one rent schedule, treating each row as an
independent observation would count the same rent many times.

*Findings (computed):*

- 2,325 areas have a single record; **281 areas cover 2,439 records (51.2%)**.
- The largest area is Boston-Cambridge-Quincy, MA-NH (HUD Metro FMR Area) with
  **114 records** (towns in MA and NH), population 3,605,178, two-bedroom FMR
  $3,008. Next: Aroostook County, ME (71 towns), Hartford–West Hartford–East
  Hartford, CT MSA (55), Penobscot County, ME (part) (53), Washington County,
  ME (48).
- 36 areas span more than one state; Philadelphia–Camden–Wilmington spans four.
- Distinct *whole schedules* (all five rents identical) number 2,446 for 2,606
  areas, so some different areas also share identical rents.

This result drove the **unit-of-analysis decision** below.

### 5.5 Choosing a unit of analysis for each question

Three different questions are easy to confuse:

| Unit | Question it answers | Used for |
| --- | --- | --- |
| **HUD area** (one row per `hud_area_code`) | "How do rents vary across distinct rent schedules / markets, as HUD defines them?" | Figures 2, 3, 4, 5, 6, 9 and one curve of 8 |
| **Record** (one row per `fips`) | "How do rents look across the geographic units in the file?" | Figure 1 (counts), Figure 7, one curve of 8 |
| **Population-weighted** | "What does the typical *resident of the dataset's geography* face?" | One curve of 8 |

When a graph is *by bedroom count* and shows a distribution, only the relevant
bedroom rows are used (or the area table, which already has one row per area per
bedroom). Figures that fix a bedroom count use two bedrooms
(`REF_BEDROOMS <- 2`) because HUD computes the two-bedroom FMR first, which
makes it the least derived of the five.

An area that crosses a state line is counted once in each state it touches when
the question is about states (Figures 1 and 4).

### 5.6 Distribution of FMR

*What:* summaries by bedroom count at both the record and area level (min,
quartiles, median, mean, max) plus a **Bowley (quartile) skewness** coefficient,
and histograms of area-level FMR.

*Why not "assume a normal distribution":* every Bowley value is positive (0.21
to 0.66 depending on bedroom count and unit), which means the upper half of the
middle 50% is longer than the lower half, and the mean is above the median in
every case. Examples (computed): two-bedroom record-level median $1,228 vs mean
$1,388; area-level median $1,017 vs mean $1,150. The distribution is
right-skewed with a long tail of expensive areas, so medians and quartiles —
not means and standard deviations — are the appropriate summaries.

I did **not** log-transform the distribution plots; the dollar scale keeps the
shape and units interpretable, and the right tail is itself a finding.

### 5.7 Bedroom count and rent

*What:* checked monotonicity (does rent rise with bedrooms in every record?),
looked at distributions by bedroom (Figure 2, Figure 5), and computed
**proportional** increases as ratios to the two-bedroom FMR (Figure 3).

*Why ratios:* absolute dollar steps depend on the rent level; a ratio isolates
the "size premium." The ratios turned out to expose HUD's rule-based structure
(Section 7).

### 5.8 Metropolitan versus nonmetropolitan; population

*What:* decoded `metro` against the `METRO`/`NCNTY` prefix, compared rent
distributions by bedroom count at the area level (Figure 5), and examined
population against rent two ways: area-level scatter (Figure 6) and the
record-level population distribution by record type (Figure 7).

*Why area-level for the comparison:* nonmetro has 2,788 *records* but only 1,957
*areas*, and 30.3% of nonmetro records are New England towns that share a
county-level area. Counting rows would overstate how many independent nonmetro
markets exist.

*Why Spearman, not Pearson, for population:* population is extremely skewed
(Figure 7), and a rank correlation is robust to that. Computed Spearman
correlations of `pop` with two-bedroom `fmr`:

| Unit | Group | n | Spearman ρ |
| --- | --- | ---: | ---: |
| Record | county | 3,161 | 0.458 |
| Record | sub-county | 1,603 | 0.714 |
| Record | **all records pooled** | 4,764 | **−0.038** |
| Area | metro | 649 | 0.576 |
| Area | nonmetro | 1,957 | 0.106 |
| Area | all areas pooled | 2,606 | 0.401 |

Pooling county and town records produces a near-zero correlation even though the
correlation is clearly positive within each kind of record: the two kinds have
very different population scales, and town rows are not comparable to county
rows. This is a concrete example of why the unit of analysis matters.

### 5.9 Outliers and unusual values

- *High:* ranked areas by two-bedroom FMR. The top of the list is dominated by
  California areas, plus Nantucket County, MA, Boston, and New York.
- *Low:* the 12 lowest two-bedroom FMRs are all in Puerto Rico.
- *Zero population:* 34 records, all sub-county, all in Maine (11), New Hampshire
  (17), and Vermont (6).
- *Tiny population:* 59 more sub-county or small-county records have a
  population between 1 and 99. Kalawao County, HI has a population of 67 and is
  flagged metro.

None of these was dropped. Each is either explained by naming or by HUD
documentation (Section 8), or flagged as unresolved.

### 5.10 How the final graphs were chosen

I generated more candidates than I kept. A candidate was kept only if it
answered a question none of the others answered *and* revealed a structural
property of the data. In particular:

- A first draft had a "spaghetti plot" of FMR against bedroom count with one line
  per HUD area. It was dropped: monotonicity was already confirmed numerically,
  and the bedroom story is told by Figures 2, 3, and 5. Its median line was also
  hidden inside the nonmetro cloud, which made it hard to read.
- A first draft of the population scatterplot had a loess curve. It was removed
  because the curve was driven by a handful of extreme points (Puerto Rico metro
  areas and a single 67-person area) and implied a U-shaped relationship that is
  not a real feature of the data.
- A histogram of "records per HUD area" was folded into Figure 1, which shows
  the same distortion state by state.

---

## 6. Final visualization guide (Figures 1–9)

All figures use `theme_minimal(12)`, carry only `Figure N` as a caption, and have
axis labels limited to variable names and units. Where a figure fixes the
bedroom count, a one-panel facet strip such as `bedrooms: 2` shows which subset is
plotted (see [Section 14](#14-judgment-calls-on-the-graph-rules)).

In the code-hidden printout PDF, figures appear on these pages:

| Page | Figures |
| ---: | --- |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 4 |
| 5 | 5 and 6 |
| 6 | 7 and 8 |
| 7 | 9 |

Pages 8 onward of the printout are supporting tables, not graphs.

### Figure 1 — Records versus HUD areas, by state

- **Variables:** `stusps` (y); count (x, log scale); `unit` (color: records or
  HUD areas).
- **Chart type:** Cleveland dot plot with a connecting segment per state,
  ordered by the larger of the two counts, x on a log₁₀ scale (breaks at 1, 3,
  10, 30, 100, 300).
- **Why:** a dot plot handles 56 categories far better than 56 bars, and the
  connecting segment makes the *gap* between the two counts the visual signal.
  Log scale because counts range from 1 to 529.
- **Question:** "Do states contribute equally many independent markets, or does
  row count mislead?"
- **Observed:** Row counts overstate market counts dramatically in New England:
  ME 529 records vs. 19 areas; MA 351 vs. 20; NH 259 vs. 14; VT 256 vs. 12; CT
  169 vs. 8; RI 39 vs. 3. Puerto Rico also has a big gap (78 records, 12 areas).
  Elsewhere the two dots almost coincide (e.g., TX has 254 records and 215
  areas). Four territories/jurisdictions — AS, DC, GU, MP — have a single record
  and a single area.
- **Caveats:** Counts are computed on the two-bedroom rows only (each record has
  exactly one such row). An area spanning states is counted in each. Counts of
  areas are *not* rents.
- **Why it matters here:** it is the figure that justifies using HUD areas, not
  rows, as the unit in most other graphs.

### Figure 2 — Distribution of FMR by bedroom count

- **Variables:** `fmr` (x); count of HUD areas (y); `bedrooms` (stacked panels).
- **Chart type:** histograms in a single column of five panels, **binwidth $100**,
  `boundary = 0`, shared x and y scales.
- **Why:** stacked histograms on a shared dollar axis let you read both the
  *shape* of each distribution and how the whole distribution *shifts* with
  bedrooms. A $100 bin gives roughly 50 bins across the range, enough to show
  structure without noise.
- **Question:** "What does the distribution of rents look like, and does it
  change with unit size?"
- **Observed (area level):** right-skewed at every size, with a long upper tail.
  Maximum FMR by bedroom: $3,230, $3,390, $4,254, $5,531, $5,748 for 0–4
  bedrooms. Area-level medians: $783, $841, $1,017, $1,368, $1,563 (0–4). The
  two-bedroom panel has a **sharp lower edge**: only 12 of 2,606 areas (all in
  Puerto Rico) fall below $885, yet 737 areas fall between $885 and $999 and a
  large spike sits right at $1,014.
- **Caveats:** the sharp lower edge is not a market boundary; it comes from HUD's
  minimum-rent rule (Figure 8). The panels share a count axis, so the zero- and
  one-bedroom panels have taller peaks because their distributions are more
  concentrated.
- **Why it matters here:** it is the basic "what do the rents look like?"
  graph and documents skew, outliers, and the effect of bedrooms in one view.

### Figure 3 — Bedroom ratios (rent relative to two bedrooms)

- **Variables:** `fmr` ÷ two-bedroom `fmr` for the same area (x); count of areas
  (y); `bedrooms` 0, 1, 3, 4 (panels).
- **Chart type:** histograms, **binwidth 0.01**, free x-axis per panel.
- **Why:** a ratio removes the rent *level* and isolates the proportional size
  premium. Free x is used because the four ratios live in non-overlapping ranges
  (e.g., 0.69–0.88 vs. 1.31–1.68); a shared axis would waste most of the space.
- **Question:** "How much more does an extra bedroom cost, in proportional terms,
  and is it consistent across areas?"
- **Observed:** the ratios pile up at the edges of fixed intervals. For
  one-bedroom, 994 of 2,606 areas (about 38%) sit within 0.005 of the minimum
  ratio (0.762); another 228 sit within 0.005 of the maximum (0.919). For
  three-bedroom, 439 areas sit at the minimum (1.191). For four-bedroom, 411 sit
  at the minimum (1.314). There are also large clusters near the upper limits
  that HUD documents: 687 areas are within 0.01 of 1.380 (three bedrooms, = 1.27 ×
  1.087) and 512 are within 0.01 of 1.669 (four bedrooms, = 1.55 × 1.077).
- **Caveats:** **this is not a market finding.** HUD documents that bedroom
  ratios are constrained to intervals, so the clustering is the rule, not
  consumer behavior. The observed extremes differ slightly from the documented
  numbers (e.g., zero-bedroom minimum 0.689 vs. "approximately 0.70";
  three-bedroom maximum 1.391 vs. 1.27 × 1.087 ≈ 1.380); I cannot explain that gap
  from the CSV.
- **Why it matters here:** it is evidence that the dataset is partly an
  *administrative* product — an oddity the in-class questions explicitly reward
  recognizing.

### Figure 4 — Two-bedroom FMR across states, with every area shown

- **Variables:** two-bedroom `fmr` (x); `stusps` (y, ordered by median);
  `metro` (color).
- **Chart type:** strip (jittered dot) plot, one dot per HUD area per state,
  with a black vertical tick at each state's median. Jitter is vertical only and
  deterministic (`seed = 1`).
- **Why:** with 1 to 215 areas per state, a boxplot would hide the sample size
  and be meaningless for states with one area. Showing every area keeps the
  number of observations visible, so a ranking is never read without its
  support. Color by `metro` explains much of the within-state spread.
- **Question:** "How do states compare, and how much do rents vary *within* a
  state?"
- **Observed (area level):** highest medians are DC $2,438 (one area), HI $2,326
  (5 areas), NJ $2,233 (11), MA $2,038 (20), RI $1,879 (3), CT $1,824 (8), NH
  $1,817 (14), CA $1,656 (51). The lowest is Puerto Rico $577 (12 areas, range
  $517–$706), then LA $902, MS $905, AR $909, KY $909, OK $916. California has by
  far the widest spread (interquartile range $944; $1,084 to $4,254). A state
  explains about 57% of the variation in log FMR across area–state pairs (R² =
  0.572) — large, but leaving plenty of within-state variation. Many low-rent
  states have a median equal to their minimum rent (e.g., MS, AR, KY, KS, MO,
  NE, ND, GA), visible as a vertical "wall" of dots.
- **Caveats:** medians for states with 1–3 areas (AS, DC, GU, MP, DE, RI, VI) are
  not stable summaries. The ranking depends on the unit: record-level, area-level,
  and population-weighted medians can differ a lot (for example, Maryland: $1,875
  by record, $1,320 by area, $2,006 population-weighted; Massachusetts: $2,367,
  $2,038, $3,008). Territories and PR are included, not dropped.
- **Why it matters here:** it is the main geographic comparison and the place
  where the unit-of-analysis problem would bite hardest.

### Figure 5 — Metro versus nonmetro, by bedroom count

- **Variables:** `bedrooms` (x, categorical); `fmr` (y); `metro` (fill).
- **Chart type:** side-by-side boxplots at the area level, outliers drawn as
  points.
- **Why:** boxplots summarize location, spread, and outliers compactly for ten
  groups, and the dollar scale makes the premium interpretable. Outliers stay
  visible but do not distort the boxes.
- **Question:** "Do metro and nonmetro rents differ, for every unit size, and by
  how much?"
- **Observed:** metro rents are higher and more dispersed at every size. Median
  area-level FMR (nonmetro → metro): $761 → $958 (0 bedrooms), $813 → $1,027 (1),
  $1,014 → $1,256 (2), $1,318 → $1,634 (3), $1,508 → $1,900 (4). The two-bedroom
  metro median is 1.24 times the nonmetro median. The interquartile range for
  two bedrooms is $961–$1,087 for nonmetro and $1,087–$1,575 for metro. The
  groups overlap: 13.9% of metro areas are below the nonmetro two-bedroom
  median, and 10.9% of nonmetro areas are above the metro median. Nonmetro rents
  are tightly clustered (partly the minimum-rent floor) with a thin upper tail
  of outliers; metro has a long upper tail.
- **Caveats:** `metro` is HUD's FMR-area designation, not a measure of urban
  density — some "HUD Metro FMR Areas" are single rural counties (e.g. Acadia
  Parish, LA; Kalawao County, HI). Area counts are 649 metro and 1,957
  nonmetro; row counts (1,976 and 2,788) would give a different picture.
- **Why it matters here:** `metro` is the single most informative column about
  rent level, and this figure shows both its size and its limits.

### Figure 6 — Population versus two-bedroom FMR (HUD areas)

- **Variables:** area total `pop2024` (x, log scale); two-bedroom `fmr` (y);
  `metro` (color).
- **Chart type:** scatterplot, alpha 0.4, one point per HUD area.
- **Why:** both variables are continuous; a log population axis is necessary
  because population spans more than five orders of magnitude (33 to 9,923,511). Alpha
  reduces overplotting in the crowded low-population cluster. I used the **area**
  total (sum of `pop2024` over the area's records) so a point is a rent schedule
  and its population base, not one town of many.
- **Question:** "Is a bigger place associated with a higher rent?"
- **Observed:** a positive but loose association among metro areas (Spearman
  0.576) and almost none among nonmetro areas (0.106). Metro areas have higher
  rents *and* larger populations, which produces the overall positive pooled
  association (0.401). Eleven low-rent metro points at the bottom are all Puerto
  Rico. A single metro point at the far left (population 67) is Kalawao County,
  HI ($2,326).
- **Caveats:** this is a **descriptive association**, not evidence that
  population causes rent, nor a measure of demand, income, or affordability. Area
  population is a sum over records and assumes the records partition the area.
  Two-bedroom only; the other sizes are proportional rescalings (Figure 3) and
  would look the same.
- **Why it matters here:** it answers the obvious "does size matter?" question
  *and* shows why the answer depends on whether you separate metro from
  nonmetro.

### Figure 7 — Population by record type (data-quality graph)

- **Variables:** `pop2024` (x, pseudo-log scale); count of records (y);
  `record_type` (county vs. sub-county, in panels).
- **Chart type:** histograms, 40 bins on a pseudo-log axis (linear near zero,
  logarithmic beyond), one panel per record type, shared scales.
- **Why:** it exposes two issues in one view: (1) `pop2024` has different
  *meanings* in the two kinds of record, and (2) zero values exist. A plain log
  axis cannot show zeros at all; the pseudo-log keeps them visible as a bar at
  0 instead of silently dropping them.
- **Question:** "Is `pop2024` comparable across rows, and are there any
  suspicious values?"
- **Observed:** county records are centered around 25,483 (median; interquartile
  range 10,790–66,067); sub-county records are centered around 2,622 (interquartile
  range about 900–9,101).
  The 34 zero-population records are all sub-county, in ME, NH, and VT (names
  include "UT", "grant", "purchase", "gore", and one reservation).
  Largest county record: Los Angeles County, 9,808,667. Largest sub-county
  record: Boston city, 666,442.
- **Caveats:** why those 34 are zero is not stated in the file. Their names
  suggest unorganized territories and similar areas, but the CSV cannot confirm
  that a zero is "no residents" rather than "no estimate." They were kept and
  are harmless for medians, rank correlations, and this plot, but would be
  silently lost under a log transform and would carry zero weight in
  population-weighted summaries.
- **Why it matters here:** it directly answers "do you have concerns about the
  accuracy of the data?"

### Figure 8 — The same rents under three definitions of "typical"

- **Variables:** two-bedroom `fmr` (x); cumulative proportion (y); `unit`
  (color: record, HUD area, population).
- **Chart type:** three empirical cumulative distribution functions (step
  functions) on one set of axes, differing only in the weight each observation
  gets: one per record, one per HUD area, or its population.
- **Why:** an ECDF has no binning parameter and lets distributions with different
  weighting be compared directly. This is the most compact way to show that
  "the typical rent" depends on the unit of analysis.
- **Question:** "How much does the answer change if I count records, areas, or
  people?"
- **Observed:** two-bedroom medians are **$1,017 (area), $1,228 (record), $1,656
  (population-weighted)**. The share of the distribution at or above $2,000 is
  3.2% of areas, 11.4% of records, and 29.2% of the population. The area curve
  has a near-vertical jump at **$1,014**: 372 areas (14.3%) have exactly that
  two-bedroom FMR, spread across 20 states (351 nonmetro, 21 metro). Roughly half
  of all areas (49.5%) have a two-bedroom FMR at or below $1,014. The population
  curve steps near $3,000 where several very large areas have almost the same rent
  (Los Angeles $2,964, New York $2,971, Boston $3,008, Santa Ana–Anaheim–Irvine
  $3,057).
- **Caveats:** the population curve weights records by `pop2024`, which has the
  caveats above. Population weighting is still a statement about the geography in
  the file, not about renters. The $1,014 jump is explained by HUD's national
  minimum rent; other repeated values (909 in 98 areas across two states, 1,002
  in 67 across two, 961 in 66 across two, 962 in 62 across five) match state-level
  minimums in the same way (*hypothesis*, consistent with HUD's rule).
- **Why it matters here:** it is the clearest single picture of both the
  unit-of-analysis issue and the minimum-rent artifact.

### Figure 9 — Highest and lowest two-bedroom areas

- **Variables:** `fmr` (x); `hud_area_name` (y, ordered by two-bedroom `fmr`);
  `bedrooms` (color).
- **Chart type:** dot plot of the 12 highest and 12 lowest two-bedroom areas,
  showing all five rents for each area as colored dots.
- **Why:** the other figures say *how many* areas are extreme; this one says
  *which ones*, which is what you need if asked "where are rents highest?"
  Plotting all five bedroom counts also shows each area's whole schedule.
- **Question:** "Which areas are the extremes, and are they consistent across
  unit sizes?"
- **Observed:** highest two-bedroom FMRs: Santa Cruz–Watsonville, CA MSA $4,254;
  San Francisco, CA $3,697; Nantucket County, MA $3,583 (the only nonmetro area
  among the top 12); Napa, CA $3,375; San Jose–Sunnyvale–Santa Clara $3,272;
  Santa Maria–Santa Barbara $3,106; Santa Ana–Anaheim–Irvine $3,057; Boston $3,008;
  San Benito County, CA $3,004; New York $2,971; Los Angeles–Long Beach–Glendale
  $2,964; and San Diego–Chula Vista–Carlsbad, CA MSA. The **single highest rent in
  the file** is Santa Cruz–Watsonville's four-bedroom FMR of $5,748. The lowest 12
  are **all in Puerto Rico**. The overall minimum ($450, zero bedrooms) is
  Barranquitas–Aibonito, PR. Within each area the five rents rise (or tie) with
  bedroom count, and the dots spread much further apart for the expensive areas.
- **Caveats:** a ranking is not an explanation; the graph cannot say why
  Santa Cruz exceeds San Francisco. Long area names are shortened only by
  removing the suffix "HUD Metro FMR Area". Only the extremes are shown, so it
  says nothing about the middle.
- **Why it matters here:** it gives you the names you would need to answer
  "which are the most and least expensive places?" and highlights Puerto Rico as
  a separate rent regime.

---

## 7. Key findings

Each statement is labelled by what supports it. "Descriptive" means the figures
or tables show it directly; "documented" means HUD says so; nothing here is
causal.

1. **The file is cleaner than most, and its main complications are structural.**
   No duplicates, no missing rents or populations, rents increase with bedroom
   count in every record, and no impossible values. The notable problems
   concern what a "row" is. *(Descriptive.)*
2. **Rows are not independent markets.** 4,764 records collapse to 2,606 HUD
   areas; 281 areas account for 2,439 records. New England towns inflate row
   counts. *(Descriptive; Figure 1.)*
3. **FMR is right-skewed at every unit size**, with a long tail of expensive
   areas: area-level two-bedroom median $1,017 versus mean $1,150. *(Descriptive;
   Figure 2.)*
4. **Rent rises by roughly a stable proportion with bedrooms**, but the ratios are
   rule-bounded. About 38% of areas sit at the lower limit of the one-bedroom
   ratio. *(Descriptive: Figure 3. Rule: documented by HUD.)*
5. **Metro areas have higher and more variable rents at every unit size**, with a
   two-bedroom median ratio of about 1.24 and substantial overlap between the
   groups. *(Descriptive; Figure 5.)*
6. **Geography matters a lot but not completely.** State explains about 57% of
   the variation in log FMR across area–state pairs; California alone spans $1,084
   to $4,254. The ranking of states depends on the unit of analysis.
   *(Descriptive; Figures 4 and 8.)*
7. **The highest-rent areas are mostly in California, plus Nantucket, Boston, and
   New York; Puerto Rico forms a separate low-rent regime** ($517–$706 for two
   bedrooms). *(Descriptive; Figures 4 and 9. The reasons are not in the data.)*
8. **A national minimum rent shapes the bottom of the distribution.** 14.3% of
   areas have exactly $1,014, and 35.2% (918 areas) are below it. For many of
   those the applicable minimum is a lower state-level figure under HUD's rule,
   but I did not verify this area by area. *(Descriptive: Figure 8. Rule:
   documented by HUD.)*
9. **Population is positively associated with rent only within kinds of
   records.** Pooling records hides it (ρ = −0.04). Among areas the association is
   moderate for metro (0.58) and weak for nonmetro (0.11). *(Descriptive;
   Figures 6 and 7. Not causal.)*
10. **`pop2024` contains 34 zeros, all in sub-county records in Maine, New
    Hampshire, and Vermont.** Their names (e.g., "UT", "grant", "purchase")
    suggest unorganized territories. *(Descriptive; the meaning of the zeros is
    not established by the data.)*

---

## 8. Data-quality concerns and limitations

Status key: **Verified** = established from the file; **Documented** = HUD
explains it; **Unresolved** = cannot be settled from the provided data.

| # | Issue | What was observed | Why it matters | Status |
| --- | --- | --- | --- | --- |
| 1 | Missing `county_town_name` | 15,795 rows (66.31%); all for whole-county records | Not an error; it means "no sub-county unit." Dropping these rows would delete two-thirds of the data. | Verified |
| 2 | Two county-level records with a name | Petersburg Borough, AK; "Sullivan part", MO | The MO record is a *piece* of a county in a different HUD area than the rest, so the county name is not a unique key. | Verified; meaning of the AK name unresolved |
| 3 | Repeated rent schedules | 281 areas span 2,439 records (51.2%); max 114 records in one area | Row-level statistics overweight multi-record areas | Verified |
| 4 | Unequal geographic representation | ME has 529 records and 19 areas; TX has 254 records and 215 areas | Row counts by state mislead; state rankings by row means are biased | Verified |
| 5 | Identical rents across many areas | 372 areas (14.3%) have a two-bedroom FMR of exactly $1,014 | Looks like duplication but is a rule | Verified; cause **documented** (national minimum rent) |
| 6 | Other repeated values | $909 (98 areas, 2 states), $1,002 (67), $961 (66), $962 (62) | Likely state minimum rents | Cause is a **hypothesis** consistent with HUD's rule |
| 7 | Rule-bounded bedroom ratios | ~38% of areas at the lower one-bedroom limit, etc. | Bedroom effects are partly administrative | Verified; cause **documented** |
| 8 | Observed ratio extremes slightly outside documented intervals | e.g., 0-bedroom min 0.689, 3-bedroom max 1.391 | Cannot reconcile exactly | **Unresolved** (rounding, the 10% decline limit, or other adjustments are possible but untested) |
| 9 | Ties across bedroom sizes | 8 records where adjacent bedroom sizes have equal rent: six with 0 = 1 bedroom (Teton ID; Carter, Chouteau, Dawson, Fergus, Sheridan MT) and two with 3 = 4 bedrooms (Adams MS; Nemaha NE) | Contradicts a monotone expectation; HUD's methodology describes a 0.005 minimum gap in the ratios | **Unresolved** |
| 10 | Zero population | 34 sub-county records (ME 11, NH 17, VT 6) | Breaks log scales; weights nothing in population-weighted summaries; could mean no residents or no estimate | Verified that they exist; interpretation **unresolved** |
| 11 | Very small populations | 59 further records with population 1–99 | Rent for a place with 6 people is a very weak "market" | Verified |
| 12 | Population means different things | County total on county rows; town total on sub-county rows | Pooling rows distorts correlations (ρ = −0.04 pooled vs. 0.46 and 0.71 within type) | Verified |
| 13 | Source and vintage of `pop2024` | Not described in the handout | Weighting and correlations rest on an undocumented quantity | **Unresolved** |
| 14 | `metro` is a HUD designation | Includes single rural counties flagged as metro (e.g., Kalawao County, HI, pop 67) | "Metro" does not mean "dense" or "urban" | Verified |
| 15 | Areas spanning states | 36 areas cross state lines | State summaries count them once per state | Verified |
| 16 | Extreme rents | Highest: California areas, Nantucket, Boston; lowest: all Puerto Rico | Extremes could be real or erroneous; cannot cross-check against an external source here | Not evidence of errors; **unresolved** whether any are wrong |
| 17 | FMR is estimated, trended, and rule-bounded | See Section 4 | The file does not measure rents actually paid | **Documented** |
| 18 | One year, no time dimension | Single fiscal year | No trends or change can be assessed | Verified |
| 19 | No coordinates or boundaries | Only names and codes | No map-based analysis was possible, and no spatial autocorrelation can be assessed | Verified |

**What I deliberately did not do:** delete observations because they looked
unusual; impute anything; recode the 34 zero populations; or fit a model. No row
was removed at any step, so every statistic above uses all the rows relevant to
its stated unit.

---

## 9. Preparing for the in-class questions

The handout says you will be asked what your graphs show, why the data look the
way they do, and whether you have concerns about accuracy. It also says you will
be assessed on **recognizing questions the data cannot answer**. This section
collects likely questions with defensible answers. It is not a script.

**"What is the main message of the dataset?"**
Rents rise with unit size, metro areas cost more, there is large geographic
variation (including very high California rents and a separate low-rent
Puerto Rico), and the file's structure (areas shared by many records, minimum
rents, bounded ratios) is as important as the rent values. *(Figures 2, 4, 5.)*

**"Which states are most and least expensive?"**
Say *by which unit.* By area-level two-bedroom median: DC, HI, NJ, MA at the top;
Puerto Rico far below the rest, then LA, MS, AR, KY, OK. Note that DC is a single
area. Record-level and population-weighted rankings differ materially
(Maryland and Massachusetts are examples). *(Figures 4 and 8.)*

**"Why are there so many identical rents at $1,014?"**
HUD sets a minimum two-bedroom rent for every area: the lower of the state's
nonmetro population-weighted median and the national nonmetro median, which is
$1,014 in FY2027. Many areas are raised to that floor. *(Figure 8; the rule is
documented by HUD.)*

**"Why does one-bedroom FMR cluster at about 76% of two-bedroom FMR?"**
HUD constrains the ratio of each size to the two-bedroom rent within an interval
(0.76–0.92 for one bedroom). About 38% of areas land at the lower end.
*(Figure 3.)*

**"Does the data say larger places have higher rents?"**
Moderately, among metro areas (ρ = 0.58 across 649 areas) and only weakly among
nonmetro areas (ρ = 0.11). It is an association in 2024 population and 2027 rents;
it says nothing about causes. *(Figure 6.)*

**"Why did you use HUD areas instead of rows?"**
Because FMR is set per HUD area, and many records share an area. Using rows would
count the same rent many times — 114 times for the Boston area. *(Figure 1.)*

**"Do you have concerns about data accuracy?"**
The file is internally consistent (no duplicates, no missing rents, rents rise
with bedroom count in every record). Concerns: 34 zero-population records whose
meaning I cannot determine; eight ties across adjacent bedroom sizes I cannot
explain; a population column with undocumented source; extreme rents I cannot
verify externally; and the fact that FMRs are HUD estimates shaped by floors and
ratio bounds. *(Figures 3, 7; Section 8.)*

**"Why is Puerto Rico so low?"**
The graphs show that it is: all 12 lowest two-bedroom areas are in Puerto Rico,
$517–$706 for most. They do not show *why* (income, housing stock, methodology
differences, anything else). I would say this cannot be answered from this file.
*(Figures 4 and 9.)*

**"Are renters in metro areas worse off?"**
Cannot be answered. FMR measures a benchmark rent, not income or rent burden. You
would need household income, actual rents paid, and household composition.

**"What would you check next?"**
HUD's FMR documentation system for the extreme and tied records; the source and
definition of `pop2024`; whether the zero-population towns are unorganized
territories; prior-year FMRs (to see how the floor and decline limit change
values); and income or affordability data if the question is affordability.

**"What don't you understand about the data?"** *(Say this plainly; the handout
rewards it.)*
(1) Why eight records have tied bedroom sizes. (2) Why observed bedroom-ratio
extremes differ slightly from HUD's stated intervals. (3) What a zero in `pop2024`
means. (4) The origin of `pop2024`. (5) Why a few specific areas (e.g.,
Santa Cruz above San Francisco; Nantucket in the top 12) are as high as they are.

---

## 10. Reproduction instructions

### 10.1 Required software

| Tool | Notes |
| --- | --- |
| **R** | The code uses the native pipe `\|>` and `\(x)` lambdas, so R ≥ 4.1 is needed. Tested with 4.6.1. |
| **Quarto** | Needs the Typst PDF format (Quarto 1.4 or later). Tested with 1.10.18. It is bundled with RStudio; or install from <https://quarto.org>. |
| **R packages** | `tidyverse` (loads `ggplot2`, `dplyr`, `tidyr`, `readr`, `stringr`, `forcats`; also brings in `scales`), `knitr`, `rmarkdown`. |

No LaTeX installation is required; the PDF is produced through Typst, which Quarto
ships with. **Tested versions** (from the rendered document's own reproducibility
table): R 4.6.1, tidyverse 2.0.0, ggplot2 4.0.3, dplyr 1.2.1, readr 2.2.0,
scales 1.4.0, knitr 1.52, Quarto 1.10.18, on macOS. Minimum versions for each
function (for example `dplyr` ≥ 1.1.0 for `.by`, `ggplot2` ≥ 3.5.0 for the
`transform` argument of continuous scales) are inferred from documentation and
were **not** tested.

### 10.2 Install R packages

The document never installs packages for you. Run once in R:

```r
install.packages(c("tidyverse", "knitr", "rmarkdown"))
```

### 10.3 Expected folder structure

```
p1/
├── PSet1-housing.pdf              (assignment handout — do not edit)
├── fmr2027.csv                    (data — read-only, never modified)
├── PSet1-housing-analysis.qmd     (the one source of truth)
├── README.md
└── outputs/
    ├── submission/PSet1-housing-analysis.pdf   (code visible)
    └── printout/PSet1-housing-analysis.pdf     (code hidden)
```

The `.qmd` reads `fmr2027.csv` by the relative path `fmr2027.csv`, so the CSV must
sit next to the `.qmd`. Quarto runs code with the `.qmd`'s folder as the working
directory, so you can run the commands from any directory as long as you give the
path to the `.qmd`. No paths on any particular computer are used.

### 10.4 Render the submission PDF (code visible)

From the `p1` folder:

```sh
quarto render PSet1-housing-analysis.qmd --output-dir outputs/submission
```

Result: `outputs/submission/PSet1-housing-analysis.pdf` (21 pages when I rendered
it; the nine figures are on pages 3–11 after the code).

### 10.5 Render the class printout PDF (code hidden)

The handout's method is to change `echo: true` to `echo: false` in the YAML and
render again. Both of these work and give identical graphs:

**Option 1 — command-line override (no file edits; recommended):**

```sh
quarto render PSet1-housing-analysis.qmd -M echo:false --output-dir outputs/printout
```

**Option 2 — the handout's way:** in `PSet1-housing-analysis.qmd` change

```yaml
execute:
  echo: true
```

to `echo: false`, render, and change it back.

Result: `outputs/printout/PSet1-housing-analysis.pdf` (11 pages). **Print pages 1–7
only** — those are the figures. Pages 8–11 are supporting tables.

### 10.6 If `quarto` is not on your PATH

RStudio bundles Quarto but may not put it on the shell PATH. On macOS you can
use it with:

```sh
export PATH=$PATH:/Applications/RStudio.app/Contents/Resources/app/quarto/bin
```

or click **Render** in RStudio's editor for the `.qmd` (this writes
`PSet1-housing-analysis.pdf` beside the `.qmd`, so move it into the right
`outputs/` folder if you want to keep the structure above). I tested the
command-line renders, a plain `quarto render` with no options, and the YAML edit
described in Option 2; I did *not* test the RStudio Render button itself.

### 10.7 What I verified

- Both PDFs rendered with no warnings or errors.
- A scripted comparison confirmed the **nine figure image files are byte-for-byte
  identical** between the two modes. The only difference is the code.
- The submission PDF contains the R code; the printout contains none.
- The `.qmd` renders when run from the parent directory (relative paths work).
- The `.qmd` renders on a modified copy of the data with Maine and Puerto Rico
  removed (no hard-coded counts of rows, states, or areas).
- Source search: no `title`, `subtitle`, `annotate`, `geom_text`, `geom_label`,
  or `theme()` call exists in the plotting code.
- All code lines are 78 characters or fewer, so nothing is cut off in the PDF.

### 10.8 Troubleshooting

| Symptom | Likely cause and fix |
| --- | --- |
| `quarto: command not found` | Quarto isn't installed or isn't on PATH. See 10.6. |
| `there is no package called 'tidyverse'` (or `knitr`, `rmarkdown`) | Run the `install.packages` command in 10.2. |
| `cannot open file 'fmr2027.csv'` | The CSV is not next to the `.qmd`, or you edited `DATA_FILE`. |
| `unused argument (.by = ...)` or similar | `dplyr` is older than 1.1.0. Update with `install.packages("dplyr")`. |
| An error about `transform` in a scale | `ggplot2` is older than 3.5.0. Update it. |
| Typst/format error | Quarto older than 1.4. Update it. |
| The assignment handout was overwritten | Quarto's Typst pipeline writes `<name>.pdf` beside the `.qmd` before moving it. This is why the source is named `PSet1-housing-analysis.qmd`: a `PSet1-housing.qmd` would clobber `PSet1-housing.pdf`. Keep the names as they are. |
| The `.qmd` stops with a `stopifnot` error | An updated CSV changed shape (e.g., different `metro` codes or no two-bedroom rows). The check is intended; inspect the file. |

---

## 11. Sources

- Assignment handout: `PSet1-housing.pdf` (this folder).
- HUD User, *HUD Fair Market Rents (40th Percentile Rents)*:
  <https://www.huduser.gov/portal/datasets/fmr.html> — definition of FMR as
  estimates of 40th percentile gross rents for standard quality units; programs
  that use FMRs; geography (OMB metro areas, HUD subdivisions, nonmetro counties).
- Federal Register, *Fair Market Rents for the Housing Choice Voucher Program,
  Moderate Rehabilitation Single Room Occupancy Program, and Other Programs,
  Fiscal Year 2027* (Sept. 1, 2026):
  <https://www.federalregister.gov/documents/2026/09/01/2026-17891/fair-market-rents-for-the-housing-choice-voucher-program-moderate-rehabilitation-single-room>
  — bedroom ratio intervals, 8.7% and 7.7% adjustments, minimum rent
  ($1,014 national nonmetro rent), recent-mover factor, inflation and trend
  factors, and the 90% limit on year-over-year decline.
- HUD User, *Calculation of HUD Fair Market Rents* (FY2027 public methodology):
  <https://www.huduser.gov/portal/datasets/fmr/fmr2027/FY27-Public-FMR-Methodology.pdf>
  — bedroom-ratio procedure, including the 0.005 separation between adjacent
  ratios.

I consulted these while building the project; the documented facts in this README
come from them. Anything not traceable to one of these or to the CSV is labelled a
hypothesis.

---

## 12. Project file guide

| File | Purpose |
| --- | --- |
| `PSet1-housing.pdf` | The assignment handout (provided). **Never overwritten by renders.** |
| `fmr2027.csv` | The dataset (provided). Read-only; the code never writes to it. |
| `PSet1-housing-analysis.qmd` | The single Quarto source. Contains setup, import, derived tables, the nine final figures (first), then the supporting exploration and data checks (after a page break). It is the only file that defines the analysis; both PDFs come from it. |
| `outputs/submission/PSet1-housing-analysis.pdf` | Submission PDF, code visible. |
| `outputs/printout/PSet1-housing-analysis.pdf` | Printout PDF, code hidden. Print pages 1–7. |
| `README.md` | This document. |

There is no `_quarto.yml`, no helper script, and no extra package: the single
`.qmd` plus the CSV are everything required. Quarto may create a hidden `.quarto/`
cache folder; it is safe to delete.

### Code walkthrough (how the `.qmd` is organized)

1. **`setup`** — loads `tidyverse` and defines four constants: the data file
   name, `REF_BEDROOMS` (2), `N_EXTREME` (12), and the jitter seed.
2. **`import`** — reads the CSV with explicit types and `stopifnot` checks.
3. **`derive`** — builds `fmr` (records, with `metro` as a labelled factor and
   `record_type`), `areas` (one row per HUD area and bedroom size, after checking
   that `fmr` is constant within an area), `area_states` (area × state pairs), and
   the two-bedroom subsets `records_ref` and `areas_ref`.
4. **`figure-1` … `figure-9`** — one chunk per figure, each ending with
   `labs(..., caption = "Figure N") + theme_minimal(12)`.
5. **Supporting exploration and data checks** — tables behind the claims in this
   README: structure and missingness; duplicates and keys; record types;
   repeated areas and schedules; metro coding; population; the FMR distribution,
   repeated values, monotonicity, and bedroom ratios; state summaries under three
   units; population–FMR correlations.
6. **Reproducibility** — the versions of R and the main packages used for the run.

---

## 13. Academic and analytical caveats

- **FMR is not rent paid.** It is HUD's estimate of a 40th-percentile gross rent
  for standard-quality units, forecast to fiscal year 2027 and then adjusted by
  floors, ratio intervals, and decline limits. It is not an average, median, or
  asking rent, and it is not a transaction price.
- **FMR is not affordability.** Affordability requires household income and
  rent burden, which this file does not contain. "Housing costs are high here"
  is a defensible statement about FMR; "housing is unaffordable here" is not.
- **FMR is not homeownership cost.** It concerns rental units only.
- **No causal claims.** The graphs describe patterns. Reasons for them (wages,
  supply, tourism, regulation, climate, migration, …) require other data and
  designs.
- **No statistical inference.** The correlations and R² reported are descriptive
  summaries of this file, not tests, and no standard errors or p-values are
  claimed. The data are essentially a census of HUD areas, not a random sample.
- **Household-level claims are unsupported.** Nothing here describes any
  individual household or renter group.
- **Cross-sectional only.** One fiscal year.
- **Ecological caution.** Findings about areas do not transfer to individuals
  living in them.

---

## 14. Judgment calls on the graph rules

The handout's rules are strict ("no ... text labels on the plots"; axis labels
are "only variable names and units"). A few choices sit in a gray zone. I made
each deliberately and list them so you can decide whether to keep them. All are
easy to change in the `.qmd`.

1. **Facet strips such as `bedrooms: 2` (Figures 2, 3, 4, 6, 8) and
   `record_type: county` (Figure 7).** Strips are generated from data variables
   by `facet_*` with `labeller = label_both`; they are not annotations or added
   text. For Figures 4, 6, and 8, which are fixed at two bedrooms, the strip is
   the only way the graph can say which bedroom count it shows without a
   forbidden note. If you read the rules as forbidding strip text on single-panel
   figures, remove `facet_wrap(vars(bedrooms), ...)` from Figures 4, 6, and 8 and
   rely on your own knowledge that they use two bedrooms.
2. **Axis labels with parenthetical units or derived names:** `count (HUD areas)`,
   `count (records)`, `pop2024 (area sum)`, `fmr / fmr (2 bedrooms)`,
   `cumulative proportion`. These are variable names plus a unit or definition,
   not sentences. The most debatable are `pop2024 (area sum)` and
   `fmr / fmr (2 bedrooms)`; plain alternatives are `pop2024` and `fmr ratio`.
3. **Black median ticks in Figure 4 and the connecting segments in Figure 1.**
   These are geometric encodings of data (a summary statistic and the gap
   between two values), not annotations. They are not labelled on the plot.
4. **Figure 9's y-axis tick labels (area names)** and **Figure 4's state
   abbreviations** are axis tick labels, not text labels placed on the plot area.
   Area names have a common suffix removed; nothing else is altered.
5. **Legend titles (`metro`, `unit`, `bedrooms`)** are variable names.
6. **Jitter in Figure 4** displaces points vertically within a category and is
   fixed by a seed; horizontal position (the rent) is exact.
7. **A pseudo-log axis in Figure 7** is a transformation of the axis scale only;
   the breaks are labelled with plain numbers.
8. **The figure number** appears only as the `labs(caption = "Figure N")` caption
   the handout prescribes.
