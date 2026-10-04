# Fit a BIc (zero-or-one inflated beta) regression

Thin wrapper around
[`gamlss::gamlss()`](https://rdrr.io/pkg/gamlss/man/gamlss.html) for the
inflated beta regression of Ospina and Ferrari (2012), fitting the three
(or four, for two-boundary responses) linked submodels of Eq. (1) in
Ospina (2026): a discrete inflation-probability submodel and a
continuous-mean submodel, optionally with their own precision submodel.

## Usage

``` r
bic_fit(
  formula,
  sigma.formula = ~1,
  nu.formula = ~1,
  tau.formula = NULL,
  data,
  weights = NULL,
  ...
)
```

## Arguments

- formula:

  Formula for the continuous-mean submodel (`mu`), e.g.
  `y ~ T + x1 + x2`.

- sigma.formula:

  Formula for the precision submodel (default `~1`, constant precision).

- nu.formula:

  Formula for the inflation-at-zero submodel.

- tau.formula:

  Formula for the inflation-at-one submodel. Leave `NULL` for a
  one-boundary (inflation at zero only) response, fit with
  [`gamlss.dist::BEZI`](https://rdrr.io/pkg/gamlss.dist/man/BEZI.html);
  supply it for a two-boundary response, fit with
  [`gamlss.dist::BEINF`](https://rdrr.io/pkg/gamlss.dist/man/BEINF.html).

- data:

  A data frame.

- weights:

  Optional prior weights (e.g. survey expansion weights), passed to
  `gamlss`.

- ...:

  Further arguments passed to
  [`gamlss::gamlss()`](https://rdrr.io/pkg/gamlss/man/gamlss.html).

## Value

A fitted `gamlss` object, as returned by
[`gamlss::gamlss()`](https://rdrr.io/pkg/gamlss/man/gamlss.html), with
its family (`"BEZI"` or `"BEINF"`) recorded for use by
[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md)
and
[`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md).

## References

Ospina, R. and Ferrari, S. L. P. (2012). A general class of zero-or-one
inflated beta regression models. *Computational Statistics & Data
Analysis*, 56, 1609-1623.
