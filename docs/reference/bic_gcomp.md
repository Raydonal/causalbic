# G-computation decomposition of the average treatment effect

Estimates the average treatment effect and its exact decomposition into
a discrete-component contribution (through the boundary probabilities)
and a continuous-component contribution (through the conditional mean),
Proposition 2.3 (one boundary) / Proposition 2.4 (two boundaries) of
Ospina (2026). Identification rests on the ordinary potential-outcomes
assumptions (SUTVA, ignorability given the covariates in `fit`,
positivity); this function does not check them.

## Usage

``` r
bic_gcomp(fit, treat, data, weights = NULL)
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

- weights:

  Optional averaging weights (e.g. survey weights), normalized
  internally to sum to one. Defaults to equal weights.

## Value

A named numeric vector `c(tau, tau_alpha, tau_mu)`, with
`tau_alpha + tau_mu == tau` exactly (to floating-point precision).

## Examples

``` r
dat <- simulate_bic(400, seed = 1)
fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
#> GAMLSS-RS iteration 1: Global Deviance = 344.8954 
#> GAMLSS-RS iteration 2: Global Deviance = 295.9198 
#> GAMLSS-RS iteration 3: Global Deviance = 293.3736 
#> GAMLSS-RS iteration 4: Global Deviance = 293.3103 
#> GAMLSS-RS iteration 5: Global Deviance = 293.309 
#> GAMLSS-RS iteration 6: Global Deviance = 293.3089 
bic_gcomp(fit, "T", dat)
#>         tau   tau_alpha      tau_mu 
#>  0.04459171 -0.07564943  0.12024114 
attr(dat, "truth")
#> $tau
#> [1] 0.04490327
#> 
#> $tau_alpha
#> [1] -0.08649041
#> 
#> $tau_mu
#> [1] 0.1313937
#> 
```
