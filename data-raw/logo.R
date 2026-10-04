## Generates man/figures/logo.png, the source for the pkgdown favicons
## (pkgdown::build_favicons()). Visual motif matches Figure 2(c) of the
## paper: a sum of two non-negative scalar parts, drawn as a split bar
## inside the hex, rather than a vector/Euclidean device.
library(hexSticker)

subplot <- function() {
  grid::grid.newpage()
  grid::grid.roundrect(x = 0.5, y = 0.52, width = 0.74, height = 0.26,
                        r = grid::unit(0.03, "npc"),
                        gp = grid::gpar(fill = "grey92", col = "white", lwd = 2))
  grid::grid.rect(x = 0.5 - 0.37 + 0.74 * 0.62 / 2, y = 0.52,
                   width = 0.74 * 0.62, height = 0.26,
                   just = "center",
                   gp = grid::gpar(fill = "#2c3e82", col = "white", lwd = 2))
  grid::grid.rect(x = 0.5 - 0.37 + 0.74 * 0.62 + 0.74 * 0.38 / 2, y = 0.52,
                   width = 0.74 * 0.38, height = 0.26,
                   just = "center",
                   gp = grid::gpar(fill = "#d94f4f", col = "white", lwd = 2))
}

sticker(
  subplot = ~ subplot(), s_x = 1, s_y = 1, s_width = 2.2, s_height = 2.2,
  package = "causalbic", p_size = 20, p_y = 1.48, p_color = "#1a1a2e",
  h_fill = "#f5f6fa", h_color = "#2c3e82",
  filename = "man/figures/logo.png", dpi = 300
)
