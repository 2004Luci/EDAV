# PSet 2: Health Insurance

## Project overview

This project explores health insurance coverage in the United States using the **2024 American Community Survey (ACS) 1-year Public Use Microdata Sample (PUMS)**. It was prepared for the data-visualization / exploratory-data-analysis assignment **"PSet 2: Health Insurance."** In the scenario of the handout, a state agency wants to understand who is and is not covered by health insurance. The data were downloaded from the Census Bureau's Microdata Access Tool (MDAT) with four variables: age (`AGEP`), housing tenure (`TEN`), marital status (`MAR`), and health insurance coverage (`HICOV`).

The assignment asks for up to 10 graphs that summarize the data, reveal major patterns and unusual features, and help answer questions that have not been supplied in advance. Following the PSet 2 rules, the graphs have only minimal titles, no subtitles, annotations or text labels, minimal human-readable axis labels, only the basic theme change `theme_minimal(12)`, and a figure-number caption (`labs(caption = "Figure N")`). Because the handout notes that color is more helpful this time than in PSet 1, the graphs use color, with colorblind-safe palettes.

This README is the explanatory companion to the final files. The explanations below are outside the graphs and do not change the graph formatting required by the assignment.

## Files and reproduction

| File | Purpose |
|---|---|
| `PSet2-ms7556.qmd` | Quarto source file containing the R code and all 10 graph definitions. Submit this. |
| `outputs/submission/PSet2-ms7556.pdf` | Submitted PDF with the R code visible. |
| `outputs/printout/PSet2-ms7556-printout.pdf` | Printout PDF with the code hidden and the graphs shown. Print this in color. |
| `health-insurance.csv` | MDAT download required to run the source file. Keep it beside the `.qmd`. |
| `render_pdfs.sh` | Script that renders both PDFs. |
| `PSet2-health-insurance.pdf` | The assignment handout. |

The source file is deliberately **not** named `PSet2-health-insurance.qmd`. Quarto's Typst step first writes `<file name>.pdf` next to the `.qmd`, so a source file with the handout's name would overwrite the handout.

### Software and packages

The source uses **R**, **Quarto**, and the `tidyverse` package (`readr`, `dplyr`, `tidyr`, `stringr`, `forcats`, `ggplot2`), plus `scales` for percent and comma axis labels. The Okabe-Ito colors come from base R's `palette.colors()`, and the heatmap uses ggplot2's built-in viridis scale. In a fresh R installation:

```r
install.packages("tidyverse")
```

The document uses Quarto's `typst` PDF format, so LaTeX is not required. From the folder that contains the `.qmd` and the CSV, render the submission version with:

```bash
quarto render PSet2-ms7556.qmd
```

The submitted `.qmd` has `echo: true`. As the handout says, the printout is made by changing the YAML option under `execute` from `echo: true` to `echo: false` and rendering again. `render_pdfs.sh` does exactly this on a temporary copy and renders both versions:

```bash
./render_pdfs.sh
```

The script uses `quarto` from the PATH if available, and otherwise the copy bundled with RStudio. I checked that the 10 figure images are byte-for-byte identical in the two versions; the only jittered plot (Figure 10) uses `seed = 1`.

### Reproducibility with an updated dataset

- The code prefers `health-insurance.csv`, and otherwise uses the only `.csv` in the folder. A new MDAT download only needs to be placed beside the `.qmd`. There are no references to a particular hard drive.
- No counts or totals are typed into the code; everything is computed from the file.
- Category labels are recoded by pattern (for example, any tenure label starting with "N/A" becomes "Group quarters"), so small changes in label wording are tolerated.
- The download must be made the same way as described in the handout: the same four variables, with `MAR`, `HICOV` and `TEN` nested in the rows in that order, and age groups as the column. The code splits the nested row label in that order.

---

## Dataset description

### Who collected the data, how, and why

