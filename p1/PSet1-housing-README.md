# PSet 1: The Price of Housing

## Project overview

This project explores the U.S. Department of Housing and Urban Development (HUD) Fair Market Rent (FMR) dataset for fiscal year 2027. It was prepared for the data-visualization / exploratory-data-analysis assignment **“PSet 1: The Price of Housing.”** The handout says that the FY2027 FMRs become effective on October 1, 2026, and cover U.S. counties, county equivalents, and New England towns by number of bedrooms.

The assignment asks for up to 10 graphs that help an analyst understand the data, communicate major patterns, notice unusual features, and answer questions that have not been supplied in advance. The submitted graphs are intended to stand on their own: they have no explanatory plot titles or annotations, use variable names and units for axis labels, and use figure-number captions for reference.

This README is the explanatory companion to the final files. The explanations below are outside the graphs and do not change the graph formatting required by the assignment.

## Files and reproduction

The final files shared for this submission are:

| File | Purpose |
|---|---|
| `PSet1-housing(1).qmd` | Quarto source file containing the R code and all 10 graph definitions. |
| `PSet1-ms7556.pdf` | Submitted PDF with the R code visible. |
| `PSet1-ms7556-printout.pdf` | Printout PDF with the code hidden and the graphs shown. |
| `fmr2027.csv` | Dataset required to run the source file. Keep it beside the `.qmd` file. |

The data file is referenced in the code as `fmr2027.csv`, a relative filename. The source should therefore be rendered from a project folder containing both the `.qmd` and the CSV. The code-visible and printout versions are intended to contain the same figures; the intended difference is code visibility.

### Software and packages

The source uses **R**, **Quarto**, and the `tidyverse` package. It also uses functions from packages included in the tidyverse ecosystem, including `readr`, `dplyr`, `tidyr`, `forcats`, and `ggplot2`, plus `scales` for readable numeric axis labels. In a fresh R installation, install the main package with:

```r
install.packages("tidyverse")
```

Install Quarto separately and make sure it is available to the command line. The document uses Quarto's `typst` PDF output format.

From the directory containing the source file and CSV, render the submitted source with:

```bash
quarto render "PSet1-housing(1).qmd"
```

The submitted `.qmd` has `echo: true`, so its code is displayed. To reproduce a code-hidden printout from the same source, change the YAML option under `execute` from `echo: true` to `echo: false`, render again, and save the resulting PDF as `PSet1-ms7556-printout.pdf`. Restore `echo: true` for the code-visible submission version. The graph code should not be changed between these two renders.

If the file is renamed to remove the `(1)` suffix, update the render command accordingly. Do not rename `fmr2027.csv` unless the `data_file` setting in the QMD is changed too.

---

## Dataset description

### What a row represents

The CSV has **23,820 rows and 11 columns**. Each row represents a geographic record at one bedroom count. There are **4,764 distinct `fips` geographic records**, and each one has five rows: `bedrooms = 0, 1, 2, 3, 4`. This gives 4,764 × 5 = 23,820 rows.

The data also identify **2,606 distinct HUD FMR areas**. These are not the same thing as the 4,764 geographic records. Multiple county/town records can be assigned to one HUD FMR area, and the same area can occur in more than one state. This distinction matters throughout the analysis: counting geographic records gives some HUD areas more weight than counting unique HUD areas.

The dataset has 56 distinct `stusps` / `state` codes. This includes states as well as the District of Columbia and U.S. territories shown in the file, including Puerto Rico and American Samoa. Treat these as the geographic units actually present in this source rather than assuming the file contains only the 50 states.

### Column-by-column dictionary

The names and basic meanings below are based on the provided CSV, the assignment handout, and the way the final QMD uses the variables. Where the source file does not give a fuller definition, the description is intentionally limited to what can be established from the data and code.

