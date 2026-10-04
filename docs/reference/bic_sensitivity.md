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
