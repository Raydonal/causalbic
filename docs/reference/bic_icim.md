# Individual Causal Influence Measure (ICIM)

The per-unit diagonal of the causal curvature of
[`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md)
(Definition 5.1 of Ospina, 2026), split by whether each unit's influence
runs mainly through the discrete or the continuous component (Definition
5.2), and screened for disproportionate influence by the
`2 * mean(ICIM)` rule.

## Usage

``` r
bic_icim(cv)
```

## Arguments

- cv:

  A `"bic_curvature"` object from
  [`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md).

## Value

A data frame with one row per unit and columns `ICIM`, `ICIM_discrete`,
`ICIM_continuous`, `type` (`"discrete"`/`"continuous"`/`"mixed"`) and
`influential` (logical, `ICIM > 2 * mean(ICIM)`).

## Details

`influential = TRUE` flags a unit whose leverage on the fitted model is
more than twice the sample's typical leverage, a screening rule in the
spirit of the `2 * mean(hat value)` rule for leverage in linear models.
It is **not** a claim that the unit has an unusually large individual
treatment effect, and a flagged unit can have a small or even near-zero
estimated effect; leverage and effect size answer different questions.
`type` says which component a flagged unit's leverage runs through,
which is useful for tracing an unexpected curvature share back to
specific observations (e.g. a handful of households with extreme
covariate profiles on the boundary side) rather than treating the
curvature as an unexplained aggregate number.