| Column | Type / role | Meaning and how it is used |
|---|---|---|
| `fips` | Geographic identifier; read as character | Identifier for a geographic record. It must be kept as text because identifiers can contain leading zeros. The QMD uses the ending `99999` to distinguish whole-county records from sub-county records for the analyses in Figures 7 and related comments. |
| `stusps` | Categorical text | State or territory postal abbreviation, such as `NY`, `CA`, or `PR`. Used to compare counts and rents across geographic areas in Figures 1 and 5. |
| `state` | Geographic code; read as character | State/geographic code supplied by the source. It is read as text to preserve leading zeros. The final plotting code does not use this field directly. |
| `countyname` | Categorical text | County or county-equivalent name as supplied by the source. Names need not be unique across states, so this is not a reliable standalone key. |
| `county_town_name` | Categorical text, with missing values | Town or sub-county name where the source provides one. Many values are missing because the corresponding record represents a whole county rather than an individual town. This should not be treated automatically as an error. |
| `hud_area_code` | HUD-area identifier; text | Identifier for the HUD Fair Market Rent area. The code groups geographic records that share the same FMR schedule. It is used to form the area-level data for Figures 2–6, 8–10. |
| `hud_area_name` | Categorical text | Human-readable name for the corresponding HUD FMR area. Used to display and identify selected areas in Figures 9 and 10. |
| `metro` | Binary category in the source | Indicates whether the record is classified as metropolitan (`1`) or nonmetropolitan (`0`). The QMD converts the values to the labels `metro` and `nonmetro`; these labels are used in Figures 3, 5, and 6. |
| `pop2024` | Numeric population count | Population field associated with the geographic record. The code uses it directly in Figure 7 and sums it across records when building the area-level data used by Figure 6. It is not a count of renters or housing units. |
| `bedrooms` | Ordered numeric/category | Number of bedrooms represented by the FMR schedule: 0, 1, 2, 3, or 4. Zero-bedroom FMR generally corresponds to an efficiency/studio unit. The variable is used for the rent-distribution, boxplot, ratio, and extreme-area comparisons. |
| `fmr` | Numeric dollar value | Fair Market Rent value for the geographic area and bedroom category. It is the main variable analyzed in this project. The assignment presents these values as FMR in dollars. |

### Data quality and structural checks

Checks on the supplied CSV show the following:

- There are **no fully duplicated rows**.
- There are **no duplicated `(fips, bedrooms)` keys**.
- Each of the 4,764 geographic records has all five bedroom values.
- `county_town_name` is the only column with missing values: **15,795 of 23,820 rows (about 66.3%)**. The missingness is largely structural and associated with whole-county records; it should not be interpreted as random missing data without further investigation.
- The population field contains zero values for **34 geographic records**. Because each geographic record has five bedroom rows, these appear on all five bedroom rows in the CSV (170 rows in total). Figure 7 uses the two-bedroom subset and shows those 34 geographic records.
- The FMR values are non-decreasing with bedroom count for all geographic records. For 4,756 of the 4,764 records they strictly increase; the other eight include a tie at one or more adjacent bedroom sizes.
- Within the data, the FMR is constant for a given `hud_area_code` and `bedrooms` pair. Therefore, the same schedule can be repeated for several underlying geographic records.

These checks describe the structure of the file; they do not prove that every source value is correct. Unusual values should be investigated rather than automatically removed.

### A note on the unit of analysis

Two units are used in the project:

1. **Geographic records**: a row representing a county, county-equivalent, or sub-county unit for a given bedroom count.
2. **HUD FMR areas**: unique HUD areas, with one rent value per bedroom category.

The QMD creates `areas` by grouping records by `hud_area_code`, `hud_area_name`, `metro`, and `bedrooms`. For each group, it takes the first FMR value, sums `pop2024` into `pop`, and counts the number of geographic records as `n_records`. This is based on the observed data structure where rent is consistent within each HUD area and bedroom category.

This area-level data is important because an area represented by many geographic records should not automatically count as many independent rent schedules. For state-based graphs, the code uses distinct state–HUD-area combinations so an area spanning state lines can appear in each state it touches.

The distinction does not mean one unit is always better than the other. It depends on the question. Figures about file composition may appropriately use records; figures describing the distribution of HUD rent schedules generally use unique HUD areas.

---

## The 10 graphs: detailed reading guide

The figure numbers below match the final PDFs. In the printout PDF, Figures 1–6 occupy pages 1–6, Figures 7 and 8 share page 7, Figure 9 is on page 8, and Figure 10 is on page 9.

### Figure 1 — Geographic records compared with HUD areas by state

