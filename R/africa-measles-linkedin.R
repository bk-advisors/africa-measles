# =============================================================================
# africa-measles-linkedin.R
# Standalone polished heatmap of African measles cases (1980-2023)
# Ready for saving and publishing on LinkedIn / social media
#
# Produces two PNG files:
#   1. africa-measles-heatmap.png      — 4:5 portrait (best for image posts)
#   2. africa-measles-heatmap-wide.png — 1.91:1 landscape (best for link shares)
#
# Usage (from project root):
#   Rscript R/africa-measles-linkedin.R
#
# Data source: WHO Global Health Observatory (cases) + World Bank (population)
# =============================================================================

library(ggplot2)
library(dplyr)
source("R/theme_bka.R")

# ---- Load pre-processed data ----
africa_measles <- read.csv("data/africa_measles.csv")

# ---- Sort countries by average pre-2001 case rate (highest at top) ----
country_order <- africa_measles %>%
  filter(year < 2001) %>%
  group_by(country) %>%
  summarise(avg_rate = mean(cases_per_million, na.rm = TRUE), .groups = "drop") %>%
  arrange(avg_rate) %>%
  pull(country)

africa_measles <- africa_measles %>%
  mutate(country = factor(country, levels = country_order))

# ---- BKA multi-stop gradient ----
measles_gradient <- c(
  colorRampPalette(c("#ACCBF9", "#005CB9", "#83BD00", "#F8A623"))(15),
  colorRampPalette(c("#F8A623", "#FA7650", "#E24A3F"))(5)
)

# ---- Build the heatmap ----
p <- ggplot(africa_measles, aes(x = year, y = country, fill = cases_per_million)) +
  geom_tile(colour = "white", linewidth = 0.4,
            width = 0.9, height = 0.9) +
  scale_fill_gradientn(
    colours = measles_gradient,
    limits = c(0, 5000),
    breaks = seq(0, 5000, by = 1000),
    labels = c("0", "1K", "2K", "3K", "4K", "5K"),
    na.value = "#F5F5F5",
    name = "Reported cases per million population",
    oob = scales::squish,
    guide = guide_colourbar(
      barwidth = 15, barheight = 0.6,
      title.position = "top",
      title.hjust = 0.5,
      ticks = TRUE, nbin = 50
    )
  ) +
  scale_x_continuous(expand = c(0, 0),
                     breaks = seq(1980, 2020, by = 5)) +
  geom_vline(xintercept = 2001, color = bka_colors$title_dark,
             linewidth = 1.2, alpha = 0.8) +
  annotate("text", label = "WHO/UNICEF\nMeasles Initiative",
           x = 2001, y = length(country_order) + 0.5,
           hjust = -0.05, vjust = 1,
           size = 4, fontface = "bold", family = "Lato",
           color = bka_colors$title_dark) +
  coord_cartesian(clip = "off") +
  labs(
    title = "Mass immunization campaigns cut African measles cases by over 90%\nbut outbreaks persist where coverage gaps remain",
    subtitle = "Reported measles cases per million population by country, 1980-2023",
    x = NULL, y = NULL,
    caption = paste0(
      "Source: WHO Global Health Observatory (cases) & World Bank (population)   |   ",
      "Countries with 15+ years of reporting shown\n",
      "Visualization: BK Advisors \u2014 bk-advisors.github.io"
    )
  ) +
  theme_bka() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_blank(),
    axis.text.y = element_text(size = 9, face = "bold", family = "Lato", hjust = 1),
    axis.text.x = element_text(size = 8),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.title = element_text(size = 9, face = "bold",
                                color = bka_colors$title_dark),
    legend.text = element_text(size = 8, color = bka_colors$subtitle_gray),
    plot.title = element_text(lineheight = 1.15),
    plot.margin = margin(15, 15, 25, 15)
  )

dir.create("output", showWarnings = FALSE)

# ---- Save portrait version (4:5 ratio — best for LinkedIn image posts) ----
ggsave("output/africa-measles-heatmap.png", plot = p,
       width = 10, height = 12.5, dpi = 300, bg = "white")
cat("Saved: output/africa-measles-heatmap.png (3000 x 3750 px @ 300dpi)\n")

# ---- Save landscape version (1.91:1 ratio — best for LinkedIn link shares) ----
ggsave("output/africa-measles-heatmap-wide.png", plot = p,
       width = 12, height = 6.28, dpi = 300, bg = "white")
cat("Saved: output/africa-measles-heatmap-wide.png (3600 x 1884 px @ 300dpi)\n")

cat("\nDone! Two files ready for LinkedIn.\n")