The **American Community Survey** is conducted continuously by the **U.S. Census Bureau**. About 3.5 million addresses are sampled each year, and responses are collected online, by mail, by phone and in person. It is the main source of yearly information on the population's social, economic and housing characteristics, and is used, for example, to allocate federal funding. The **PUMS** is a public, anonymized subset of individual responses: the 1-year file contains about 1% of the U.S. population. To protect confidentiality, some values are modified (for example, ages are top-coded). The national PUMS covers the 50 states and the District of Columbia; Puerto Rico is a separate file and is not included.

### What a number in the file represents

The handout asks for the **PUMS person weight (PWGTP)**. Every count is therefore an **estimate of the number of people in the U.S.** in a category, not the number of people who answered the survey. Each respondent represents roughly 100 people. The export does **not** include the number of respondents or margins of error.

The universe is people aged **15 to 99**. Ages were grouped from 15 to 99 in steps of 10, with "Not Elsewhere Grouped" unchecked, so people under 15 are excluded. The data include people living in **group quarters** such as college dorms, nursing homes, prisons and military barracks.

- Total population in the file: **280,613,270**
- Uninsured: **25,246,844 (9.0%)**

### File structure and how the code tidies it

The MDAT CSV is not a tidy table:

1. The first 4 lines are metadata (dataset, weight, universe, geography).
2. The first column, `Group`, contains nested labels such as `-> Married -> No health insurance coverage -> Rented`. Subtotal rows exist for each level of nesting.
3. Each fully nested group is followed by one row per age group (`Between 15 and 24`, ..., `Between 95 and 99`).
4. Counts are written with thousands separators (`"5,751"`).

The setup chunk skips the metadata, parses the counts with `parse_number()`, fills each group label down to its age rows, keeps only the age rows, and splits the label on `->` into three columns. The result, `cells`, has **450 rows = 5 marital statuses x 2 coverage values x 5 tenure categories x 9 age groups**, a complete cross with one count per cell. The helper function `rates()` sums the weighted counts for any grouping and computes the uninsured rate as estimated uninsured people divided by estimated people.

### Column-by-column dictionary

Definitions are from the 2024 ACS PUMS data dictionary.

| Variable | Meaning | Values in the file | Label used in the figures |
|---|---|---|---|
| `AGEP` | Age in years, top-coded at 99. | 9 groups: 15-24, 25-34, ..., 85-94, and 95-99. | Same groups, shortened to e.g. `15-24`. |
| `MAR` | Marital status. | Married; Widowed; Divorced; Separated; Never married or under 15 years old. | "Never married or under 15 years old" is shortened to **Never married**, because nobody under 15 is in the data. |
| `HICOV` | Health insurance coverage recode: whether the person has **any** health insurance (employer, purchased, Medicare, Medicaid, military/VA, etc.) at the time of the interview. It has no "not applicable" code, so it is defined for everyone. | With health insurance coverage; No health insurance coverage. | **Insured**, **Uninsured**. |
| `TEN` | Tenure of the **housing unit** the person lives in. It is a household characteristic, not the person's own status. | Owned with mortgage or loan (include home equity loans); Owned free and clear; Rented; Occupied without payment of rent; N/A (GQ/vacant). | **Owned with mortgage**, **Owned free and clear**, **Rented**, **No rent paid**, **Group quarters**. A person cannot live in a vacant unit, so the N/A category is the group-quarters population. |
| `Count` | Weighted estimate of the number of people (sum of PWGTP). | 0 to over 10 million per cell. | `count` in the code. |

### Data quality and structural checks

These checks were run while exploring the data; they are not in the `.qmd`, which contains only the 10 figures.

- **Totals reconcile.** Every subtotal in the file equals the sum of its age rows, and the 450 cells add up to the grand total of 280,613,270. There are no missing cells.
- **Zero cells.** 15 cells are exactly 0. Fourteen are uninsured cells at old ages (12 at 95-99, the others at 75-94); one is an insured cell (separated, no rent paid, 95-99). A zero means no respondent in the sample fell in that cell, not that nobody in the U.S. does.
- **Small cells.** 68 of the 450 cells are below 1,000 estimated people, which at about 100 people per respondent corresponds to roughly 10 respondents or fewer. Rates computed from such cells are very uncertain.
- **Uneven age groups.** 95-99 covers 5 years; the other groups cover 10. Its count is therefore not directly comparable with the others.
- **Top-coding.** The Census Bureau replaces the highest ~0.5% of ages in each state with a state mean, so the composition of the oldest groups is partly synthetic.
- **Label oddity.** "Never married or under 15 years old" appears even though under-15s are excluded; it is the official label, and here simply means never married.
- **Tenure belongs to the household.** 39% of people aged 15-24 live in "owned with mortgage" housing, which mostly means young people living in their parents' homes, not young homeowners.