**Graph type:** Paired dot plot, with a thin line connecting the two counts for each state/territory. The horizontal count axis is logarithmic.

**What is plotted:** For each `stusps`, the graph compares the number of two-bedroom geographic records with the number of distinct HUD areas represented in that state. The two-bedroom filter is used so that each geographic record is counted once rather than five times for the five bedroom categories. The record count is `n()`; the area count is `n_distinct(hud_area_code)` within a state.

**How to read it:** The two colored points show the two counts for a state. A long connector means the state contains many geographic records relative to the number of distinct HUD areas. The logarithmic axis makes it possible to show states with only one or a few areas alongside states with hundreds.

**What it reveals:** Maine stands out: it has 529 geographic records but only 19 distinct HUD areas. Massachusetts, New Hampshire, Vermont, and Connecticut also have many more records than areas. These are states where the dataset includes many town/sub-county records. In most other states, the two counts are closer together, although they are not necessarily identical.

**Why it matters:** A count of rows is not the same as a count of independent rent schedules. This figure warns against treating every CSV record as a separate housing market or calculating a state summary by simply averaging all rows.

**Caveat:** An HUD area that crosses a state boundary is counted once within each state it touches. Therefore, adding the state-level HUD-area counts does not necessarily produce the number of nationally unique HUD areas.

### Figure 2 — FMR distributions by number of bedrooms

**Graph type:** Five vertically faceted histograms, one for each bedroom category, with a common dollar scale and a bin width of $100.

**What is plotted:** `fmr` among the unique HUD area–bedroom combinations, with the count axis representing HUD areas. Each panel contains the rent distribution for 2,606 HUD areas at that bedroom count.

**How to read it:** Each bar counts how many HUD areas have FMR values in a given $100 interval. Using a common horizontal scale makes it possible to compare the rent ranges across bedroom sizes.

**What it reveals:** The distributions are right-skewed: most areas have values toward the lower end, with fewer areas at much higher values. The distribution shifts toward larger dollar amounts as bedroom count rises. Four-bedroom FMRs show a particularly long upper tail, with the maximum across the file reaching $5,748.

**Why it matters:** The histogram shows the overall shape of the main variable without letting repeated county/town records give extra weight to the same HUD rent schedule. It also shows that one average would not fully describe the distribution, especially because of the high-rent tail.

**Caveat:** Histogram appearance depends on the bin width. The graph is descriptive; it does not explain why some areas have much higher FMR values than others.

### Figure 3 — FMR by bedroom count and metropolitan status

**Graph type:** Side-by-side boxplots, with bedroom count on the horizontal axis and color showing `metro` versus `nonmetro`.

**What is plotted:** FMR distributions using the unique HUD area–bedroom data. Each box summarizes the median and middle 50% of rent values for one bedroom category and metropolitan status; points beyond the whiskers show observations flagged as outliers by the boxplot rule.

**How to read it:** Compare the medians, box heights, whiskers, and upper outliers between metro and nonmetro areas at the same bedroom count. The boxplots allow many areas to be compared without plotting every name separately.

**What it reveals:** FMR rises with bedroom count for both categories. Metropolitan HUD areas have higher medians and broader distributions than nonmetropolitan areas. For two-bedroom FMR, the median is $1,256 in metro areas and $1,014 in nonmetro areas. The difference also appears for the other bedroom categories: metro/nonmetro medians are approximately $958/$761 for zero bedrooms, $1,027/$813 for one bedroom, $1,634/$1,318 for three bedrooms, and $1,900/$1,508 for four bedrooms.

**Why it matters:** Bedroom size and metropolitan status are both associated with differences in the FMR schedule. Comparing them together is more informative than looking at bedroom count alone.

**Caveat:** A boxplot summarizes a distribution; it does not show the identity of every area or establish that metropolitan status itself causes the difference. The points classified as outliers are not necessarily data errors.

### Figure 4 — Rent for each bedroom category relative to two-bedroom FMR

**Graph type:** Histograms of ratios, faceted by bedroom count for 0-, 1-, 3-, and 4-bedroom units. Each histogram uses a bin width of 0.01; the panels use free horizontal scales.

