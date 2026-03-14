# =============================================================================
# theme_bka.R — BKA-branded ggplot2 theme for data visualization
# Source this file: source("../_common/theme_bka.R")
#
# Color system: Blended BKA palette
#   - Typography & structure: BK Advisors/Dalberg theme (navy, gray, Lato font)
#   - Data accents: Gavi Palette (6 vibrant, distinguishable accent colors)
#
# Dataviz principles applied throughout (see dataviz-principles.md):
#   - Tufte: maximize data-ink ratio
#   - Knaflic: strategic color, visual hierarchy, whitespace
#   - Few: readable typography, subdued gridlines
#   - Cairo: meaningful annotations, pre-attentive attributes
# =============================================================================

library(ggplot2)

# ---------------------------------------------------------------------------
# Color palette — BKA blended (BK Advisors structure + Gavi data accents)
# ---------------------------------------------------------------------------

bka_colors <- list(
  title_dark    = "#242852",    # BK Advisors navy — for titles, emphasis text

  subtitle_gray = "#606060",    # BK Advisors body text — for subtitles, axis labels
  header_green  = "#83BD00",    # Gavi Accent 1 lime green — primary brand accent
  border_light  = "#E8E8E8",    # Tufte: subtle gridlines that don't compete with data
  white         = "#FFFFFF",
  black         = "#000000"
)

# Knaflic: gray for non-focal data — use to de-emphasize context points
bka_gray_context <- "#B0B0B0"
bka_gray_light   <- "#D9D9D9"

# Investment tier colors — Cairo: semantic color (red = urgent → green = stable)
bka_tier_colors <- c(
  "IMMEDIATE" = "#F8D7DA",     # Light red tint
  "HIGH"      = "#FDE2CF",     # Light coral tint
  "MEDIUM"    = "#FEF3CD",     # Light amber tint
  "ONGOING"   = "#D4EDDA"      # Light green tint
)

bka_tier_text <- c(
  "IMMEDIATE" = "#E24A3F",     # Gavi Red
  "HIGH"      = "#FA7650",     # Gavi Coral Orange
  "MEDIUM"    = "#F8A623",     # Gavi Amber
  "ONGOING"   = "#3E9B6E"      # Gavi Forest Green
)

# Numeric tier mapping
bka_tier_fill <- c(
  "1" = "#F8D7DA", "2" = "#FDE2CF", "3" = "#FEF3CD", "4" = "#D4EDDA"
)
bka_tier_font <- c(
  "1" = "#E24A3F", "2" = "#FA7650", "3" = "#F8A623", "4" = "#3E9B6E"
)

# EmOC level colors — Cairo: semantic mapping to care intensity
bka_emoc_colors <- c(
  "BEmOC" = "#83BD00",         # Gavi Lime Green — basic
  "SEmOC" = "#FA7650",         # Gavi Coral Orange — signal/intermediate
  "CEmOC" = "#005CB9"          # Gavi Dark Blue — comprehensive
)

# Facility type colors
bka_facility_colors <- c(
  "Health Center"     = "#83BD00",   # Gavi Lime Green
  "Primary Hospital"  = "#FA7650",   # Gavi Coral Orange
  "General Hospital"  = "#005CB9"    # Gavi Dark Blue
)

# Region palette (8 distinct colors — Cairo: maximize perceptual distance)
bka_region_colors <- c(
  "Addis Ababa" = "#005CB9",    # Dark Blue
  "Amhara"      = "#83BD00",    # Lime Green
  "Oromia"      = "#E24A3F",    # Red
  "SNNPR"       = "#FA7650",    # Coral Orange
  "Tigray"      = "#242852",    # Deep Navy
  "Sidama"      = "#3E9B6E",    # Forest Green
  "Harari"      = "#F8A623",    # Amber
  "Dire Dawa"   = "#00A1DF"     # Sky Blue
)

# Sequential palette — for continuous data (light → dark progression)
bka_sequential <- c("#ACCBF9", "#005CB9", "#242852")

# Diverging palette — for above/below target (red → white → green)
bka_diverging <- c("#E24A3F", "#F8D7DA", "#FFFFFF", "#D4EDDA", "#3E9B6E")

# Health financing source colors
bka_source_colors <- c(
  "Government"    = "#005CB9",   # Dark Blue — institutional
  "Donor"         = "#83BD00",   # Lime Green — external support
  "Out-of-Pocket" = "#E24A3F"    # Red — burden signal
)

# Country colors (East Africa)
bka_country_colors <- c(
  "Ethiopia" = "#005CB9",
  "Tanzania" = "#83BD00",
  "Kenya"    = "#E24A3F",
  "Rwanda"   = "#FA7650",
  "Uganda"   = "#242852"
)

