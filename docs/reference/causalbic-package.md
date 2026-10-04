# causalbic: Causal Inference for Zero-or-One Inflated Beta Regression

Companion package to Ospina (2026), *Causal inference for proportional
outcomes via likelihood displacement in inflated beta regression*. Fits
the zero-or-one inflated beta (BIc) regression of Ospina and Ferrari
(2012) with a treatment indicator in each submodel, estimates the
average/conditional treatment effect by g-computation
([`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md),
[`bic_cate()`](https://raydonal.github.io/causalbic/reference/bic_cate.md)),
and decomposes it exactly into a discrete-component and a
continuous-component contribution, a consequence of the block-diagonal
Fisher information of the BIc likelihood. A diagnostic layer built on
the same separability adds a causal conformal normal curvature with the
same additive decomposition
([`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md)),
a per-unit causal influence screen
([`bic_icim()`](https://raydonal.github.io/causalbic/reference/bic_icim.md)),
and a Hölder-duality sensitivity bound for unmeasured confounding
([`bic_sensitivity()`](https://raydonal.github.io/causalbic/reference/bic_sensitivity.md)).

Start with
[`vignette("causalbic")`](https://raydonal.github.io/causalbic/articles/causalbic.md)
for a worked example on simulated data with a known answer.

## See also

Useful links:

- <https://github.com/Raydonal/causalbic>

- <https://raydonal.github.io/causalbic/>

- Report bugs at <https://github.com/Raydonal/causalbic/issues>

## Author

**Maintainer**: Raydonal Ospina <raydonal@de.ufpe.br>

Authors:

- Raydonal Ospina <raydonal@de.ufpe.br>
