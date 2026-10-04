# Getting started with causalbic

``` r
library(causalbic)
```

## The model

`causalbic` is for a proportional outcome `y` in `[0, 1]` with a point
mass at a boundary (zero, one, or both), and a binary treatment that may
act two ways: by moving the probability of landing on the boundary, or
by shifting the mean of the cases that do not.
[`simulate_bic()`](https://raydonal.github.io/causalbic/reference/simulate_bic.md)
draws from such a model with a known, closed-form effect and its two
components, so the rest of this vignette can check the estimator against
ground truth.

``` r
set.seed(1)
dat <- simulate_bic(600)
head(dat)
#>           y T         W1         W2
#> 1 0.3652367 0 -0.6264538 -0.3410670
#> 2 0.0000000 1  0.1836433  1.5024245
#> 3 0.0000000 1 -0.8356286  0.5283077
#> 4 0.1161088 0  1.5952808  0.5421914
#> 5 0.6113145 1  0.3295078 -0.1366734
#> 6 0.4796077 0 -0.8204684 -1.1367339
attr(dat, "truth")
#> $tau
#> [1] 0.04582751
#> 
#> $tau_alpha
#> [1] -0.0863694
#> 
#> $tau_mu
#> [1] 0.1321969
```

## Fitting and the effect decomposition

[`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md)
fits the inflated beta regression
([`gamlss.dist::BEZI`](https://rdrr.io/pkg/gamlss.dist/man/BEZI.html)
for one boundary,
[`gamlss.dist::BEINF`](https://rdrr.io/pkg/gamlss.dist/man/BEINF.html)
for two, chosen automatically by whether `tau.formula` is supplied).
[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md)
then estimates the average treatment effect and decomposes it exactly
into a discrete-component part (through the boundary probability) and a
continuous-component part (through the conditional mean):

``` r
fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
#> GAMLSS-RS iteration 1: Global Deviance = 448.3807 
#> GAMLSS-RS iteration 2: Global Deviance = 371.5585 
#> GAMLSS-RS iteration 3: Global Deviance = 367.9107 
#> GAMLSS-RS iteration 4: Global Deviance = 367.8287 
#> GAMLSS-RS iteration 5: Global Deviance = 367.8272 
#> GAMLSS-RS iteration 6: Global Deviance = 367.8272
g <- bic_gcomp(fit, treat = "T", data = dat)
g
#>         tau   tau_alpha      tau_mu 
#>  0.06570652 -0.07816620  0.14387272
g["tau_alpha"] + g["tau_mu"] - g["tau"]  # exact identity
#> tau_alpha 
#>         0
```

The conditional effect at specific covariate profiles uses the same
decomposition,
[`bic_cate()`](https://raydonal.github.io/causalbic/reference/bic_cate.md):

``` r
profiles <- data.frame(W1 = c(-1, 0, 1), W2 = c(-1, 0, 1))
bic_cate(fit, "T", profiles)
#>          tau   tau_alpha    tau_mu
#> 1 0.09744089 -0.05018926 0.1476301
#> 2 0.07395980 -0.07729049 0.1512503
#> 3 0.02791105 -0.11223325 0.1401443
```

## Diagnostics: curvature, influence and sensitivity

[`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md)
builds the causal conformal normal curvature in the treatment direction
and splits it, additively and exactly, into the same two components:

``` r
cv <- bic_curvature(fit, "T", dat)
c(BdT = cv$BdT, discrete = cv$BdT_discrete, continuous = cv$BdT_continuous)
#>        BdT   discrete continuous 
#> 0.09381095 0.03428841 0.05952254
```

[`bic_icim()`](https://raydonal.github.io/causalbic/reference/bic_icim.md)
reads the per-unit diagonal of that curvature off to flag
disproportionately influential observations, and classify them by which
component they act through:

``` r
icim <- bic_icim(cv)
sum(icim$influential)
#> [1] 63
table(icim$type)
#> 
#> continuous   discrete 
#>        394        206
```

[`bic_sensitivity()`](https://raydonal.github.io/causalbic/reference/bic_sensitivity.md)
bounds how much an unmeasured confounder of a given strength could move
the estimate, and solves for the smallest confounding strength
`Gamma_star` that would be needed to erase the effect. This bound can
be, and on some data sets is, uninformative (`Gamma_star` close to 1 or
`NA`): it says what it says honestly rather than manufacturing
reassurance.

``` r
sens <- bic_sensitivity(cv, fit, "T", dat, tau_hat = g["tau"])
c(L1 = sens$L1, Gamma_star = sens$Gamma_star)
#>             L1 Gamma_star.tau 
#>       1.028062       1.136554
```

## Reference

Ospina, R. (2026). Causal inference for proportional outcomes via
likelihood displacement in inflated beta regression. Submitted to *The
Annals of Applied Statistics*.
