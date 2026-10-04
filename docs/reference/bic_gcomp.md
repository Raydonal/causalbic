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

## Details

Reading the three numbers: `tau` is the total change in the mean
response caused by treatment. `tau_alpha` is the part of that change
coming from treatment moving units onto or off the boundary (a change in
how many units attain the inflated value); `tau_mu` is the part coming
from treatment shifting the conditional mean among units that remain in
the interior. They can have the same sign (both mechanisms reinforcing)
or opposite signs (one mechanism offsetting the other, so that `tau`
alone understates how much is actually happening); only the three-number
decomposition distinguishes these cases, since `tau` by itself looks the
same either way when the components happen to be small, and looks
deceptively modest when they are large and opposed.

## Examples

``` r
dat <- simulate_bic(400, seed = 1)
fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
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
