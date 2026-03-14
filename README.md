# Africa Measles Heatmap

Interactive heatmap showing how vaccination campaigns led to a dramatic reduction in measles cases across Africa.

**[View the live interactive visualization](https://bk-advisors.github.io/africa-measles/)**

## About

This visualization maps reported measles cases per million population across African countries from 1980 to 2023. It highlights the impact of the **WHO/UNICEF Measles Initiative** launched in 2001, which contributed to a **90%+ reduction** in measles cases across the continent.

Hover over any tile to explore country-level details including year, reported cases, and cases per million population.

## Data Sources

- **Cases:** WHO Global Health Observatory
- **Population:** World Bank

Countries with 15+ years of reporting are included.

## Tech Stack

- [R](https://www.r-project.org/) — data processing and visualization
- [Quarto](https://quarto.org/) — document rendering
- [ggplot2](https://ggplot2.tidyverse.org/) + [ggiraph](https://davidgohel.github.io/ggiraph/) — interactive heatmap
- GitHub Pages — hosting

## Local Development

To re-render the visualization:

```bash
quarto render interactive-africa-measles.qmd
```

Requires R with packages: `ggplot2`, `dplyr`, `ggiraph`, `scales`.

---

*Visualization by [BK Advisors](https://bk-advisors.github.io)*
