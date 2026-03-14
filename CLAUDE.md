# CLAUDE.md

## Project Overview

Single-page Quarto interactive data visualization — an interactive heatmap of measles cases across African countries (1980–2023). Deployed to GitHub Pages.

## Key Files

- `interactive-africa-measles.qmd` — Quarto source (R code that generates the interactive heatmap)
- `index.html` — Rendered self-contained HTML (~10 MB, all CSS/JS embedded)
- `data/africa_measles.csv` — Source data (country, year, cases, population, cases_per_million)
- `_quarto.yml` — Quarto project config (website type, output to root)
- `.nojekyll` — Prevents Jekyll processing on GitHub Pages

## External Dependency

The `.qmd` sources a custom theme: `source("../../synthesized-lessons/_common/theme_bka.R")`. This file lives outside this repo. The theme provides `theme_bka()` and `bka_colors` used throughout the visualization. To re-render, this file must be accessible at the relative path.

## Re-rendering

```bash
quarto render interactive-africa-measles.qmd
```

Output goes to `index.html` (configured via `output-file` in the YAML front matter).

## Deployment

- GitHub Pages serves from `main` branch root (`/`)
- Live URL: https://bk-advisors.github.io/africa-measles/
- After pushing to `main`, Pages deploys automatically (1-2 min delay)
- The output must be named `index.html` for Pages to serve it as the landing page

## R Packages Required

`ggplot2`, `dplyr`, `ggiraph`, `scales`
