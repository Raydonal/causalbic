# Simulate data from a causal zero-inflated beta (BIc) model

Draws potential outcomes from a one-boundary inflated beta regression
([`gamlss.dist::BEZI`](https://rdrr.io/pkg/gamlss.dist/man/BEZI.html),
inflation at zero) with a confounded treatment assignment, the
data-generating process used in the simulation study of Ospina (2026).
Useful for testing
[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md),
[`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md)
and friends against a model where the true average treatment effect and
its discrete/continuous components are known in closed form.

## Usage

``` r
simulate_bic(
  n,
  gamma = c(-1.5, 0.3, 1.5),
  beta = c(-1, 0.5, 1.2),
  phi = 4,
  rho = 0.4,
  seed = NULL
)
```

## Arguments

- n:

  Sample size.

- gamma:

  Numeric length-3 vector `(gamma0, gamma1, gammaT)`, the
  inflation-probability (logit) linear predictor coefficients for
  intercept, covariate `W1` and treatment.

- beta:

  Numeric length-3 vector `(beta0, beta1, betaT)`, the continuous-mean
  (logit) linear predictor coefficients for intercept, covariate `W2`
  and treatment.

- phi:

  Precision of the continuous beta component (constant).

- rho:

  Confounding strength: treatment is drawn with probability
  `plogis(rho * (W1 + W2))`, so `rho = 0` is a randomized experiment and
  `rho > 0` confounds treatment with the covariates that also drive the
  outcome.

- seed:

  Optional seed for reproducibility.

## Value

A `data.frame` with columns `y` (observed response), `T` (treatment),
`W1`, `W2` (covariates), and attributes `"truth"` (a list with the
population `tau`, `tau_alpha`, `tau_mu`) and `"params"` (the generating
coefficients).

## Examples

``` r
dat <- simulate_bic(500, seed = 1)
attr(dat, "truth")
#> $tau
#> [1] 0.04573403
#> 
#> $tau_alpha
#> [1] -0.08662263
#> 
#> $tau_mu
#> [1] 0.1323567
#> 
```
