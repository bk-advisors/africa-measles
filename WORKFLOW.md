# WORKFLOW.md

A repeatable workflow for turning a data visualization into a verified, publication-ready LinkedIn post — with supporting charts, figure audits, and source validation.

## The workflow

### 1. Draft the narrative first, then extract claims

Write the LinkedIn post (or have it drafted) before building any supporting assets. Once the narrative is stable, list every specific claim that can be checked against the data:

- Exact numbers ("1.4 million", "35,000")
- Percentages ("97% drop", "over 90%")
- Named entities ("Malawi, Zambia, Niger, Kenya")
- Time references ("in 2016", "starting in 2001")

### 2. Build a figure audit script

Create an R script (`R/audit_figures.R`) that programmatically checks each claim against the source CSV. Each check should:

- Print the actual value from the data
- Compare it to the claim (exact match, or within rounding tolerance)
- Output a clear PASS/FAIL verdict

Run this before every version of the post. If the narrative changes, update the audit script to match.

### 3. Validate the source data against APIs

Don't assume the CSV is correct — verify it against the original sources. Create a validation script (`R/validate_sources.R`) that:

- Fetches live data from the source APIs (WHO GHO, World Bank, etc.)
- Joins on country code + year
- Reports exact matches, discrepancies, and coverage gaps

**Key lesson from this project:** The WHO GHO hosts multiple indicators with similar names. Always verify the indicator code against actual returned values, not just the indicator name. In this case, `WHS3_62` (reported cases) was correct; `WHS3_41` returned completely different values.

### 4. Generate Quarto reports for the audits

Convert audit and validation scripts into Quarto reports for a permanent, shareable record:

- `audit-figures-report.qmd` — checks every claim with PASS/CHECK callouts
- `data-validation-report.qmd` — cross-references CSV against APIs

For API-dependent reports, use a two-step approach:
1. **Prep script** (`R/fetch_validation_data.R`) fetches data and saves to `.rds`
2. **Report** reads from the cached `.rds` — no network dependency at render time

This avoids flaky API connections during `quarto render`.

### 5. Create publication-ready chart assets

Build a separate R script for each chart that saves to `output/`:

- Use the project theme (`R/theme_bka.R`) for visual consistency
- Apply dataviz principles (see `principles/dataviz-principles.md`)
- Save at 300 DPI for print quality
- Generate multiple aspect ratios if needed (portrait for image posts, landscape for link shares)

Align captions across all charts — same source attribution format, same branding line.

### 6. Keep the Quarto project config clean

When standalone `.qmd` reports coexist with a website project, add a `render:` key to `_quarto.yml` listing only the website pages. This prevents RStudio's "Render" button from building everything (and failing on reports that have different dependencies).

```yaml
project:
  type: website
  output-dir: .
  render:
    - interactive-africa-measles.qmd
```

Standalone reports render individually from the terminal:
```bash
quarto render data-validation-report.qmd
```

## File organization pattern

```
project-root/
├── data/                        # Source data (CSV) + cached API data (.rds)
├── output/                      # Publication-ready PNGs
├── principles/                  # Reference guides (dataviz principles, etc.)
├── reports/                     # Standalone Quarto audit & validation reports
│   ├── audit-figures-report.qmd
│   └── data-validation-report.qmd
├── R/
│   ├── theme_bka.R              # Shared theme
│   ├── africa-measles-linkedin.R  # Chart → PNG scripts
│   ├── trend_chart.R
│   ├── audit_figures.R          # Claim verification (console output)
│   ├── validate_sources.R       # Source validation (console output)
│   └── fetch_validation_data.R  # API data caching for reports
├── interactive-africa-measles.qmd   # Main visualization (website)
├── _quarto.yml
└── CLAUDE.md
```

## Checklist before posting

1. Run `Rscript R/audit_figures.R` — all claims PASS
2. Run `Rscript R/fetch_validation_data.R` then `quarto render reports/data-validation-report.qmd` — all sources match
3. Run `Rscript R/africa-measles-linkedin.R` and `Rscript R/trend_chart.R` — PNGs generated
4. Review PNGs in `output/` — captions aligned, branding consistent
5. Final read of the LinkedIn post text against the audit output
