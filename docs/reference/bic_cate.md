# Conditional average treatment effect at covariate profiles

The same decomposition as
[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md),
evaluated at specific covariate profiles (Definition 4.3 of Ospina,
2026) instead of averaged over a sample.

## Usage

``` r
bic_cate(fit, treat, profiles)
```

## Arguments

- fit:

  A fitted model from
  [`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md).

- treat:

  Character, the name of the treatment variable.

- profiles:

  A data frame of covariate profiles (one row per profile), with all
  covariates used by `fit` except `treat`.

## Value

A data frame with one row per profile and columns `tau`, `tau_alpha`,
`tau_mu`.