**What is plotted:** For each HUD area, the FMR for a bedroom category is divided by that same area's two-bedroom FMR. The two-bedroom category itself is left out because its ratio would always be 1.

**How to read it:** A ratio below 1 means the category's FMR is lower than the same area's two-bedroom value; a ratio above 1 means it is higher. For example, a ratio of 1.30 means the rent is 30% higher than the area's two-bedroom FMR.

**What it reveals:** The median ratios are approximately 0.75 for zero-bedroom units, 0.79 for one-bedroom units, 1.30 for three-bedroom units, and 1.47 for four-bedroom units. There are noticeable concentrations/spikes rather than a perfectly smooth distribution. This is a sign that bedroom-size FMRs follow a structured schedule and are not independent, unrelated values.

**Why it matters:** Absolute rents differ substantially from one HUD area to another. Dividing by the same area's two-bedroom value helps compare the relative rent schedule across areas and shows the typical proportional change with bedroom count.

**Caveat:** Because each facet has its own horizontal scale, the widths of different panels should not be compared as if they had identical axes. The ratios describe the structure of the published schedule, not an independently measured price premium for every real apartment.

### Figure 5 — Two-bedroom FMR by state, with metro status and state medians

**Graph type:** State-level dot plot. Each point is a distinct state–HUD-area combination at two bedrooms; color denotes metro status. A short black vertical mark indicates the median for each state. Points are jittered slightly up/down to make overlapping values easier to see.

**What is plotted:** The two-bedroom FMRs from distinct HUD areas represented in each state. The states are ordered by their median FMR, making the relative distributions easier to scan. If a HUD area crosses state lines, the area can appear in each state it touches.

**How to read it:** Read horizontally to compare FMR values within a state and vertically to compare distributions across states. The black marker gives a compact summary of the state's median; the colored points reveal spread and individual higher- or lower-rent areas.

**What it reveals:** States vary in both typical two-bedroom FMR and within-state spread. Some states have a relatively concentrated cloud, while others have a much wider range and a few very high values. Higher-rent areas appear among states such as California, Massachusetts, Hawaii, New Jersey, and the District of Columbia; many of the lowest values appear in Puerto Rico. Metro areas often appear to the right of nonmetro areas, though the pattern is not absolute.

**Why it matters:** A state median communicates a typical value while the individual points retain information about variation within the state. This avoids hiding all local differences behind one state average.

**Caveat:** State distributions have different numbers of HUD areas, and not every state contains both metro and nonmetro areas. The plot is descriptive and should not be interpreted as a ranking of household affordability or actual rents paid.

### Figure 6 — Two-bedroom FMR versus population

**Graph type:** Scatterplot with a logarithmic horizontal axis. Color distinguishes metro from nonmetro areas.

**What is plotted:** Each point is one HUD area at two bedrooms. The horizontal variable is the area-level population total created in the QMD by summing `pop2024` across the geographic records assigned to that HUD area. The vertical variable is its two-bedroom FMR. Although the axis is labelled `pop2024`, the values in this plot are the aggregated `pop` created in the code, not the unaggregated population from a single CSV row.

**How to read it:** The log axis means equal horizontal distances represent multiplicative changes in population rather than equal changes in people. Color helps distinguish metro and nonmetro areas. Look for broad trends, clusters, and exceptions rather than expecting all points to follow a straight line.

**What it reveals:** Higher-population areas often have higher FMRs, particularly among metro areas, but the relationship is not deterministic. There is substantial scatter: areas with similar populations can have different FMR values, and some low-population areas have relatively high FMRs. The metro areas extend farther into the high-population and high-rent region of the plot.

**Why it matters:** The plot investigates whether population size is associated with FMR and makes differences between metropolitan categories visible in the same display.

**Caveat:** Population is not the same as housing demand, household income, or the number of renters. Aggregating population across records depends on the geographic structure of the source, and an association in this graph does not demonstrate causation.

### Figure 7 — Population distribution for county and sub-county records

**Graph type:** Histograms faceted by `record_type`, using a logarithmic horizontal axis. The code adds 1 to population before applying the log scale so zero-population records can be represented.

