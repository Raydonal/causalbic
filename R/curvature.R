## Internal: design matrices, inverse links and a flat-parameter index for
## a bic_fit() object, shared by the log-density, score and information
## helpers below. Not exported.
.bic_terms <- function(fit, data) {
  two_boundary <- fit$family[1] == "BEINF"
  get_mm <- function(which) {
    trm <- stats::delete.response(stats::terms(stats::formula(fit, which)))
    stats::model.matrix(trm, data)
  }
  X_mu <- get_mm("mu"); X_sigma <- get_mm("sigma"); X_nu <- get_mm("nu")
  linkinv <- function(link) stats::make.link(link)$linkinv
  p_mu <- ncol(X_mu); p_sigma <- ncol(X_sigma); p_nu <- ncol(X_nu)
  idx <- list(mu = seq_len(p_mu),
              sigma = p_mu + seq_len(p_sigma),
              nu = p_mu + p_sigma + seq_len(p_nu))
  if (two_boundary) {
    X_tau <- get_mm("tau")
    p_tau <- ncol(X_tau)
    idx$tau <- p_mu + p_sigma + p_nu + seq_len(p_tau)
  } else {
    X_tau <- NULL
  }
  list(two_boundary = two_boundary,
       X = list(mu = X_mu, sigma = X_sigma, nu = X_nu, tau = X_tau),
       g = list(mu = linkinv(fit$mu.link), sigma = linkinv(fit$sigma.link),
                 nu = linkinv(fit$nu.link),
                 tau = if (two_boundary) linkinv(fit$tau.link) else NULL),
       idx = idx,
       idx_discrete = if (two_boundary) c(idx$nu, idx$tau) else idx$nu,
       idx_continuous = c(idx$mu, idx$sigma))
}

.bic_theta_hat <- function(fit, trm) {
  theta <- numeric(max(unlist(trm$idx)))
  theta[trm$idx$mu]    <- stats::coef(fit, "mu")
  theta[trm$idx$sigma] <- stats::coef(fit, "sigma")
  theta[trm$idx$nu]    <- stats::coef(fit, "nu")
  if (trm$two_boundary) theta[trm$idx$tau] <- stats::coef(fit, "tau")
  theta
}

## Per-unit log-density, as a function of the flat parameter theta, with
## the design matrices of `trm` (already built at a possibly
## counterfactual value of the treatment). Returns a length-n vector.
.bic_logdens_vec <- function(theta, y, trm) {
  mu    <- trm$g$mu(as.numeric(trm$X$mu %*% theta[trm$idx$mu]))
  sigma <- trm$g$sigma(as.numeric(trm$X$sigma %*% theta[trm$idx$sigma]))
  nu    <- trm$g$nu(as.numeric(trm$X$nu %*% theta[trm$idx$nu]))
  if (trm$two_boundary) {
    tau <- trm$g$tau(as.numeric(trm$X$tau %*% theta[trm$idx$tau]))
    gamlss.dist::dBEINF(y, mu = mu, sigma = sigma, nu = nu, tau = tau, log = TRUE)
  } else {
    gamlss.dist::dBEZI(y, mu = mu, sigma = sigma, nu = nu, log = TRUE)
  }
}

