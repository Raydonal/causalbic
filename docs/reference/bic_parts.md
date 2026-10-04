# Fitted BIc component parts under a counterfactual treatment value

Evaluates the fitted inflation probability/probabilities and continuous
mean of a
[`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md)
object with the treatment variable set to a fixed counterfactual value
`a` for every row of `newdata`, using the fitted coefficients and the
model's own design matrices directly (not
`predict.gamlss(..., newdata=)`, which re-resolves its stored `data`
argument by name in the calling frame and silently returns the wrong
frame when the fit was produced inside a function; see Ospina (2026),
Section 4).

## Usage

``` r
bic_parts(fit, treat, newdata, a)
```

## Arguments

- fit:

  A fitted model from
  [`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md).

- treat:

  Character, the name of the treatment variable in `newdata`.

- newdata:

  A data frame with `treat` and all other covariates used by `fit`.

- a:

  The counterfactual value to substitute for `treat` (`0` or `1`).

## Value

A list with `mu` (continuous mean), `p0` (probability of the lower
boundary) and, for two-boundary fits, `p1` (probability of the upper
boundary), and `EY`, the mixture mean \\p_1 + (1 - p_0 - p_1)\mu\\.