---

## The 10 graphs: detailed reading guide

The figure numbers below match the final PDFs. In the printout PDF there are two figures per page: Figures 1-2 on page 1, 3-4 on page 2, 5-6 on page 3, 7-8 on page 4 and 9-10 on page 5. Unless stated otherwise, every rate is weighted: estimated uninsured people divided by estimated people in the group. Colors are kept consistent: orange always means uninsured, the same five colors always mean the same marital statuses (Figures 4-5), and the same five colors always mean the same tenure categories (Figures 7-8).

### Figure 1 — Population by age and coverage

**Graph type:** Stacked bar chart of counts, one bar per age group, with the uninsured part (orange) at the bottom and the insured part (grey) on top.

**What is plotted:** The estimated number of people (in millions) in each age group, split by coverage. All marital statuses and tenures are summed.

**How to read it:** The total bar height is the size of the age group; the orange segment is the number of uninsured people. Because the orange segments share a common baseline at zero, their heights can be compared directly across age groups.

**What it reveals:** The population is roughly flat at 41-46 million per 10-year group from 15 to 64, then shrinks quickly (19.3 million at 75-84, 5.8 million at 85-94, 0.5 million at 95-99). The orange segment is largest at 25-34 (6.6 million uninsured) and nearly invisible from 65 on. **97.9% of all uninsured people are aged 15-64.**

**Why it matters:** An agency deciding where to focus outreach needs absolute numbers, not only rates. This figure shows where the uninsured people actually are, and that the older population, while large, contributes very few uninsured people.

**Caveat:** The 95-99 bar covers only 5 years of age, so its height is not comparable with the 10-year bars. Counts are survey estimates with sampling error.

### Figure 2 — Uninsured rate by age

**Graph type:** Bar chart of percentages.

**What is plotted:** The share of each age group that is uninsured.

**How to read it:** Each bar is a rate between 0% and 100%; the bars start at zero, so their lengths are proportional to the rates.

**What it reveals:** The uninsured rate is 11.3% at 15-24, peaks at **14.4% at 25-34**, and then falls steadily: 12.2% (35-44), 10.3% (45-54), 7.6% (55-64). It then drops sharply to **1.1% at 65-74** and about 0.5-0.6% at older ages.

**Why it matters:** This is the main trend in the data: age is the strongest single factor associated with coverage. The cliff at 65 coincides with Medicare eligibility, and the lower rate for 15-24 than for 25-34 is consistent with Medicaid/CHIP for teenagers and the ACA rule that allows young adults to stay on a parent's plan until age 26.

**Caveat:** Medicare and the age-26 rule are explanations from outside the data; the file contains no information on the type of insurance. The age groups are wide, so the exact age at which rates change cannot be seen.

### Figure 3 — Uninsured rate by marital status (all ages)

**Graph type:** Cleveland dot plot, sorted by rate, with the axis starting at 0%.

**What is plotted:** The uninsured rate for each marital status, with all ages and tenures combined.

**How to read it:** Each dot is one marital status; dots further right have higher uninsured rates.

**What it reveals:** Separated 16.0%, never married 13.4%, divorced 8.6%, married 6.4%, widowed 2.9%.

**Why it matters:** This is the simple comparison an agency might start with. However, it is **confounded by age**: it should be read together with Figures 4 and 5, which show that the low rate for widowed people is mostly an age effect.

**Caveat:** A one-variable summary mixes people of very different ages. It does not show that marital status itself affects coverage.

