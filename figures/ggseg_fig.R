# Load libraries ----------------------------------------------------------

library(readr)
library(ggplot2)
library(ggseg)
library(viridis) # for nice continuous scales

# Load example data -------------------------------------------------------

ggseg_dat <- read_csv("data/ggseg_dat.csv")


# Plot data ---------------------------------------------------------------


dk_plot <- ggseg(
  .data = ggseg_dat, atlas="dk",
  # outline color
  colour = "black", # size = 0.7,
  mapping = aes(fill = beta), # can also plot p.value, t-statistic, etc
  # position, stacked or dispersed
  position = "stacked") +
  # can use pre-defined color schemes
  scale_fill_viridis(na.value = "grey85") + 
  # can also use your own colours
  # scale_fill_continuous(
  # type = "gradient", na.value="grey85", # or can make "transparent"
  # low = "#48cae4", high = "#caf0f8") +
  theme_minimal() +
  # theme_void() +  # to remove elements
  theme(legend.position = "right")

dk_plot


# Save plot ---------------------------------------------------------------

ggsave(
  filename = "figures/age_dk_brain_plot.png",
  plot = dk_plot,
  width = 6, height = 5.5, units = "in",
  dpi = 500,
  limitsize = TRUE
)