#' Causal conformal normal curvature (CCNC) and its block decomposition
#'
#' Builds the causal Delta matrix (Theorem 3.2 of Ospina, 2026) by moving
#' each unit's *observed* response between its two potential-outcome
#' log-densities, and from it the conformal normal curvature in the
#' treatment direction, `B_dT`, and its exact additive split into a
#' discrete-component part and a continuous-component part (Theorem 3.5),
#' which holds because the Fisher information of the BIc model is block
#' diagonal (Lemma 2.1). The observed information is a numerical Hessian
#' of the fitted log-likelihood, the same construction used for the
#' real-data results in Ospina (2026), Section 8, so this does not depend
#' on a closed-form score for a particular link function.
#'
#' @inheritParams bic_gcomp
#' @param eps Step size passed to [numDeriv::jacobian()] /
#'   [numDeriv::hessian()] for the numerical derivatives.
#'
#' @return A list of class `"bic_curvature"` with elements `BdT` (the
#'   scalar curvature), `BdT_discrete`, `BdT_continuous` (its two
#'   components, summing to `BdT`), `Delta` (the `p x n` causal Delta
#'   matrix), `Iinv` (the `p x p` inverse observed information),
#'   `cross_term` (the numerically-vanishing cross term between the two
#'   blocks, a diagnostic for Lemma 2.1 holding on this fit), and `trm`
#'   (internal design/index information reused by [bic_icim()] and
#'   [bic_sensitivity()]).
#'
#' @details
#' This answers a different question from [bic_gcomp()]. `bic_gcomp()`
#' says how big the effect is and through which component; `BdT` says how
#' much the *fitted model itself* depends on the treatment assignment of
#' the sample at hand, a sensitivity/leverage reading, not an effect size,
#' and in particular not something that should be expected to equal, or
#' even track closely, the share each component contributes to `tau`
#' (one is a share of an average effect, the other a share of a
#' curvature). A large gap between the two shares is itself informative:
#' it can mean a submodel affects the curvature, e.g. through a treatment
#' effect on precision, without affecting `tau` at all, since the mixture
#' mean does not depend on precision.
#'
#' @examples
#' dat <- simulate_bic(400, seed = 1)
#' fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
#' cv <- bic_curvature(fit, "T", dat)
#' cv$BdT; cv$BdT_discrete + cv$BdT_continuous  # match cv$BdT
#'
#' @export
bic_curvature <- function(fit, treat, data, eps = 1e-4) {
  trm <- .bic_terms(fit, data)
  theta_hat <- .bic_theta_hat(fit, trm)
  y <- stats::model.response(stats::model.frame(stats::formula(fit, "mu"), data))

  d1 <- data; d1[[treat]] <- 1
  d0 <- data; d0[[treat]] <- 0
  trm1 <- .bic_terms(fit, d1)
  trm0 <- .bic_terms(fit, d0)

  score <- function(trm_a) {
    f <- function(theta) .bic_logdens_vec(theta, y, trm_a)
    t(numDeriv::jacobian(f, theta_hat, method.args = list(eps = eps)))
  }
  S1 <- score(trm1); S0 <- score(trm0)
  Delta <- S1 - S0   # p x n

  loglik <- function(theta) sum(.bic_logdens_vec(theta, y, trm))
  H <- numDeriv::hessian(loglik, theta_hat, method.args = list(eps = eps))
  Iinv <- solve(-H)

  dT <- data[[treat]] / sqrt(sum(data[[treat]]))
  v  <- as.numeric(Delta %*% dT)
  A  <- Delta %*% t(Delta)
  normF <- sqrt(sum(diag((Iinv %*% A) %*% (Iinv %*% A))))

  blockB <- function(idx) {
    vi <- v[idx]
    as.numeric(t(vi) %*% Iinv[idx, idx, drop = FALSE] %*% vi) / normF
  }
  BdT <- as.numeric(t(v) %*% Iinv %*% v) / normF
  Bd_disc <- blockB(trm$idx_discrete)
  Bd_cont <- blockB(trm$idx_continuous)

  structure(list(BdT = BdT, BdT_discrete = Bd_disc, BdT_continuous = Bd_cont,
                 cross_term = BdT - Bd_disc - Bd_cont,
                 Delta = Delta, Iinv = Iinv, normF = normF, dT = dT,
                 trm = trm),
            class = "bic_curvature")
}

#' Individual Causal Influence Measure (ICIM)
#'
#' The per-unit diagonal of the causal curvature of [bic_curvature()]
#' (Definition 5.1 of Ospina, 2026), split by whether each unit's
#' influence runs mainly through the discrete or the continuous component
#' (Definition 5.2), and screened for disproportionate influence by the
#' `2 * mean(ICIM)` rule.
#'
#' @param cv A `"bic_curvature"` object from [bic_curvature()].
#'
#' @return A data frame with one row per unit and columns `ICIM`,
#'   `ICIM_discrete`, `ICIM_continuous`, `type`
#'   (`"discrete"`/`"continuous"`/`"mixed"`) and `influential` (logical,
#'   `ICIM > 2 * mean(ICIM)`).
#'
#' @details
#' `influential = TRUE` flags a unit whose leverage on the fitted model is
#' more than twice the sample's typical leverage, a screening rule in the
#' spirit of the `2 * mean(hat value)` rule for leverage in linear models.
#' It is **not** a claim that the unit has an unusually large individual
#' treatment effect, and a flagged unit can have a small or even
#' near-zero estimated effect; leverage and effect size answer different
#' questions. `type` says which component a flagged unit's leverage runs
#' through, which is useful for tracing an unexpected curvature share
#' back to specific observations (e.g. a handful of households with
#' extreme covariate profiles on the boundary side) rather than treating
#' the curvature as an unexplained aggregate number.
#' @export
bic_icim <- function(cv) {
  stopifnot(inherits(cv, "bic_curvature"))
  Delta <- cv$Delta; Iinv <- cv$Iinv; trm <- cv$trm
  M <- Iinv %*% Delta
  icim_all <- colSums(Delta * M) / cv$normF
  icim_block <- function(idx) {
    colSums(Delta[idx, , drop = FALSE] * M[idx, , drop = FALSE]) / cv$normF
  }
  icim_d <- icim_block(trm$idx_discrete)
  icim_c <- icim_block(trm$idx_continuous)
  share_d <- icim_d / icim_all
  type <- ifelse(share_d > 0.5, "discrete",
          ifelse(share_d < 0.5, "continuous", "mixed"))
  thr <- 2 * mean(icim_all)
  data.frame(ICIM = icim_all, ICIM_discrete = icim_d,
             ICIM_continuous = icim_c, type = type,
             influential = icim_all > thr)
}

