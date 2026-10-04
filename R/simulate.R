#' Simulate data from a causal zero-inflated beta (BIc) model
#'
#' Draws potential outcomes from a one-boundary inflated beta regression
#' (`gamlss.dist::BEZI`, inflation at zero) with a confounded treatment
#' assignment, the data-generating process used in the simulation study of
#' Ospina (2026). Useful for testing [bic_gcomp()], [bic_curvature()] and
#' friends against a model where the true average treatment effect and its
#' discrete/continuous components are known in closed form.
#'
#' @param n Sample size.
#' @param gamma Numeric length-3 vector `(gamma0, gamma1, gammaT)`, the
#'   inflation-probability (logit) linear predictor coefficients for
#'   intercept, covariate `W1` and treatment.
#' @param beta Numeric length-3 vector `(beta0, beta1, betaT)`, the
#'   continuous-mean (logit) linear predictor coefficients for intercept,
#'   covariate `W2` and treatment.
#' @param phi Precision of the continuous beta component (constant).
#' @param rho Confounding strength: treatment is drawn with probability
#'   `plogis(rho * (W1 + W2))`, so `rho = 0` is a randomized experiment and
#'   `rho > 0` confounds treatment with the covariates that also drive the
#'   outcome.
#' @param seed Optional seed for reproducibility.
#'
#' @return A `data.frame` with columns `y` (observed response), `T`
#'   (treatment), `W1`, `W2` (covariates), and attributes `"truth"` (a list
#'   with the population `tau`, `tau_alpha`, `tau_mu`) and `"params"` (the
#'   generating coefficients).
#'
#' @examples
#' dat <- simulate_bic(500, seed = 1)
#' attr(dat, "truth")
#'
#' @export
simulate_bic <- function(n, gamma = c(-1.5, 0.3, 1.5),
                          beta = c(-1.0, 0.5, 1.2),
                          phi = 4, rho = 0.4, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  W1 <- stats::rnorm(n)
  W2 <- stats::rnorm(n)
  pT <- stats::plogis(rho * (W1 + W2))
  Tt <- stats::rbinom(n, 1, pT)

  alpha_of <- function(a, w1) stats::plogis(gamma[1] + gamma[2] * w1 + gamma[3] * a)
  mu_of    <- function(a, w2) stats::plogis(beta[1]  + beta[2]  * w2 + beta[3]  * a)

  a1 <- alpha_of(1, W1); a0 <- alpha_of(0, W1)
  m1 <- mu_of(1, W2);    m0 <- mu_of(0, W2)
  al <- ifelse(Tt == 1, a1, a0)
  mu <- ifelse(Tt == 1, m1, m0)
  y  <- gamlss.dist::rBEZI(n, mu = mu, sigma = phi, nu = al)
  y  <- pmin(y, 1 - 1e-8)

  tau_alpha_i <- -(a1 - a0) * m0
  tau_mu_i    <- (1 - a1) * (m1 - m0)

  out <- data.frame(y = y, T = Tt, W1 = W1, W2 = W2)
  attr(out, "truth") <- list(
    tau       = mean(tau_alpha_i + tau_mu_i),
    tau_alpha = mean(tau_alpha_i),
    tau_mu    = mean(tau_mu_i)
  )
  attr(out, "params") <- list(gamma = gamma, beta = beta, phi = phi, rho = rho)
  out
}
