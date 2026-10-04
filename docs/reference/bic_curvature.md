# Causal conformal normal curvature (CCNC) and its block decomposition

Builds the causal Delta matrix (Theorem 3.2 of Ospina, 2026) by moving
each unit's *observed* response between its two potential-outcome
log-densities, and from it the conformal normal curvature in the
treatment direction, `B_dT`, and its exact additive split into a
discrete-component part and a continuous-component part (Theorem 3.5),
which holds because the Fisher information of the BIc model is block
diagonal (Lemma 2.1). The observed information is a numerical Hessian of
the fitted log-likelihood, the same construction used for the real-data
results in Ospina (2026), Section 8, so this does not depend on a
closed-form score for a particular link function.

## Usage

``` r
bic_curvature(fit, treat, data, eps = 1e-04)
```

## Arguments

- fit:

  A fitted model from
  [`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md).

- treat:

  Character, the name of the treatment variable.

- data:

  The data frame the effect is averaged over (by default, the data `fit`
  was fitted on).

- eps:

  Step size passed to
  [`numDeriv::jacobian()`](https://rdrr.io/pkg/numDeriv/man/jacobian.html)
  /
  [`numDeriv::hessian()`](https://rdrr.io/pkg/numDeriv/man/hessian.html)
  for the numerical derivatives.

## Value

A list of class `"bic_curvature"` with elements `BdT` (the scalar
curvature), `BdT_discrete`, `BdT_continuous` (its two components,
summing to `BdT`), `Delta` (the `p x n` causal Delta matrix), `Iinv`
(the `p x p` inverse observed information), `cross_term` (the
numerically-vanishing cross term between the two blocks, a diagnostic
for Lemma 2.1 holding on this fit), and `trm` (internal design/index
information reused by
[`bic_icim()`](https://raydonal.github.io/causalbic/reference/bic_icim.md)
and
[`bic_sensitivity()`](https://raydonal.github.io/causalbic/reference/bic_sensitivity.md)).

## Details

This answers a different question from
[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md).
[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md)
says how big the effect is and through which component; `BdT` says how
much the *fitted model itself* depends on the treatment assignment of
the sample at hand, a sensitivity/leverage reading, not an effect size,
and in particular not something that should be expected to equal, or
even track closely, the share each component contributes to `tau` (one
is a share of an average effect, the other a share of a curvature). A
large gap between the two shares is itself informative: it can mean a
submodel affects the curvature, e.g. through a treatment effect on
precision, without affecting `tau` at all, since the mixture mean does
not depend on precision.

## Examples

``` r
dat <- simulate_bic(400, seed = 1)
fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
cv <- bic_curvature(fit, "T", dat)
cv$BdT; cv$BdT_discrete + cv$BdT_continuous  # match cv$BdT
#> [1] 0.08341132
#> [1] 0.08341132
```