#' Sensitivity of the average treatment effect to unmeasured confounding
#'
#' The \eqn{\Gamma}-model sensitivity bound of Theorem 6.1 in Ospina
#' (2026): a sharp, Hölder-duality bound on how far an unmeasured
#' confounder of odds-ratio strength at most \eqn{\Gamma} can move the
#' estimate, calibrated by the per-unit causal influence vector CIC
#' (Theorem 3.6). The bound pairs the box constraint the \eqn{\Gamma}-model
#' places on confounding with the \eqn{\ell_1} norm of CIC, not the
#' \eqn{\ell_2} norm; see the paper for why the \eqn{\ell_2} pairing,
#' including one built from the curvature `BdT` itself, is not sharp and
#' was a genuine error in an earlier draft of this method.
#'
#' @param cv A `"bic_curvature"` object from [bic_curvature()].
#' @param fit,treat,data As in [bic_gcomp()]; used to compute the gradient
#'   of the estimated effect with respect to the model parameters.
#' @param tau_hat The estimated average treatment effect (e.g.
#'   `bic_gcomp(fit, treat, data)["tau"]`), used to solve for `Gamma_star`.
#' @param eps Step size for the numerical gradient.
#'
#' @return A list with `CIC` (the per-unit causal influence vector),
#'   `L1` (\eqn{\|\mathrm{CIC}\|_1}), `Gamma_star` (the smallest
#'   \eqn{\Gamma} at which the bound reaches `|tau_hat|`, or `NA` if the
#'   bound already exceeds it at `Gamma = 1`), and `bound` (a function of
#'   `Gamma` returning the bound itself).
#'
#' @details
#' `Gamma_star` answers one question: how strong would an unmeasured
#' confounder need to be, on an odds-ratio scale, before it could
#' plausibly explain away the estimated effect? `Gamma_star` far above 1
#' means the conclusion survives all but an implausibly strong confounder;
#' `Gamma_star` close to 1 (or `NA`, meaning the bound already exceeds
#' `|tau_hat|` with no confounding at all) means the bound cannot rule out
#' even a weak one. A small `Gamma_star` is not necessarily a defect of
#' the data or the estimate: at large sample sizes, the worst case this
#' bound allows requires *every* unit's confounding to align
#' adversarially with the sign of that unit's own contribution, a
#' configuration no single realistic confounder produces, so the bound
#' can be sharp for the box constraint on confounding it assumes while
#' still not being informative in practice; see the vignette and Ospina
#' (2026), Section 8, for a worked example where this happens.
#' @export
bic_sensitivity <- function(cv, fit, treat, data, tau_hat, eps = 1e-4) {
  stopifnot(inherits(cv, "bic_curvature"))
  trm <- cv$trm
  w <- rep(1 / nrow(data), nrow(data))
  tau_of_theta <- function(theta) {
    parts_a <- function(a) {
      d <- data; d[[treat]] <- a
      t_a <- .bic_terms(fit, d)
      mu <- t_a$g$mu(as.numeric(t_a$X$mu %*% theta[t_a$idx$mu]))
      nu <- t_a$g$nu(as.numeric(t_a$X$nu %*% theta[t_a$idx$nu]))
      if (t_a$two_boundary) {
        tau <- t_a$g$tau(as.numeric(t_a$X$tau %*% theta[t_a$idx$tau]))
        p0 <- nu / (1 + nu + tau); p1 <- tau / (1 + nu + tau)
      } else {
        p0 <- nu / (1 + nu); p1 <- 0
      }
      list(mu = mu, p0 = p0, p1 = p1)
    }
    q1 <- parts_a(1); q0 <- parts_a(0)
    EY1 <- sum(w * (q1$p1 + (1 - q1$p0 - q1$p1) * q1$mu))
    EY0 <- sum(w * (q0$p1 + (1 - q0$p0 - q0$p1) * q0$mu))
    EY1 - EY0
  }
  theta_hat <- .bic_theta_hat(fit, trm)
  gradtau <- numDeriv::grad(tau_of_theta, theta_hat, method.args = list(eps = eps))
  CIC <- as.numeric(t(gradtau) %*% cv$Iinv %*% cv$Delta)
  L1 <- sum(abs(CIC))
  k <- abs(tau_hat) / L1
  Gamma_star <- if (k < 1) (1 + k) / (1 - k) else NA_real_
  bound <- function(Gamma) ((Gamma - 1) / (Gamma + 1)) * L1
  list(CIC = CIC, L1 = L1, Gamma_star = Gamma_star, bound = bound)
}
