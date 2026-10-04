# The curvature concept figure (Figure 1 of Ospina, 2026)

A two-panel, fully synthetic illustration of the paper's diagnostic
layer: (a) how a treatment can separately move the boundary probability
and the continuous mean of an inflated beta response, and (b) the
likelihood-displacement curve \\F\\ along the treatment direction, whose
leading quadratic term at the factual world is the curvature
\\B\_{d_T}\\ of
[`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md).
Both panels use illustrative parameters chosen for legibility, not data
from the application; no arguments are needed to reproduce the figure
exactly as printed.

## Usage

``` r
plot_concept()
```

## Value

Invisibly `NULL`; called for its plotting side effect. Draws both panels
in the current graphics device (set `par(mfrow = c(1, 2))`, or open a
device of width-to-height ratio near 2:1, before calling, to match the
paper's layout).

## Examples

``` r
plot_concept()


```
