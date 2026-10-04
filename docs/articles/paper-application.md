# Reproducing the application (Ospina, 2026)

Section 8 of Ospina (2026) applies the framework to the Brazilian
Household Budget Survey 2017-2018 (POF), on the effect of the *Bolsa
Família* cash transfer on the share of food expenditure made away from
home. This vignette gives the exact code for that application. **The
code chunks below do not run when this vignette is built**: the POF
microdata are public but too large (hundreds of megabytes) to ship with
this package, and downloading them is not something a package build
should do unattended. Every number quoted here is the real output of
this exact code, reproduced independently from the cached model fit as
part of the package’s own development checks; none is invented for this
document.

## Getting the data

Microdata:
<https://ftp.ibge.gov.br/Orcamentos_Familiares/Pesquisa_de_Orcamentos_Familiares_2017_2018/Microdados/>.
The files used are `CADERNETA_COLETIVA.txt`, `DESPESA_INDIVIDUAL.txt`,
`OUTROS_RENDIMENTOS.txt` and `MORADOR.txt`, read in fixed-width format
using the layout dictionary published alongside the microdata, and
assembled into one household-level data frame `dat` with columns `p`
(the response share), `T` (receipt of *Bolsa Família*, income-module
codes `5400101`/`5400102`), `linc` (log household income), `n_res`,
`n_child`, `educ`, `age`, `region`, and the survey design variables
(`upa`, `estrato`, `w`). The data-assembly code is not part of this
package; see the paper’s reproducibility repository.

## Fitting

The response is inflated at both boundaries (zero and one), so the fit
uses all four BIc submodels
([`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md)
dispatches to
[`gamlss.dist::BEINF`](https://rdrr.io/pkg/gamlss.dist/man/BEINF.html)
automatically because `tau.formula` is supplied). The specification
below is the one Section 8.2 of the paper justifies by likelihood-ratio
tests, not an arbitrary choice: a treatment-by-log-income interaction in
the mean and inflation-at-zero submodels, and treatment, household size
and schooling in the precision submodel.

``` r
library(causalbic)

fit <- bic_fit(
  p ~ T * linc + n_res + n_child + educ + age + region,
  sigma.formula = ~ T + n_res + educ,
  nu.formula    = ~ T * linc + n_res + n_child + educ,
  tau.formula   = ~ T + linc + n_res + n_child + educ,
  data = dat, weights = dat$w
)
```

## The effect and its decomposition

``` r
g <- bic_gcomp(fit, "T", dat, weights = dat$w)
g
#>        tau   tau_alpha      tau_mu
#> 0.05906962  0.03353953  0.02553009
```

**What this says substantively.** Receiving *Bolsa Família* raises the
share of food spending made away from home by 5.9 percentage points on
average (`tau`), after standardizing over the covariate distribution;
the raw, unadjusted contrast between recipients and non-recipients is
*negative* (recipients spend a smaller raw share away from home),
because recipients are poorer and income is the dominant predictor of
eating out, so adjustment reverses the sign. Of that 5.9-point effect,
3.4 points (57%) come from `tau_alpha`, households newly crossing from
“spends nothing away from home” to “spends something”, and 2.6 points
(43%) from `tau_mu`, a shift in how much is spent away from home among
households that already spend something. The policy reading is specific,
not just larger-or-smaller: the transfer mainly changes *whether* a
household eats out at all, more than *how much* an already-eating-out
household spends. Standard errors in the paper come from a cluster
bootstrap over primary sampling units within strata (150 replicates: SE
0.0076, 0.0048, 0.0059 for `tau`, `tau_alpha`, `tau_mu`, all three
intervals excluding zero), which this package does not implement
directly; see [`boot::boot()`](https://rdrr.io/pkg/boot/man/boot.html)
or `survey::svyboot()` with the survey design variables `upa`/`estrato`.

## Curvature: which households carry the estimate

``` r
cv <- bic_curvature(fit, "T", dat)
c(BdT = cv$BdT, discrete = cv$BdT_discrete, continuous = cv$BdT_continuous)
#>         BdT    discrete  continuous
#> 0.001248564 0.001152412 0.00009616  # 92% discrete, cross term ~1e-9
```

[`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md)
says *how big* the effect is and *through which component*;
[`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md)
asks a different question, how much the fitted model itself depends on
the treatment assignment of particular households, regardless of the
effect’s sign or size. The discrete block carries 92% of that dependence
here, against 57% of the effect itself: the two numbers agree on which
component dominates and are not supposed to match exactly, since one is
a share of an average effect and the other a share of a curvature. The
gap between 92% and 57% is informative on its own: Section 8.3 of the
paper traces part of it to a treatment effect on the *precision*
submodel (how tightly spending clusters around its mean), which
contributes to the curvature but, because the mixture mean does not
depend on precision, contributes nothing to `tau`, `tau_alpha` or
`tau_mu` — an effect the decomposition above is structurally unable to
show, and that only this curvature step reveals.

``` r
icim <- bic_icim(cv)
sum(icim$influential)
#> 7492
table(icim$type)
#> continuous    discrete
#>       3243        4249
```

7,492 of the 53,022 households (14%) are individually influential by the
$2 \times \text{mean(ICIM)}$ screening rule, a leverage diagnostic, not
a claim that these households have unusually large individual effects.
Most of them (4,249) are influential through the discrete component, the
same component that dominates the aggregate curvature.

## Sensitivity to unmeasured confounding

``` r
sens <- bic_sensitivity(cv, fit, "T", dat, tau_hat = g["tau"])
c(L1 = sens$L1, Gamma_star = sens$Gamma_star)
#>        L1 Gamma_star
#>  4.137724   1.028965
```

`Gamma_star` answers: how strong would an unmeasured confounder need to
be, in odds-ratio terms, before it could plausibly explain away the
estimated effect? A `Gamma_star` far above 1 would mean the conclusion
is robust to all but an implausibly strong confounder; one close to 1,
as here, means the bound cannot rule out even a very weak one. This
bound is correctly computed but, as Section 8.4 of the paper discusses
at length, not informative at this sample size, and for a substantive
reason rather than an algebraic one: its worst case requires the
confounding of every one of the 53,022 households to align adversarially
with the sign of that household’s own contribution, a configuration no
single realistic unmeasured confounder would produce. We report
`Gamma_star` honestly rather than omit it, and read it as an open
problem in calibrating this style of bound at large sample sizes, not as
evidence against the effect.

## Reference

Ospina, R. (2026). Causal inference for proportional outcomes via
likelihood displacement in inflated beta regression. Submitted to *The
Annals of Applied Statistics*.