**What is plotted:** The two-bedroom subset of the original geographic records, not the aggregated HUD-area data. In the final code, `record_type` is derived from `fips`: identifiers ending in `99999` are labelled `county`; the others are labelled `sub-county`.

**How to read it:** Each panel shows how many geographic records fall into population intervals. The shared log scale allows very small and very large populations to be shown. Because the plotted value is `pop2024 + 1`, a source population of zero appears at 1 on the horizontal scale.

**What it reveals:** County records generally have much larger populations than sub-county records, while the sub-county distribution includes many smaller population units. The far-left bar in the sub-county panel reflects 34 records whose population is zero. These are observations to investigate, not values that should be silently removed.

**Why it matters:** This plot helps explain why population values should be interpreted in light of the type and size of the geographic unit represented by each row. It also documents a noticeable data feature directly.

**Caveat:** The `county`/`sub-county` classification is a rule derived from the FIPS identifier in this code. It is a practical classification used for this analysis, not a full independent verification of every jurisdiction's legal or statistical status. Adding 1 changes the exact value at the origin; it is used to display zero values on the logarithmic axis.

### Figure 8 — Distribution of two-bedroom FMR by record versus HUD area

**Graph type:** Two overlaid density curves. One curve uses the original geographic records and the other uses the unique HUD areas.

**What is plotted:** Both curves use two-bedroom FMR values. The record-level curve has 4,764 records, while the HUD-area curve has 2,606 unique areas. A density curve is normalized, so the comparison is about distributional shape rather than the raw number of rows.

**How to read it:** Compare where each curve peaks and how widely each spreads across FMR values. The record distribution gives more weight to an area when that area's schedule appears on many geographic records; the unique-area distribution gives each HUD FMR area one observation.

**What it reveals:** Both distributions concentrate around the lower two-bedroom rent values and have a right tail. The record-level curve is broader and places relatively more weight on some higher values; the HUD-area curve has a sharper concentration near roughly $1,000. For context, the median two-bedroom FMR is $1,228 when calculated over geographic records and $1,017 when calculated over unique HUD areas.

**Why it matters:** This is one of the clearest demonstrations of why the unit of analysis matters. A repeated schedule is not a new independent rent value simply because it is attached to another geographic row.

**Caveat:** Density curves depend on bandwidth and smooth the data. They show the distributions represented by the two choices of unit, not uncertainty or the accuracy of the HUD estimates.

### Figure 9 — Bedroom schedules in the 12 lowest- and 12 highest-rent HUD areas

**Graph type:** Dot plot with HUD area names on the vertical axis, FMR on the horizontal axis, and color representing bedroom count.

**What is plotted:** The code first ranks unique HUD areas by their two-bedroom FMR and selects the 12 lowest and 12 highest areas. It then plots the FMR for all five bedroom categories for each selected area. The names are ordered according to their rent values across the displayed bedroom rows.

**How to read it:** Each horizontal group of colored dots corresponds to one HUD area. The colors locate zero-, one-, two-, three-, and four-bedroom FMRs. Horizontal distance between dots shows the dollar difference between bedroom categories; horizontal position of the whole group shows the rent level of that area.

**What it reveals:** The high-rent end includes places such as Santa Cruz–Watsonville, San Francisco, Nantucket, Napa, San Jose, and several other California or Northeastern areas. The low-rent end includes multiple areas in Puerto Rico. Within an area, FMR generally rises as the bedroom count rises. The figure also makes clear that the range between the low- and high-rent places is large at every bedroom count.

**Why it matters:** Choosing areas using a common two-bedroom benchmark makes the selection rule clear, while displaying all bedroom categories shows whether the geographic contrast persists beyond the two-bedroom value.

**Caveat:** The endpoints were selected using two-bedroom FMR only. This is a deliberately focused view of extremes, not a representative sample of all HUD areas. Ties at the selection boundary can make the exact set of selected areas dependent on the source ordering.

### Figure 10 — HUD areas represented by the largest number of geographic records

**Graph type:** Horizontal dot plot of the 15 HUD areas with the largest `n_records` values.

**What is plotted:** `n_records` is calculated when the QMD collapses the dataset to one row per HUD area and bedroom category. Figure 10 uses the two-bedroom subset, so each dot represents one HUD area and the number of geographic records assigned to it. The x-axis starts at zero for context.

