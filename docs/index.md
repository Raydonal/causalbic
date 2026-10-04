# causalbic

Causal inference for proportional outcomes with a point mass at a
boundary (zero, one, or both), via the zero-or-one inflated beta (BIc)
regression of Ospina and Ferrari (2012). `causalbic` estimates the
average and conditional treatment effect by g-computation and decomposes
it **exactly** into a discrete-component contribution (through the
boundary probabilities) and a continuous-component contribution (through
the conditional mean), a consequence of the block-diagonal Fisher
information of the BIc likelihood. A diagnostic layer built on the same
separability adds a causal conformal normal curvature with the same
additive decomposition, a per-unit causal influence screen, and a
Hölder-duality sensitivity bound for unmeasured confounding.

Companion package to Ospina (2026), *Causal inference for proportional
outcomes via likelihood displacement in inflated beta regression*,
submitted to *The Annals of Applied Statistics*. This repository is the
package only; it does not include the manuscript or the scripts that
reproduce its simulation and application.

## Installation

``` r
# install.packages("pak")
pak::pak("Raydonal/causalbic")
```

## Example

``` r
library(causalbic)

set.seed(1)
dat <- simulate_bic(600)
fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
#> GAMLSS-RS iteration 1: Global Deviance = 448.3807 
#> GAMLSS-RS iteration 2: Global Deviance = 371.5585 
#> GAMLSS-RS iteration 3: Global Deviance = 367.9107 
#> GAMLSS-RS iteration 4: Global Deviance = 367.8287 
#> GAMLSS-RS iteration 5: Global Deviance = 367.8272 
#> GAMLSS-RS iteration 6: Global Deviance = 367.8272

bic_gcomp(fit, treat = "T", data = dat)
#>         tau   tau_alpha      tau_mu 
#>  0.06570652 -0.07816620  0.14387272
```

The decomposition is exact, not approximate:

``` r
g <- bic_gcomp(fit, "T", dat)
g["tau_alpha"] + g["tau_mu"] - g["tau"]
#> tau_alpha 
#>         0
```

See
[`vignette("causalbic")`](https://raydonal.github.io/causalbic/articles/causalbic.md)
for the diagnostic layer (curvature, per-unit influence, sensitivity to
unmeasured confounding).

## Reference

Ospina, R. and Ferrari, S. L. P. (2012). A general class of zero-or-one
inflated beta regression models. *Computational Statistics & Data
Analysis*, 56, 1609-1623.
