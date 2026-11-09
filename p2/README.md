# PSet 2: Health Insurance

Exploratory analysis of health insurance coverage in the U.S. using the
2024 ACS 1-year Public Use Microdata Sample (PUMS), downloaded from the
Census Microdata Access Tool (MDAT) as described in
`PSet2-health-insurance.pdf`. The deliverable is a `.qmd` with 10 figures and
its rendered PDF.

## Files

| File | What it is |
|---|---|
| `PSet2-ms7556.qmd` | The Quarto source. Submit this. |
| `ACSPUMS1Y2024_2026-11-08T19_39_51.008Z.csv` | The MDAT download (not modified). |
| `outputs/submission/PSet2-ms7556.pdf` | Rendered with the R code shown. Submit this. |
| `outputs/printout/PSet2-ms7556-printout.pdf` | Same document, code hidden. Print this (in color). |
| `render_pdfs.sh` | Renders both PDFs in one go. |
| `PSet2-health-insurance.pdf` | The assignment handout. |

The `.qmd` is deliberately **not** called `PSet2-health-insurance.qmd`.
Quarto's Typst step writes `<name>.pdf` next to the `.qmd` first, so a
`.qmd` with the handout's name would overwrite the handout (this happened in
PSet 1).

## How to render

You need R, Quarto (1.4 or newer) and the `tidyverse` package. The PDF uses
Quarto's built-in Typst, so no LaTeX is needed.

```r
install.packages("tidyverse")
```

Open a terminal in this folder (the `.qmd` uses relative paths only).

**Submission (code visible)**

```
quarto render PSet2-ms7556.qmd
```

**Printout (code hidden)**: as the handout says, change `echo: true` to
`echo: false` under `execute:` in the YAML, render, print, then change it
back. Or run the script, which does that on a temporary copy and renders
both:

```
./render_pdfs.sh
```

The script uses `quarto` from PATH if there is one, otherwise the copy that
ships with RStudio (`/Applications/RStudio.app/.../quarto/bin/quarto`). Set
`QUARTO=/path/to/quarto` to use a different one.

I checked that all 10 figure images are byte-for-byte identical in the two
versions (the jitter in Figure 10 uses `seed = 1`). Rendered with R 4.6.1,
ggplot2 4.0.3 and Quarto 1.10.18.

**Updated data.** The code picks up the newest file in the folder whose name
starts with `ACSPUMS` and ends in `.csv`, so a new MDAT download only has to be
dropped into the folder. It must be downloaded the same way (same four
variables, with the rows nested in the order MAR, HICOV, TEN and AGEP as the
column), because the code splits the `->` group labels in that order. No
counts or category totals are hard-coded; category labels are recoded by
pattern (for example anything starting with "N/A" becomes "Group quarters").

## The data

**Who / why / how.** The American Community Survey is run every year by the
U.S. Census Bureau. It mails (and follows up by phone/in person) about 3.5
million addresses to produce official estimates of the population's
characteristics. PUMS is a public, anonymized subset of the individual
responses (about 1% of the population per year). MDAT tabulates it online.

**What a number in the file is.** The handout asks for the **PUMS person
weight (PWGTP)**, so every count is an *estimated number of people in the
U.S.*, not a number of survey respondents. Each respondent stands in for
roughly 100 people. The file gives no sample sizes and no margins of error.

**Universe.** People aged 15-99 (AGEP grouped 15 to 99 by 10, with "Not
Elsewhere Grouped" unchecked, so under-15s are dropped), 50 states + DC (the
national PUMS excludes Puerto Rico). It includes people in group quarters:
dorms, nursing homes, prisons, military barracks. Total: **280,613,270 people,
of whom 25,246,844 (9.0%) are uninsured**.

**Structure.** The csv is not tidy: 4 metadata lines, then a column `Group`
with nested labels like `-> Married -> No health insurance coverage -> Rented`,
followed by one row per age group, and counts written with commas. The code
fills the group label down, keeps the age rows, and splits the label into
three columns. Result: 450 cells = 5 marital statuses x 2 coverage x 5 tenure
x 9 age groups (a complete cross).

| Variable | Meaning (2024 PUMS data dictionary) | Labels used in the figures |
|---|---|---|
| `AGEP` | Age, top-coded at 99 | 15-24, ..., 85-94, 95-99 |
| `MAR` | Marital status | Never married, Married, Separated, Divorced, Widowed |
| `HICOV` | Has *any* health insurance at the time of the interview | Insured, Uninsured |
| `TEN` | Tenure of the **household's** housing unit | Owned with mortgage, Owned free and clear, Rented, No rent paid, Group quarters |

## What I checked (not in the `.qmd`)

- Every subtotal in the file equals the sum of its age rows, and the cells add
  up to the grand total. No missing cells.
- **15 cells are exactly 0**, all uninsured old people (most at 95-99, a few
  at 75-94) and one insured cell (separated, no rent paid, 95-99). 68 of the
  450 cells are under 1,000 people (i.e. maybe about 10 respondents or fewer).
- **"Never married or under 15 years old"** is the official MAR label. Since
  under-15s are excluded, here it just means never married; I shortened it.
- **"N/A (GQ/vacant)"** tenure: for people (not housing units) "vacant" is
  impossible, so this category is the group-quarters population.
- **95-99 is a 5-year group**, the others are 10 years, so its count is
  not comparable to the other bars in Figure 1. Age is also top-coded
  (the Census replaces the top ~0.5% of ages in each state with a state mean),
  so the very old groups are partly synthetic.

## The figures

All rates are weighted: estimated uninsured people / estimated people.