**How to read it:** The farther right the point lies, the more geographic records are mapped to the HUD area. The labels make it possible to identify the areas with the most rows.

**What it reveals:** The Boston-Cambridge-Quincy, MA–NH HUD Metro FMR Area is represented by 114 records, the largest count in this plot. Other areas with high counts include Aroostook County, ME (71), Hartford-West Hartford-East Hartford, CT (55), Penobscot County, ME (part) HUD Metro FMR Area (53), and Washington County, ME (48). Many of the highest-count areas are in New England.

**Why it matters:** This plot directly exposes uneven representation of HUD areas in the row-level data. The count reflects how many geographic records are assigned to an area, not its population, number of apartments, or number of renters. It helps explain why record-weighted rent distributions and naive averages can differ from summaries in which each HUD area counts once.

**Caveat:** Having more records does not mean that an area has more distinct FMR schedules. For a given bedroom category, an HUD area still has one FMR value.

---

## Key findings across the figures

1. **The unit of analysis matters.** There are 4,764 geographic records but only 2,606 HUD FMR areas. Counts and rent distributions at the record level weight some areas more heavily because those areas cover more geographic records.
2. **Rent distributions are right-skewed.** Most HUD areas have lower or moderate FMR values, while a smaller group have much higher values. The upper tail is particularly wide for larger bedroom categories.
3. **FMR increases with bedroom count.** This is visible in the histograms, boxplots, ratio distributions, and extreme-area comparison. Rents are non-decreasing across bedroom sizes for each geographic record; only eight of the 4,764 records have a tie between adjacent bedroom categories.
4. **Metro areas generally have higher FMRs.** The median metro two-bedroom FMR is $1,256 versus $1,014 in nonmetro areas, and the same pattern appears for the other bedroom sizes. There is still variation and overlap within each category.
5. **Geography is unevenly represented in the source file.** Maine, Massachusetts, New Hampshire, Vermont, and Connecticut have many town/sub-county records. A record count can therefore tell a different story from a count of unique HUD areas.
6. **Population and FMR are associated, but not perfectly.** More-populated HUD areas often have higher rents, especially among metro areas, but there is considerable variation and the plot does not establish why the differences occur.
7. **The population zeros and missing town names deserve context.** Zero population values are concentrated in sub-county records in this file, and the large number of missing town names is largely structural rather than arbitrary missingness.
8. **The high- and low-rent ends are geographically different.** The selected highest-rent areas include several California and Northeastern locations, whereas many of the lowest two-bedroom values occur in Puerto Rico. This is descriptive; the graphs do not explain the causes.

## Important interpretation limits

- **FMR is the measure in the dataset.** The project should not treat it as a direct observation of the rent paid by every household or as a complete measure of housing affordability.
- **There is no household-level affordability information here.** The CSV does not provide household income, actual rent burdens, apartment listings, lease transactions, or housing quality. Those questions require other data.
- **A plot does not establish causality.** The population and metro comparisons describe association, not causal effects.
- **Some values repeat by design of the geography.** Repeated FMR values across geographic records are not automatically duplicate errors; the dataset maps those records to HUD areas.
- **Outliers are prompts for investigation.** They may reflect real differences in the FMR schedules, special geography, or data issues. They should not be deleted without evidence.
- **Population aggregation needs care.** Figure 6 uses the sum of `pop2024` across records grouped into a HUD area. The interpretation depends on the geographic coverage of those records.
- **The source file does not answer every metadata question.** For full technical details about how HUD constructed each FMR estimate, consult the applicable HUD documentation rather than inferring the methodology from the CSV alone.

## How to use this README for the in-class questions

For each graph, be prepared to explain (1) what one point, bar, box, or curve represents; (2) whether it uses geographic records or unique HUD areas; (3) the major pattern; (4) any anomaly; and (5) what cannot be concluded from the plot. A useful general habit is to say explicitly whether a statement is a direct description of the data or a possible explanation that would need more evidence.

The strongest recurring theme in this dataset is that **a row is not necessarily an independent rent market**. Figures 1, 8, and 10 make this especially clear, while Figures 2–6 and 9 use the HUD-area structure to examine the rents themselves.
