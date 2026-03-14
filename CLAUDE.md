# CLAUDE.md

## Project Overview

Single-page Quarto interactive data visualization — an interactive heatmap of measles cases across African countries (1980–2023). Deployed to GitHub Pages. Includes supporting assets for a LinkedIn post: a static trend chart, figure audit report, and data validation report.

## Key Files

### Core visualization
- `interactive-africa-measles.qmd` — Quarto source (R code that generates the interactive heatmap)
- `index.html` — Rendered self-contained HTML (~10 MB, all CSS/JS embedded)
- `data/africa_measles.csv` — Source data (country, year, cases, population, cases_per_million)
- `_quarto.yml` — Quarto project config (website type, output to root, renders only the interactive heatmap)
- `.nojekyll` — Prevents Jekyll processing on GitHub Pages

### R scripts (all run from project root)
- `R/theme_bka.R` — BKA-branded ggplot2 theme (local copy; also exists at external path)
- `R/africa-measles-linkedin.R` — Generates publication-ready heatmap PNGs for LinkedIn
- `R/trend_chart.R` — Generates the continental trend bar chart PNG
- `R/audit_figures.R` — Verifies LinkedIn post claims against the data
- `R/validate_sources.R` — Cross-checks CSV against WHO and World Bank APIs
- `R/fetch_validation_data.R` — Fetches and caches API data for the validation report

### Reports (`reports/` — standalone Quarto, not part of the website project)
- `reports/audit-figures-report.qmd` — Quarto report auditing each LinkedIn claim
- `reports/data-validation-report.qmd` — Quarto report validating CSV against source APIs

### Output
- `output/africa_measles_trend.png` — Trend chart for LinkedIn
- `output/africa-measles-heatmap.png` — Heatmap portrait (4:5, best for image posts)
- `output/africa-measles-heatmap-wide.png` — Heatmap landscape (1.91:1, best for link shares)

### Reference
- `principles/dataviz-principles.md` — Data visualization principles guide (Tufte, Knaflic, Few, Cairo, Wong)

## Data Sources

| Column | Source | API Indicator |
|--------|--------|---------------|
| `cases` | WHO Global Health Observatory | **WHS3_62** (Measles — number of reported cases) |
| `population` | World Bank Open Data | **SP.POP.TOTL** (Population, total) |
| `cases_per_million` | Derived | `cases / population * 1,000,000` |

**Important:** The correct WHO indicator is `WHS3_62`, not `WHS3_41`. The WHO GHO hosts 6 measles indicators; `WHS3_41` returns different values (not reported case counts).

## Theme

`R/theme_bka.R` is a local copy of the BKA theme. The interactive `.qmd` sources this local copy. The theme provides `theme_bka()`, `bka_colors`, and palette functions. The external path (`../../synthesized-lessons/_common/theme_bka.R`) is no longer required.

## Rendering

```bash
# Interactive heatmap (website project)
quarto render interactive-africa-measles.qmd

# Standalone reports (render from reports/ folder)
Rscript R/fetch_validation_data.R          # fetch API data first (run from project root)
quarto render reports/data-validation-report.qmd
quarto render reports/audit-figures-report.qmd

# LinkedIn assets
Rscript R/africa-measles-linkedin.R        # heatmap PNGs
Rscript R/trend_chart.R                    # trend chart PNG
```

The `_quarto.yml` `render:` key is set to only `interactive-africa-measles.qmd`, so clicking "Render" in RStudio won't accidentally build the standalone reports.

## Deployment

- GitHub Pages serves from `main` branch root (`/`)
- Live URL: https://bk-advisors.github.io/africa-measles/
- After pushing to `main`, Pages deploys automatically (1-2 min delay)
- The output must be named `index.html` for Pages to serve it as the landing page

## R Packages Required

`ggplot2`, `dplyr`, `ggiraph`, `scales`, `jsonlite`