### Figure 4 — Marital status by age

**Graph type:** 100% stacked bar chart (each bar sums to 100%).

**What is plotted:** The composition of each age group by marital status.

**How to read it:** The height of each colored segment is the share of the age group with that marital status. Segments at the bottom and top of the bars are easiest to compare; middle segments are harder because they do not share a baseline.

**What it reveals:** Never married is 94.7% of 15-24 and 57.5% of 25-34. Married rises to 60-64% for ages 35-74. Widowed grows from almost nothing to 25.2% at 75-84, **51.9% at 85-94 and 67.5% at 95-99**. Separated is a thin slice (at most 2.6%) in every age group.

**Why it matters:** Marital status is strongly tied to age. Widowed people are mostly over 65, and almost everyone over 65 is insured (Figure 2), so it is no surprise that widowed people have the lowest overall rate in Figure 3. This figure explains the difference between Figures 3 and 5.

**Caveat:** The bars show shares, not counts: the 95-99 bar represents only 0.5 million people, while the 15-24 bar represents 44.7 million.

### Figure 5 — Uninsured rate by age and marital status

**Graph type:** Dot-and-line chart; age on the horizontal axis, one colored line per marital status.

**What is plotted:** The uninsured rate within each combination of age group and marital status. Lines simply connect the age groups in order to make each group easier to follow.

**How to read it:** Compare colors at the same age to see marital status differences with age held roughly constant; follow one color across ages to see how its rate changes.

**What it reveals:**

- Separated people have the highest rate in every age group under 65 (28.5% at 15-24, 23.4% at 25-34, 13.9% at 55-64).
- From 25-34 to 55-64, **married people have the lowest rate** (10.8%, 8.9%, 7.9%, 5.8%).
- **Widowed people are not better covered than others of the same age.** At 25-34 they are 21.4% uninsured, and at 35-64 they are close to the never-married and divorced lines. Their low overall rate in Figure 3 comes from their age distribution — an example of how combining groups can reverse comparisons.
- At 15-24 the ordering is different: never married people (11.0%) are below married people (15.5%), which is consistent with unmarried young people being covered as dependents on parents' plans.
- After 65 all lines collapse to near zero.

**Why it matters:** This is the fairest comparison of marital statuses in the data, because it compares people of similar ages.

**Caveat:** Some points come from small groups: about 20,000 widowed people aged 15-24 and 80,000 aged 25-34, and small separated groups at old ages. Those points (for example the widowed bump at 25-34 and the separated rise at 85-99) are noisy and should not be over-interpreted.

### Figure 6 — Uninsured rate by housing tenure (all ages)

**Graph type:** Cleveland dot plot, sorted by rate, with the axis starting at 0%.

**What is plotted:** The uninsured rate for each tenure category, all ages and marital statuses combined.

**How to read it:** Each dot is one tenure category; dots further right have higher rates.

**What it reveals:** Group quarters 17.2%, rented 14.2%, no rent paid 13.0%, owned free and clear 7.1%, owned with mortgage 5.9%. Renters are 28% of the population but **45% of all uninsured people** (11.4 million).

**Why it matters:** Tenure is a rough indicator of economic situation, and renters are a large group to target for outreach.

**Caveat:** Like Figure 3, this is confounded by age: owning free and clear is common among older people (Figure 7), who are almost all insured.

### Figure 7 — Housing tenure by age

**Graph type:** 100% stacked bar chart.

**What is plotted:** The composition of each age group by tenure of the housing they live in.

**How to read it:** Same as Figure 4: each bar sums to 100%, and segment heights are shares of the age group.

**What it reveals:**

- **Owned free and clear** grows with age, from about 12-15% under 45 to about half of people aged 75-94.
- **Owned with mortgage** peaks at 45-54 (52.9%).
- **Rented** peaks at 25-34 (45.9%).
- **Group quarters is U-shaped:** 7.9% at 15-24 (college dorms, military), under 2% from 25 to 74, then 9.2% at 85-94 and **15.8% at 95-99** (nursing homes).
- 39% of 15-24 year olds live in a home with a mortgage — mostly their parents' home.