# ---------------------------------------------------------------------------
# Custom theme: theme_bka()
# Knaflic: visual hierarchy — title dominates, data is prominent, chrome is quiet
# Tufte: maximize data-ink ratio — subtle gridlines, no ticks, clean whitespace
# Few: readable at print size — 10pt+ text, wider-than-taller default
# ---------------------------------------------------------------------------

theme_bka <- function(base_size = 12, base_family = "Lato") {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # Titles — Knaflic: visual hierarchy, title is the primary entry point
      plot.title = element_text(
        color = bka_colors$title_dark,
        size = rel(1.4),                 # Knaflic: title dominates the hierarchy
        face = "bold",
        hjust = 0,
        lineheight = 1.15,              # Knaflic: breathing room for multi-line titles
        margin = margin(b = 6)          # Tufte: separation between title and subtitle
      ),
      plot.subtitle = element_text(
        color = bka_colors$subtitle_gray,
        size = rel(0.95),
        hjust = 0,
        lineheight = 1.15,              # Few: consistent line spacing throughout
        margin = margin(t = 2, b = 14)  # Knaflic: breathing room below subtitle
      ),
      plot.caption = element_text(
        color = bka_colors$subtitle_gray,
        size = rel(0.75),
        hjust = 1,
        margin = margin(t = 10)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",

      # Axes — Few: readable at report-print size (~10pt minimum)
      axis.title = element_text(
        color = bka_colors$subtitle_gray,
        size = rel(0.85)
      ),
      axis.title.x = element_text(
        margin = margin(t = 8)           # Knaflic: whitespace between axis text and title
      ),
      axis.title.y = element_text(
        margin = margin(r = 8)           # Knaflic: whitespace between axis text and title
      ),
      axis.text = element_text(
        color = bka_colors$subtitle_gray,
        size = rel(0.85)                 # Few: bumped from 0.8 for readability
      ),
      axis.line = element_line(
        color = bka_colors$border_light,
        linewidth = 0.5
      ),
      axis.ticks = element_blank(),      # Tufte: remove non-data ink

      # Grid — Tufte: maximize data-ink ratio
      # Most charts read left-to-right, so only horizontal gridlines aid value reading
      panel.grid.major.y = element_line(
        color = bka_colors$border_light,
        linewidth = 0.25                 # Tufte: thinner = less visual noise
      ),
      panel.grid.major.x = element_blank(),  # Few: vertical gridlines rarely needed
      panel.grid.minor = element_blank(),

      # Legend — Tufte: reduce non-data-ink in legend area
      legend.position = "top",
      legend.justification = "left",
      legend.title = element_text(
        color = bka_colors$title_dark,
        size = rel(0.85),
        face = "bold"
      ),
      legend.text = element_text(
        color = bka_colors$subtitle_gray,
        size = rel(0.85)                 # Few: matched to axis.text for consistency
      ),
      legend.key = element_rect(fill = "transparent", color = NA),  # Tufte: no background boxes
      legend.key.spacing.x = unit(6, "pt"),  # Few: prevent legend items from blurring together
      legend.margin = margin(b = 4),

      # Facet strips — Few: strip labels must orient the reader
      strip.text = element_text(
        face = "bold",
        color = bka_colors$title_dark,
        size = rel(0.9),
        margin = margin(t = 4, b = 4)
      ),
      strip.background = element_rect(
        fill = "#F5F5F5",               # Subtle container, not white
        color = NA
      ),

      # Panel — Knaflic: white space reduces cognitive load
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(20, 20, 15, 15)  # Knaflic: more breathing room top & right
    )
}

# ---------------------------------------------------------------------------
# Scale convenience functions
# ---------------------------------------------------------------------------

scale_fill_bka <- function(palette = "facility", ...) {
  pal <- switch(palette,
    "facility" = bka_facility_colors,
    "tier"     = bka_tier_colors,
    "emoc"     = bka_emoc_colors,
    "region"   = bka_region_colors,
    "source"   = bka_source_colors,
    "country"  = bka_country_colors,
    bka_facility_colors
  )
  scale_fill_manual(values = pal, ...)
}

scale_color_bka <- function(palette = "facility", ...) {
  pal <- switch(palette,
    "facility" = bka_facility_colors,
    "tier"     = bka_tier_text,
    "emoc"     = bka_emoc_colors,
    "region"   = bka_region_colors,
    "source"   = bka_source_colors,
    "country"  = bka_country_colors,
    bka_facility_colors
  )
  scale_color_manual(values = pal, ...)
}
