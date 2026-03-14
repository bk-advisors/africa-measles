# Data Visualization Principles — Expert Reference Guide

A synthesis of actionable principles from five leading data visualization experts, organized by category. Each principle includes the expert attribution and how it translates to ggplot2 code.

---

## 1. Data-Ink Ratio

> "Above all else show the data." — Edward Tufte

**Tufte** (*The Visual Display of Quantitative Information*): Maximize the proportion of ink devoted to non-redundant data display. Erase non-data-ink and redundant data-ink ruthlessly. Revise and edit iteratively.

**Few** (*Show Me the Numbers*): Reduce non-data ink; enhance the data ink. Keep gridlines visually subdued. White background for data objects.

### ggplot2 translation
- Remove vertical gridlines when charts read left-to-right: `panel.grid.major.x = element_blank()`
- Use subtle, thin horizontal gridlines: `panel.grid.major.y = element_line(color = "#E8E8E8", linewidth = 0.25)`
- Remove minor gridlines: `panel.grid.minor = element_blank()`
- Remove axis ticks: `axis.ticks = element_blank()`
- Use filled shapes without borders: `geom_point(shape = 16, stroke = 0)`
- Remove legend key backgrounds: `legend.key = element_rect(fill = "transparent", color = NA)`
- Remove all gridlines from heatmaps: `panel.grid = element_blank()`

---

## 2. Typography Hierarchy

> "Clutter is a property of design, not data." — Edward Tufte

**Knaflic** (*Storytelling with Data*): Structure so the most important information stands out immediately. Title should dominate visually. Use a clear hierarchy: title → subtitle → data → axis labels.

**Wong** (*WSJ Guide to Information Graphics*): Rich content with inviting visualization. Three essential elements: rich content, inviting visualization, sophisticated execution.

### Hierarchy (largest to smallest)
| Element | Purpose | Styling |
|---------|---------|---------|
| Title | States the insight (Minto) | 14pt+, bold, dark color |
| Subtitle | Provides context | 12pt, regular, gray |
| Axis titles | Label dimensions | 10pt, regular, gray |
| Axis text | Tick labels | 10pt, regular, gray |
| Annotations | Contextual callouts | 10-11pt, italic or bold |
| Caption | Source/notes | 9pt, regular, light gray |

### ggplot2 translation
- Title: `element_text(size = rel(1.4), face = "bold", lineheight = 1.15)`
- Subtitle: `element_text(size = rel(0.95), lineheight = 1.15)`
- Multi-line titles need `lineheight` to prevent compression
- With ggtext: `element_markdown()` for colored/bolded text in titles

---

## 3. Strategic Color Use

> "Use color only when it serves a purpose." — Cole Nussbaumer Knaflic

**Knaflic** (*Storytelling with Data*): Use color sparingly and deliberately — 1-2 emphasis colors maximum per chart. Gray out non-focal data. Color should emphasize key takeaways, not decorate.

**Cairo** (*The Truthful Art*): Pre-attentive color pop-out — a single different-colored element immediately draws attention. Use semantic colors (red = urgent, green = stable).

**Few** (*Show Me the Numbers*): Color hue for categorical distinction. Color intensity for quantitative encoding. De-emphasize non-focal data with lower opacity.

### ggplot2 translation
- Gray out context data: `geom_point(color = "#B0B0B0", alpha = 0.3)`
- Focal data in accent color: `geom_point(color = "#E24A3F")`
- Semantic color palettes: `scale_color_manual(values = c("urgent" = "#E24A3F", "stable" = "#3E9B6E"))`
- Reduced alpha for density: `geom_point(alpha = 0.5)`
- Legend keys match plot: `guides(color = guide_legend(override.aes = list(size = 4, alpha = 1)))`

---

## 4. Whitespace & Breathing Room

> "White space reduces cognitive load." — Cole Nussbaumer Knaflic

**Knaflic** (*Storytelling with Data*): Strategic white space and contrast highlight what matters and guide viewer attention. Proximity groups related information (Gestalt principle).

**Tufte** (*Envisioning Information*): Avoid the "1+1=3" visual clutter effect where elements placed too close together create unintended visual noise.