**Why it matters:** This explains part of Figure 6 (older people tend to own outright and are insured), and it is the key to understanding the group-quarters pattern in Figure 8.

**Caveat:** The type of group quarters (dorm, prison, nursing home, barracks) is not in the data; the explanations in parentheses are reasonable guesses.

### Figure 8 — Uninsured rate by age and housing tenure

**Graph type:** Dot-and-line chart; age on the horizontal axis, one colored line per tenure category.

**What is plotted:** The uninsured rate within each combination of age group and tenure.

**How to read it:** Compare colors at the same age to see tenure differences with age held roughly constant.

**What it reveals:** The standout oddity of the dataset:

- **Group quarters residents aged 25-54 are 37-44% uninsured** (39.4%, 43.8%, 37.4%), far above every other group.
- At 15-24, group quarters residents are only 8.0% uninsured — about the same as mortgage holders — consistent with mostly college students in dorms who are covered by student or parents' plans.
- At ages 85+ the group-quarters line is near zero, consistent with nursing-home residents on Medicare.
- Among people in households, mortgage holders have the lowest rate at every age under 65 (5-10%). Renters and no-rent households are mostly highest (12-20%), and owners free and clear are in between, except at 25-34, where they are slightly above renters.

**Why it matters:** The adult group-quarters population is small (about 3.0 million people aged 25-64) but has by far the highest uninsured rate. A likely explanation is incarceration: prisons and jails are group quarters, and incarcerated people generally do not have their own insurance coverage.

**Caveat:** The prison explanation cannot be confirmed from this file, because group-quarters type is not included. Military barracks are also group quarters, and military members are covered, which would pull the rate in the opposite direction.

### Figure 9 — Uninsured rate by marital status and tenure, ages 15-64

**Graph type:** Heatmap (tiles colored by a continuous viridis scale).

**What is plotted:** The uninsured rate for each combination of marital status (columns) and tenure (rows), restricted to people aged 15-64. People 65 and over are left out because nearly all of them are insured, and including them would dilute the differences.

**How to read it:** Brighter (yellow) tiles have higher uninsured rates; darker (purple) tiles have lower rates. Read along a row to compare marital statuses within one tenure category, or down a column to compare tenures within one marital status.

**What it reveals:**

| Tenure | Never married | Married | Separated | Divorced | Widowed |
|---|---|---|---|---|---|
| Owned with mortgage | 9.5% | **5.0%** | 12.3% | 8.3% | 8.8% |
| Owned free and clear | 14.9% | 9.1% | 18.6% | 13.4% | 11.3% |
| Rented | 16.5% | 15.5% | 20.1% | 14.0% | 13.7% |
| No rent paid | 18.5% | 14.5% | 27.6% | 16.3% | 15.3% |
| Group quarters | 17.3% | 40.4% | **42.7%** | 41.3% | 31.1% |

- The lowest rate is married people in mortgaged homes (5.0%); the highest is separated people in group quarters (42.7%).
- **Separated is the highest column in every tenure category.**
- Within group quarters, never married people (17.3%, a group dominated by students) are far below married and divorced people (about 40%), which again points to institutions other than dorms.

**Why it matters:** It shows the two characteristics together, so the agency can see which combinations are most at risk.

**Caveat:** Color is less precise than position for reading exact values. Some tiles are small groups (for example, about 65,000 widowed and 130,000 separated people in group quarters). Age is still mixed within the 15-64 range.

### Figure 10 — Estimated people in each table cell

**Graph type:** Jittered strip plot with a logarithmic vertical axis.

**What is plotted:** One point per cell of the table (marital status x coverage x tenure x age group), for 450 points. The vertical value is the estimated count plus 1, so that zero cells can be shown on the log scale (they appear at 1). Color shows whether the cell is insured or uninsured. Points are jittered horizontally (with a fixed seed) to reduce overplotting.

**How to read it:** Higher points are larger cells. Each gridline step on the log axis is a factor of 100.

