# Sensitivity of the average treatment effect to unmeasured confounding

The \\\Gamma\\-model sensitivity bound of Theorem 6.1 in Ospina (2026):
a sharp, Hölder-duality bound on how far an unmeasured confounder of
odds-ratio strength at most \\\Gamma\\ can move the estimate, calibrated
by the per-unit causal influence vector CIC (Theorem 3.6). The bound
pairs the box constraint the \\\Gamma\\-model places on confounding with
the \\\ell_1\\ norm of CIC, not the \\\ell_2\\ norm; see the paper for
why the \\\ell_2\\ pairing, including one built from the curvature `BdT`
itself, is not sharp and was a genuine error in an earlier draft of this
method.

## Usage

``` r
bic_sensitivity(cv, fit, treat, data, tau_hat, eps = 1e-04)
```

## Arguments

- cv:

  A `"bic_curvature"` object from
  [`bic_curvature()`](https://raydonal.github.io/causalbic/reference/bic_curvature.md).

- fit, treat, data:

  As in
  [`bic_gcomp()`](https://raydonal.github.io/causalbic/reference/bic_gcomp.md);
  used to compute the gradient of the estimated effect with respect to
  the model parameters.

- tau_hat:

  The estimated average treatment effect (e.g.
  `bic_gcomp(fit, treat, data)["tau"]`), used to solve for `Gamma_star`.

- eps:

  Step size for the numerical gradient.

## Value

A list with `CIC` (the per-unit causal influence vector), `L1`
(\\\\\mathrm{CIC}\\\_1\\), `Gamma_star` (the smallest \\\Gamma\\ at
which the bound reaches `|tau_hat|`, or `NA` if the bound already
exceeds it at `Gamma = 1`), and `bound` (a function of `Gamma` returning
the bound itself).

## Details

`Gamma_star` answers one question: how strong would an unmeasured
confounder need to be, on an odds-ratio scale, before it could plausibly
explain away the estimated effect? `Gamma_star` far above 1 means the
conclusion survives all but an implausibly strong confounder;
`Gamma_star` close to 1 (or `NA`, meaning the bound already exceeds
`|tau_hat|` with no confounding at all) means the bound cannot rule out
even a weak one. A small `Gamma_star` is not necessarily a defect of the
data or the estimate: at large sample sizes, the worst case this bound
allows requires *every* unit's confounding to align adversarially with
the sign of that unit's own contribution, a configuration no single
realistic confounder produces, so the bound can be sharp for the box
constraint on confounding it assumes while still not being informative
in practice; see the vignette and Ospina (2026), Section 8, for a worked
example where this happens.