**Few** (*Show Me the Numbers*): Make graphs wider than taller. Group data into logical sections.

### ggplot2 translation
- Axis breathing room: `scale_x_continuous(expand = expansion(mult = c(0.02, 0.05)))`
- Bar spacing: `geom_col(width = 0.7)`
- Plot margins: `plot.margin = margin(20, 20, 15, 15)`
- Title-subtitle separation: `margin(b = 6)` on title, `margin(t = 2, b = 14)` on subtitle
- Axis title spacing: `axis.title.x = element_text(margin = margin(t = 8))`
- Wider-than-taller aspect ratio: `fig.width = 8, fig.height = 5` (1.6:1)

---

## 5. Bar Chart Design

> "Bars must start at zero — truncated bars distort perception." — Stephen Few

**Tufte** (*The Visual Display of Quantitative Information*): White space between bars improves readability.

**Few** (*Show Me the Numbers*): Include zero baseline for meaningful comparisons. Bars anchored at zero prevent misinterpretation.

### ggplot2 translation
- Anchor bars at zero: `scale_y_continuous(expand = expansion(mult = c(0, 0.05)))`
- Bar spacing: `geom_col(width = 0.7)`
- Horizontal bars for long labels: `coord_flip()`
- Swap gridlines for flipped bars: `theme(panel.grid.major.x = element_line(...), panel.grid.major.y = element_blank())`

---

## 6. Legends vs. Direct Labeling

> "Direct labeling eliminates the cognitive load of cross-referencing." — Cole Nussbaumer Knaflic

**Knaflic** (*Storytelling with Data*): Default to direct labeling. Legends force the reader to look back and forth. Only use legends when direct labeling creates clutter.

**Cairo** (*The Truthful Art*): Good graphics require strong titles, introductions, and explanatory text — visualization alone is insufficient.

### When to use which
| Technique | Use When | ggplot2 |
|-----------|----------|---------|
| Direct labels | ≤5 categories, line endpoints, bar values | `geom_text()`, `geom_label_repel()` |
| Legend-in-title | Color maps to 2-3 categories | `ggtext::element_markdown()` in title |
| Traditional legend | >5 categories, complex multi-aesthetic charts | `guide_legend(override.aes = ...)` |

### ggplot2 translation
- Endpoint labels: `geom_text(data = endpoints, aes(label = category), hjust = 0)`
- Allow labels outside plot: `coord_cartesian(clip = "off")`
- Remove legend after direct labeling: `theme(legend.position = "none")`
- Smart anti-overlap labels: `ggrepel::geom_label_repel(max.overlaps = 15)`

---

## 7. Annotations & Reference Lines

> "Annotations are essential, not optional — they tell the reader WHERE to look." — Alberto Cairo

**Cairo** (*The Truthful Art*): "Subtract the obvious, add the meaningful." Remove irrelevant elements while bringing in essential details.

**Few** (*Show Me the Numbers*): Reference lines provide context without cluttering. Highlight deviations, outliers, and benchmarks.

**Tufte** (*Envisioning Information*): Graphs should answer viewers' questions within the visualization itself. Include units, baselines, benchmarks.

### ggplot2 translation
- Reference line: `geom_hline(yintercept = target, linetype = "dashed", linewidth = 0.5)`
- Reference label: `annotate("text", x = ..., y = ..., label = "WHO target", fontface = "italic", size = 3)`
- Shaded zone: `annotate("rect", xmin = ..., xmax = ..., fill = "#E24A3F", alpha = 0.15)`
- Arrow callout: `geom_segment(arrow = arrow(length = unit(0.2, "cm")))`
- Conditional labeling (only outliers): `geom_label_repel(data = df %>% filter(show_label), ...)`

---

## 8. Pre-Attentive Attributes

> "Perception is selective — interesting data must contrast with the norm." — Stephen Few

**Few** (*Show Me the Numbers*): Pre-attentive attributes are processed before conscious attention. Use them strategically:

| Attribute | Best For | Power |
|-----------|----------|-------|
| **Position** (x, y) | Primary encoding | Highest accuracy |
| **Length** | Comparing quantities | Very high |
| **Color hue** | Categorical distinction | High pop-out |
| **Color intensity** | Quantitative encoding | Medium |
| **Size** | Relative importance | Medium |
| **Shape** | Secondary category | Low (don't overuse) |
| **Opacity** | De-emphasis | Best for non-focal data |

**Cairo** (*The Functional Art*): Leverage Cleveland & McGill's hierarchy — position and length are perceived most accurately; area and volume are least accurate.

### ggplot2 translation
- Color for primary focus: `aes(color = focal_variable)`
- Size for secondary importance: `aes(size = secondary_variable)`
- Shape for tertiary category only: `aes(shape = category)` (max 3-4 shapes)
- Opacity to de-emphasize: `alpha = 0.3` for background, `alpha = 0.8` for focus
- Override in legend: `override.aes = list(size = 4, alpha = 1)` (so legend is clear)

---

## 9. Truthfulness & Integrity

> "Charts lie when based on unreliable data or poor design choices." — Alberto Cairo

**Cairo** (*How Charts Lie*): Five qualities — visualizations must be truthful, functional, beautiful, insightful, and enlightening. Identify deception sources: wrong data, inappropriate volume, concealed uncertainty, misleading patterns, axis manipulation.

**Tufte** (*The Visual Display of Quantitative Information*): Include zero baselines where meaningful. Maintain consistent axis scales when comparing panels. Show uncertainty when it exists.

### ggplot2 translation
- Consistent scales in facets: `facet_wrap(scales = "fixed")` (default)
- Free scales only when ranges differ dramatically: `facet_wrap(scales = "free_y")`
- Show confidence intervals: `geom_smooth(se = TRUE)`
- Don't truncate bar chart axes (always include zero)

---

## 10. Small Multiples

> "Small multiples are the best design solution for a wide range of problems." — Edward Tufte

**Tufte** (*Envisioning Information*): Small multiples reveal patterns invisible in single crowded charts. Same design structure repeated across panels enables rapid comparison.

### ggplot2 translation
- Single-variable split: `facet_wrap(~ variable, ncol = 3)`
- Two-variable matrix: `facet_grid(rows ~ cols)`
- Styled strip labels: `strip.text = element_text(face = "bold", size = rel(0.9))`
- Hierarchical nesting: `ggh4x::facet_nested()`

---

## Quick Reference: Comment Templates

Use these inline comments when applying principles in code:

```r
# Tufte: maximize data-ink ratio — remove non-data ink
# Tufte: filled shapes without borders = less non-data ink per point
# Tufte: white space between bars improves readability
# Tufte: small multiples reveal patterns invisible in single crowded charts
# Knaflic: strategic color — only focal data is saturated
# Knaflic: gray out non-focal data to reduce cognitive load
# Knaflic: direct labeling eliminates legend lookup
# Knaflic: override.aes ensures legend keys are readable despite plot transparency
# Knaflic: white space reduces cognitive load
# Knaflic: visual hierarchy — title is the primary entry point
# Cairo: "subtract the obvious, add the meaningful"
# Cairo: pre-attentive color pop-out — accent draws attention
# Cairo: annotations are essential, not optional
# Cairo: semantic color — red = urgent, green = stable
# Few: bars must start at zero — truncated bars distort perception
# Few: de-emphasize non-focal data with transparency
# Few: data lines should be more prominent than gridlines
# Few: reference lines provide context without cluttering
# Few: facet strip labels orient the reader
# Wong: simplicity — filter data for audience understanding
```

---

## Sources

- Alberto Cairo, *The Truthful Art* (2016)
- Alberto Cairo, *How Charts Lie* (2019)
- Alberto Cairo, *The Functional Art* (2012)
- Edward Tufte, *The Visual Display of Quantitative Information* (2001, 2nd ed.)
- Edward Tufte, *Envisioning Information* (1990)
- Cole Nussbaumer Knaflic, *Storytelling with Data* (2015)
- Dona Wong, *The Wall Street Journal Guide to Information Graphics* (2010)
- Stephen Few, *Show Me the Numbers* (2012, 2nd ed.)
- Stephen Few, *Now You See It* (2009)