**What it reveals:** Cell sizes range from 0 to over 10 million. Insured cells are mostly much larger than uninsured cells. From 65 on, uninsured cells become very small, and all of the **zero cells are at old ages** (the row of points at 1, mostly at 95-99).

**Why it matters:** This is a data-quality figure. Rates computed from small cells, especially the right-hand side of Figures 5 and 8 and the small groups in Figure 9, rest on very few respondents and have large sampling error. It helps answer the question "how reliable are these numbers?"

**Caveat:** Cell size is shown as a weighted estimate, not as the number of respondents, which the export does not provide. Adding 1 is only a device to place zeros on the log axis.

---

## Key findings across the figures

1. **Age is the dominant factor.** About 11-14% of people under 45 are uninsured, 7.6% at 55-64, and about 1% or less from 65 on (Figures 1-2). 97.9% of the uninsured are 15-64, with the most at 25-34.
2. **The overall rate is 9.0%** (25.2 million uninsured among 280.6 million people aged 15-99).
3. **Marital status matters after accounting for age.** From 25 to 64, married people are the best covered and separated people the worst (Figure 5).
4. **One-variable comparisons can mislead.** Widowed people appear best covered overall (Figure 3) only because most are old (Figure 4); within age groups they are not.
5. **Tenure matters too.** Mortgage holders are the best covered at every working age; renters, people paying no rent and people in group quarters are the least covered (Figures 6 and 8). Renters are 45% of the uninsured.
6. **Group quarters adults are an extreme group.** Residents aged 25-54 are 37-44% uninsured, while group quarters residents aged 15-24 and 85+ are well covered (Figures 7-8). The data cannot say which institutions are responsible.
7. **Combined risk.** The best-covered combination is married + owned with mortgage (5.0%); the worst is separated + group quarters (42.7%) among ages 15-64 (Figure 9).
8. **Small and zero cells** exist mainly among uninsured people aged 65 and over, so those rates are imprecise (Figure 10).

## Important interpretation limits

- **The data cannot explain why.** There is no income, employment, education, citizenship, race/ethnicity, disability, state, or type of insurance in this extract. Medicare at 65, Medicaid, the ACA age-26 rule, or losing a spouse's employer coverage after separation are plausible outside explanations, not conclusions from the file.
- **No causal claims.** The data are cross-sectional counts; they cannot show that getting married, or owning a home, causes people to have insurance.
- **Sampling error is not shown.** The counts are estimates from about a 1% sample. Margins of error would require the 80 replicate weights, which are not part of the export.
- **Point-in-time coverage.** `HICOV` is coverage on the day of the interview. It says nothing about gaps during the year, how good the coverage is, or underinsurance.
- **Group quarters type is unknown.** Dorms, nursing homes, prisons and barracks are combined into one category.
- **Tenure is a household attribute.** It describes the home, not whether the person is the owner or renter.
- **Age is coarse and top-coded.** Age is available only in 10-year groups (5 years for 95-99), the oldest ages are top-coded, and people under 15 are not included.
- **National totals only.** State differences, which matter a lot for health insurance (for example Medicaid expansion), cannot be seen; Puerto Rico is not included.
- **Survey responses.** Coverage is self-reported (or reported by a household member), and some answers are imputed by the Census Bureau.

## How to use this README for the in-class questions

For each graph, be ready to explain:

1. what one bar, dot, line, tile or point represents;
2. whether it shows counts (Figures 1 and 10), shares of a group (Figures 4 and 7), or uninsured rates (Figures 2, 3, 5, 6, 8 and 9);
3. the main pattern;
4. any oddity;
5. what cannot be concluded from the plot.

It helps to say explicitly whether a statement is a direct description of the data or a possible explanation that would need more evidence.

The strongest recurring themes in this dataset are:

- **Age dominates coverage, and it is tied to both marital status and tenure.** Comparisons of marital status or tenure should therefore be made within age groups (Figures 5, 8 and 9) rather than over all ages (Figures 3 and 6).
- **Adults in group quarters are the clearest unusual feature.** Their high uninsured rate is one of the questions the data alone cannot answer.
