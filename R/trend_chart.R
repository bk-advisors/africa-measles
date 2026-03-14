# ---- Publication-quality trend chart: Africa measles cases 1980–2023 ----
# Companion to the interactive heatmap for use in the LinkedIn post.
# Outputs: output/africa_measles_trend.png
#
# Usage: Rscript R/trend_chart.R

library(ggplot2)
library(dplyr)
library(scales)

source("R/theme_bka.R")

df <- read.csv("data/africa_measles.csv")

yearly <- df %>%
  group_by(year) %>%
  summarise(total_cases = sum(cases, na.rm = TRUE), .groups = "drop")

peak <- yearly %>% slice_max(total_cases, n = 1)
low  <- yearly %>% slice_min(total_cases, n = 1)

# ---- Knaflic: strategic color — focal bars saturated, context bars muted ----
yearly <- yearly %>%
  mutate(
    focal = case_when(
      year == peak$year ~ "peak",
      year == low$year  ~ "low",
      TRUE              ~ "context"
    )
  )

# Cairo: semantic color — red for the urgent peak, green for the achievement
bar_fills <- c(
  "peak"    = "#E24A3F",
  "low"     = "#83BD00",
  "context" = "#ACCBF9"
)

p <- ggplot(yearly, aes(x = year, y = total_cases, fill = focal)) +
  # Few: bars must start at zero
  geom_col(width = 0.7) +                                 # Tufte: white space between bars
  scale_fill_manual(values = bar_fills, guide = "none") +  # Knaflic: direct labeling, no legend

  # Few: anchor bars at zero — expansion only at top for label room
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.08))
  ) +

  scale_x_continuous(
    breaks = seq(1980, 2020, 5),
    expand = expansion(mult = c(0.01, 0.02))               # Knaflic: whitespace breathing room
  ) +

  # Cairo: annotations are essential — mark the Measles Initiative
  geom_vline(
    xintercept = 2001,
    linewidth = 0.7, linetype = "dashed",
    color = bka_colors$title_dark, alpha = 0.5
  ) +
  annotate("text",
    x = 2001.3, y = max(yearly$total_cases) * 0.72,
    label = "WHO/UNICEF\nMeasles Initiative\n(2001)",
    hjust = 0, size = 3, fontface = "italic",
    color = bka_colors$subtitle_gray,
    family = "Lato", lineheight = 1.1
  ) +

  # Knaflic: direct labeling eliminates legend lookup
  annotate("text",
    x = peak$year, y = peak$total_cases,
    label = paste0(peak$year, "\n", round(peak$total_cases / 1e6, 1), "M cases"),
    vjust = -0.4, size = 3.2, fontface = "bold",
    color = "#E24A3F", family = "Lato", lineheight = 1.1
  ) +
  annotate("text",
    x = low$year, y = low$total_cases,
    label = paste0(low$year, "\n", comma(low$total_cases)),
    vjust = -0.4, size = 3.2, fontface = "bold",
    color = "#3E9B6E", family = "Lato", lineheight = 1.1
  ) +

  # Knaflic: visual hierarchy — title states the insight
  labs(
    title = "Africa went from 1.4 million measles cases to 35,000\nin 35 years — a 97% reduction",
    subtitle = "Total reported measles cases across 46 African countries, 1980–2023",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Source: WHO Global Health Observatory (cases) & World Bank (population)   |   ",
      "Visualization: BK Advisors \u2014 bk-advisors.github.io"
    )
  ) +

  coord_cartesian(clip = "off") +
  theme_bka() +
  theme(
    axis.line.x = element_line(
      color = bka_colors$border_light, linewidth = 0.4    # Few: subtle axis line
    ),
    axis.line.y = element_blank(),                         # Tufte: gridlines serve as y reference
    plot.title = element_text(lineheight = 1.15),
    plot.margin = margin(20, 25, 15, 15)                   # Knaflic: extra right margin for labels
  )

# ---- Save ----
dir.create("output", showWarnings = FALSE)

ggsave(
  "output/africa_measles_trend.png",
  plot = p,
  width = 10, height = 6, dpi = 300,                       # Few: wider-than-taller aspect ratio
  bg = "white"
)

cat("Saved to output/africa_measles_trend.png\n")
