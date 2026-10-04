#' Fit a BIc (zero-or-one inflated beta) regression
#'
#' Thin wrapper around [gamlss::gamlss()] for the inflated beta regression
#' of Ospina and Ferrari (2012), fitting the three (or four, for
#' two-boundary responses) linked submodels of Eq. (1) in Ospina (2026):
#' a discrete inflation-probability submodel and a continuous-mean
#' submodel, optionally with their own precision submodel.
#'
#' @param formula Formula for the continuous-mean submodel (`mu`), e.g.
#'   `y ~ T + x1 + x2`.
#' @param sigma.formula Formula for the precision submodel (default
#'   `~1`, constant precision).
#' @param nu.formula Formula for the inflation-at-zero submodel.
#' @param tau.formula Formula for the inflation-at-one submodel. Leave
#'   `NULL` for a one-boundary (inflation at zero only) response, fit with
#'   `gamlss.dist::BEZI`; supply it for a two-boundary response, fit with
#'   `gamlss.dist::BEINF`.
#' @param data A data frame.
#' @param weights Optional prior weights (e.g. survey expansion weights),
#'   passed to `gamlss`.
#' @param ... Further arguments passed to [gamlss::gamlss()].
#'
#' @return A fitted `gamlss` object, as returned by [gamlss::gamlss()],
#'   with its family (`"BEZI"` or `"BEINF"`) recorded for use by
#'   [bic_gcomp()] and [bic_curvature()].
#'
#' @references Ospina, R. and Ferrari, S. L. P. (2012). A general class of
#'   zero-or-one inflated beta regression models. *Computational
#'   Statistics & Data Analysis*, 56, 1609-1623.
#' @export
bic_fit <- function(formula, sigma.formula = ~1, nu.formula = ~1,
                     tau.formula = NULL, data, weights = NULL, ...) {
  fam <- if (is.null(tau.formula)) gamlss.dist::BEZI else gamlss.dist::BEINF
  args <- list(formula = formula, sigma.formula = sigma.formula,
               nu.formula = nu.formula, family = fam, data = data, ...)
  if (!is.null(tau.formula)) args$tau.formula <- tau.formula
  if (!is.null(weights)) args$weights <- weights
  if (is.null(args$control)) {
    args$control <- gamlss::gamlss.control(trace = FALSE)
  }
  do.call(gamlss::gamlss, args)
}

#' Fitted BIc component parts under a counterfactual treatment value
#'
#' Evaluates the fitted inflation probability/probabilities and continuous
#' mean of a [bic_fit()] object with the treatment variable set to a fixed
#' counterfactual value `a` for every row of `newdata`, using the fitted
#' coefficients and the model's own design matrices directly (not
#' `predict.gamlss(..., newdata=)`, which re-resolves its stored `data`
#' argument by name in the calling frame and silently returns the wrong
#' frame when the fit was produced inside a function; see Ospina (2026),
#' Section 4).
#'
#' @param fit A fitted model from [bic_fit()].
#' @param treat Character, the name of the treatment variable in `newdata`.
#' @param newdata A data frame with `treat` and all other covariates used
#'   by `fit`.
#' @param a The counterfactual value to substitute for `treat` (`0` or
#'   `1`).
#'
#' @return A list with `mu` (continuous mean), `p0` (probability of the
#'   lower boundary) and, for two-boundary fits, `p1` (probability of the
#'   upper boundary), and `EY`, the mixture mean
#'   \eqn{p_1 + (1 - p_0 - p_1)\mu}.
#' @export
bic_parts <- function(fit, treat, newdata, a) {
  nd <- newdata
  nd[[treat]] <- a
  mu_terms <- stats::delete.response(stats::terms(stats::formula(fit, "mu")))
  nu_terms <- stats::delete.response(stats::terms(stats::formula(fit, "nu")))
  mu <- stats::plogis(as.numeric(
    stats::model.matrix(mu_terms, nd) %*% stats::coef(fit, "mu")))
  nu <- exp(as.numeric(
    stats::model.matrix(nu_terms, nd) %*% stats::coef(fit, "nu")))

  two_boundary <- fit$family[1] == "BEINF"
  if (two_boundary) {
    tau_terms <- stats::delete.response(stats::terms(stats::formula(fit, "tau")))
    ta <- exp(as.numeric(
      stats::model.matrix(tau_terms, nd) %*% stats::coef(fit, "tau")))
    den <- 1 + nu + ta
    p0 <- nu / den; p1 <- ta / den
    EY <- p1 + (1 - p0 - p1) * mu
    return(list(mu = mu, p0 = p0, p1 = p1, EY = EY))
  }
  p0 <- nu / (1 + nu)
  EY <- (1 - p0) * mu
  list(mu = mu, p0 = p0, p1 = 0, EY = EY)
}

#' G-computation decomposition of the average treatment effect
#'
#' Estimates the average treatment effect and its exact decomposition into
#' a discrete-component contribution (through the boundary probabilities)
#' and a continuous-component contribution (through the conditional mean),
#' Proposition 2.3 (one boundary) / Proposition 2.4 (two boundaries) of
#' Ospina (2026). Identification rests on the ordinary potential-outcomes
#' assumptions (SUTVA, ignorability given the covariates in `fit`,
#' positivity); this function does not check them.
#'
#' @param fit A fitted model from [bic_fit()].
#' @param treat Character, the name of the treatment variable.
#' @param data The data frame the effect is averaged over (by default, the
#'   data `fit` was fitted on).
#' @param weights Optional averaging weights (e.g. survey weights),
#'   normalized internally to sum to one. Defaults to equal weights.
#'
#' @return A named numeric vector `c(tau, tau_alpha, tau_mu)`, with
#'   `tau_alpha + tau_mu == tau` exactly (to floating-point precision).
#'
#' @examples
#' dat <- simulate_bic(400, seed = 1)
#' fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
#' bic_gcomp(fit, "T", dat)
#' attr(dat, "truth")
#'
#' @export
bic_gcomp <- function(fit, treat, data, weights = NULL) {
  w <- if (is.null(weights)) rep(1, nrow(data)) else weights
  w <- w / sum(w)
  q1 <- bic_parts(fit, treat, data, 1)
  q0 <- bic_parts(fit, treat, data, 0)
  EY1 <- sum(w * q1$EY); EY0 <- sum(w * q0$EY)
  tau <- EY1 - EY0
  ## boundary probabilities at their treated values, continuous mean held
  ## at its control value (Proposition 2.3/2.4)
  EY_disc <- sum(w * (q1$p1 + (1 - q1$p0 - q1$p1) * q0$mu))
  tau_alpha <- EY_disc - EY0
  c(tau = tau, tau_alpha = tau_alpha, tau_mu = tau - tau_alpha)
}

#' Conditional average treatment effect at covariate profiles
#'
#' The same decomposition as [bic_gcomp()], evaluated at specific
#' covariate profiles (Definition 4.3 of Ospina, 2026) instead of averaged
#' over a sample.
#'
#' @inheritParams bic_gcomp
#' @param profiles A data frame of covariate profiles (one row per
#'   profile), with all covariates used by `fit` except `treat`.
#'
#' @return A data frame with one row per profile and columns `tau`,
#'   `tau_alpha`, `tau_mu`.
#' @export
bic_cate <- function(fit, treat, profiles) {
  profiles[[treat]] <- 0
  out <- t(vapply(seq_len(nrow(profiles)), function(i) {
    bic_gcomp(fit, treat, profiles[i, , drop = FALSE])
  }, numeric(3)))
  as.data.frame(out)
}