1. **Population by age and coverage** (stacked counts). The population is
   flat at 41-46 million per group up to 64, then shrinks. The orange part
   (uninsured) almost vanishes from 65 on: **97.9% of the uninsured are
   under 65**. Largest uninsured group: 25-34 (6.6 million).
2. **Uninsured rate by age.** Rises from 11.3% (15-24) to a peak of 14.4% at
   25-34, then falls steadily to 7.6% at 55-64 and drops to 1.1% at 65-74
   and about 0.5% after. The cliff at 65 lines up with Medicare eligibility
   (an explanation from outside the data). The dip for 15-24 is consistent
   with Medicaid/CHIP for teens and staying on a parent's plan until 26.
3. **Uninsured rate by marital status, all ages.** Separated 16.0%, never
   married 13.4%, divorced 8.6%, married 6.4%, widowed 2.9%. This
   ordering is **misleading on its own**; see Figures 4 and 5.
4. **Marital status by age** (100% bars). Never married is 95% of 15-24;
   married peaks at 45-64; widowed is 52% of 85-94 and 68% of 95-99. So
   marital status is largely a stand-in for age.
5. **Uninsured rate by age and marital status.** In every age group from
   25-34 to 55-64 **married people have the lowest rate**, and in every group
   under 65 separated people have the highest (28.5% at 15-24, 23.4% at 25-34). Widowed people are *not* better covered than
   others of the same age; they look best in Figure 3 only because most of
   them are over 65. Exception: at 15-24 never married (11.0%) is below
   married (15.5%), likely because single young people are on parents' plans.
   The separated and widowed lines at young ages come from small groups
   (e.g. 20,000 widowed 15-24 year olds), so they are noisy.
6. **Uninsured rate by housing tenure, all ages.** Group quarters 17.2%,
   rented 14.2%, no rent paid 13.0%, owned free and clear 7.1%, owned with
   mortgage 5.9%. Renters are 45% of all uninsured people.
7. **Housing tenure by age** (100% bars). Owning free and clear grows with
   age (about half of people 75-94). Group quarters is U-shaped: 7.9% at 15-24
   (dorms), under 2% at 25-74, 9.2% at 85-94 and 15.8% at 95-99 (nursing
   homes). Note that 39% of 15-24 year olds are in "owned with mortgage"
   homes: tenure belongs to the household, so these are mostly young people
   living with their parents.
8. **Uninsured rate by age and housing tenure.** The standout oddity:
   **group quarters residents aged 25-54 are 37-44% uninsured**, versus 8%
   at 15-24 (students in dorms, who are often covered). The most likely
   explanation is prisons and jails, which are group quarters and whose
   inmates generally have no insurance of their own, but the data cannot
   separate GQ types. Among households, mortgage holders are lowest at
   every age under 65 (5-10%); renters and no-rent households are mostly
   highest (12-20%), with owners free and clear in between (except 25-34,
   where they are slightly above renters).
9. **Heatmap: uninsured rate by marital status x tenure, ages 15-64**
   (65+ removed because nearly everyone is insured). The lowest cell is
   married + owned with mortgage (5.0%), the highest separated + group
   quarters (42.7%). Within group quarters, never married is only 17.3%
   (mostly students) while married/divorced are about 40%. Separated is the
   worst column in every tenure.
10. **Estimated people in each table cell** (one point per cell, log scale,
    +1 so zeros show). A data quality figure: cell sizes span from 0 to over
    10 million. Uninsured cells at 65+ are tiny and the zeros (the row of
    points at 1) are all old ages. Rates built from those cells (the
    right side of Figures 5 and 8) rest on very few respondents.

## Main takeaways

- Age is the dominant factor: 11-14% uninsured below 45, about 1% or less
  from 65 on. Almost all uninsured people (98%) are 15-64, mostly 25-44.
- Marital status and tenure both matter *after* accounting for age: from
  25 to 64, married people and homeowners with a mortgage are the best
  covered; separated people and renters are among the least covered.
- Simple one-variable comparisons can mislead because marital status and
  tenure are tied to age (widowed, owned free and clear = old).
- Group quarters adults 25-54 are an extreme high-risk group (about 40%).

## Concerns and what I can't answer

- **Why.** The data contain no income, employment, citizenship, state, or
  insurance type (employer, Medicaid, Medicare, Marketplace), so causes such
  as Medicare at 65, ACA dependent coverage, or job loss after separation are
  plausible outside explanations, not conclusions from this file.
- **Uncertainty.** These are survey estimates from a ~1% sample. There are no
  margins of error in the export (they would need the 80 replicate weights),
  so small cells (the young widowed/separated, all uninsured 65+ cells, the
  zeros) should not be over-interpreted. A 0 means no respondent in the
  sample, not that nobody in the U.S. is in that group.
- **Point in time.** HICOV is coverage *on the day of the interview*. It says
  nothing about gaps during the year or about being underinsured.
- **Group quarters type** (prison vs nursing home vs dorm vs military) is not
  in the data, so the prison explanation for Figure 8 is a guess. Military
  members have coverage, which would push the GQ rate the other way.
- **Tenure is a household attribute**, not the person's own: a 20-year-old in
  "owned with mortgage" is probably not the owner.
- **Ages:** 95-99 is a narrower group and age is top-coded, so the oldest
  groups are approximate. Under-15s are not in the data at all.
- **Geography:** national totals only, no state differences (Medicaid
  expansion varies by state), no Puerto Rico.
- **Causal or individual-level claims** (e.g. "getting married gives you
  insurance") cannot be made from cross-sectional counts.
