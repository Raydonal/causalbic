#' causalbic: Causal Inference for Zero-or-One Inflated Beta Regression
#'
#' @description
#' Companion package to Ospina (2026), *Causal inference for proportional
#' outcomes via likelihood displacement in inflated beta regression*.
#' Fits the zero-or-one inflated beta (BIc) regression of Ospina and
#' Ferrari (2012) with a treatment indicator in each submodel, estimates
#' the average/conditional treatment effect by g-computation
#' ([bic_gcomp()], [bic_cate()]), and decomposes it exactly into a
#' discrete-component and a continuous-component contribution, a
#' consequence of the block-diagonal Fisher information of the BIc
#' likelihood. A diagnostic layer built on the same separability adds a
#' causal conformal normal curvature with the same additive decomposition
#' ([bic_curvature()]), a per-unit causal influence screen
#' ([bic_icim()]), and a Hölder-duality sensitivity bound for unmeasured
#' confounding ([bic_sensitivity()]).
#'
#' Start with `vignette("causalbic")` for a worked example on simulated
#' data with a known answer.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
