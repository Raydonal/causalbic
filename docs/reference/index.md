# Package index

## Fitting

Fit the BIc model and evaluate its fitted parts.

- [`bic_fit()`](https://raydonal.github.io/causalbic/reference/bic_fit.md)
  : Fit a BIc (zero-or-one inflated beta) regression
- [`bic_parts()`](https://raydonal.github.io/causalbic/reference/bic_parts.md)
  : Fitted BIc component parts under a counterfactual treatment value

## Identification and estimation

G-computation estimate of the average/conditional treatment effect and
its exact discrete/continuous decomposition. This is the layer that
identifies the effect; nothing below it changes this result.

- [`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md)
  : G-computation decomposition of the average treatment effect
- [`bic_cate()`](https://raydonal.github.io/causalbic/reference/bic_cate.md)
  : Conditional average treatment effect at covariate profiles

## Diagnostics

The causal-perturbation diagnostic layer: curvature, per-unit influence,
and sensitivity to unmeasured confounding.

- [`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md)
  : Causal conformal normal curvature (CCNC) and its block decomposition
- [`bic_icim()`](https://raydonal.github.io/causalbic/reference/bic_icim.md)
  : Individual Causal Influence Measure (ICIM)
- [`bic_sensitivity()`](https://raydonal.github.io/causalbic/reference/bic_sensitivity.md)
  : Sensitivity of the average treatment effect to unmeasured
  confounding

## Simulation

- [`simulate_bic()`](https://raydonal.github.io/causalbic/reference/simulate_bic.md)
  : Simulate data from a causal zero-inflated beta (BIc) model

## Figures

Reproduce the manuscript’s figures from the package alone.

- [`plot_concept()`](https://raydonal.github.io/causalbic/reference/plot_concept.md)
  : The curvature concept figure (Figure 1 of Ospina, 2026)
- [`plot_cate()`](https://raydonal.github.io/causalbic/reference/plot_cate.md)
  : The conditional average treatment effect figure (Figure 2 of Ospina,
  2026)
- [`plot_diagnostics()`](https://raydonal.github.io/causalbic/reference/plot_diagnostics.md)
  : Goodness-of-fit diagnostics for a fitted BIc model (Figure 5 of
  Ospina, 2026)
