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
