## Visual identity shared by the three figures below, sampled from
## Alencar's disgraphia application figure for a consistent palette across
## the author's work; also a colorblind-safe pair (unlike red/green).
.causalbic_blue   <- "#2A78D6"
.causalbic_orange <- "#EB6834"

#' The curvature concept figure (Figure 1 of Ospina, 2026)
#'
#' A two-panel, fully synthetic illustration of the paper's diagnostic
#' layer: (a) how a treatment can separately move the boundary probability
#' and the continuous mean of an inflated beta response, and (b) the
#' likelihood-displacement curve \eqn{F} along the treatment direction,
#' whose leading quadratic term at the factual world is the curvature
#' \eqn{B_{d_T}} of [bic_curvature()]. Both panels use illustrative
#' parameters chosen for legibility, not data from the application; no
#' arguments are needed to reproduce the figure exactly as printed.
#'
#' @return Invisibly `NULL`; called for its plotting side effect. Draws
#'   both panels in the current graphics device (set `par(mfrow = c(1,
#'   2))`, or open a device of width-to-height ratio near 2:1, before
#'   calling, to match the paper's layout).
#'
#' @examples
#' plot_concept()
#'
#' @export
plot_concept <- function() {
  COL_BLUE <- .causalbic_blue; COL_ORANGE <- .causalbic_orange

  ## ---- Panel (a): response distribution, control vs. treatment -------
  op <- graphics::par(mar = c(4.4, 4.6, 2.9, 1.2), cex.main = 1.02,
                       cex.lab = 0.96, cex.axis = 0.90, mgp = c(2.7, 0.7, 0))
  on.exit(graphics::par(op), add = TRUE)

  a0 <- 0.25; a1 <- 0.15
  m0 <- 0.40; m1 <- 0.55
  phi <- 8
  dbeta_mp <- function(x, m, phi) stats::dbeta(x, m * phi, (1 - m) * phi)
  xs <- seq(0.002, 0.998, length.out = 250)
  d0 <- (1 - a0) * dbeta_mp(xs, m0, phi)
  d1 <- (1 - a1) * dbeta_mp(xs, m1, phi)
  spike_scale <- 5
  peak0_x <- (m0 * phi - 1) / (phi - 2); peak1_x <- (m1 * phi - 1) / (phi - 2)
  peak0_y <- d0[which.min(abs(xs - peak0_x))]
  peak1_y <- d1[which.min(abs(xs - peak1_x))]
  ylim_a <- c(-0.05, 2.80)

  graphics::plot(xs, d1, type = "l", lwd = 2.4, col = COL_ORANGE, las = 1,
                 ylim = ylim_a, xlim = c(-0.05, 1.02),
                 xlab = "outcome y", ylab = "density on (0,1)",
                 main = "(a) response distribution, control vs. treatment")
  graphics::lines(xs, d0, lwd = 2.1, lty = 2, col = COL_BLUE)
  graphics::segments(-0.025, 0, -0.025, a0 * spike_scale, lwd = 5, col = COL_BLUE)
  graphics::segments(-0.010, 0, -0.010, a1 * spike_scale, lwd = 5, col = COL_ORANGE)
  graphics::text(-0.017, 2.70, "P(Y=0)", cex = 0.80, adj = c(0.5, 1), col = "grey20")
  graphics::text(peak0_x, peak0_y + 0.20, "control", cex = 0.84, adj = c(1, 0), col = COL_BLUE)
  graphics::text(peak1_x, peak1_y + 0.20, "treated", cex = 0.84, adj = c(0, 0), col = COL_ORANGE)
  arr_y <- 2.38
  graphics::arrows(peak0_x, arr_y, peak1_x, arr_y, length = 0.06, code = 3,
                    lwd = 1.2, col = "grey30")
  graphics::text((peak0_x + peak1_x) / 2, arr_y + 0.17, "shift in continuous mean",
                 cex = 0.78, adj = c(0.5, 0), col = "grey30")

  ## ---- Panel (b): displacement along the path of worlds --------------
  graphics::par(mar = c(4.4, 4.8, 2.9, 2.2), mgp = c(2.9, 0.7, 0))

  k_ctrl <- 1.30; q_ctrl <- 0.40
  k_treat <- 0.75; q_treat <- 0.15
  F_true <- function(s) ifelse(s < 0, k_ctrl * s^2 + q_ctrl * s^4,
                                       k_treat * s^2 + q_treat * s^4)
  F_quad <- function(s) ifelse(s < 0, k_ctrl * s^2, k_treat * s^2)

  s_full <- seq(-1.05, 1.05, length.out = 400)
  s_loc  <- seq(-0.78, 0.78, length.out = 200)
  s_ctrl <- -0.85; s_treat <- 0.85
  F_ctrl <- F_true(s_ctrl); F_treat <- F_true(s_treat)

  graphics::plot(s_full, F_true(s_full), type = "l", lwd = 2.4, las = 1,
       xlab = expression("position along the treatment direction, " * s),
       ylab = expression("likelihood displacement, " * F(omega^0 + s * d[T])),
       xlim = c(-1.28, 2.05), ylim = c(-0.72, 2.18), xaxt = "n",
       main = "(b) displacement along the path of worlds")
  graphics::lines(s_loc, F_quad(s_loc), lwd = 2.0, lty = 2, col = COL_ORANGE)

  graphics::points(0, 0, pch = 19, cex = 1.05)
  graphics::segments(-0.22, 0, 0.22, 0, lwd = 1.0, col = "grey55")
  graphics::text(0, -0.26, "factual world", cex = 0.86, adj = c(0.5, 1))
  graphics::text(0, -0.47, expression(omega^0 == T), cex = 0.86, adj = c(0.5, 1))
  graphics::text(0, 2.16, expression(atop("curvature " * B[d[T]] * ":",
       "leading quadratic term of " * F)), cex = 0.78, adj = c(0.5, 1), col = "grey20")

  graphics::points(c(s_ctrl, s_treat), c(F_ctrl, F_treat), pch = 19, cex = 0.95)
  graphics::text(s_ctrl + 0.04, F_ctrl + 0.42, "control-everyone", cex = 0.78, adj = c(0, 0))
  graphics::text(s_ctrl + 0.04, F_ctrl + 0.24, expression(omega == 0), cex = 0.78, adj = c(0, 0))

  lab_x <- 1.10
  graphics::segments(s_treat + 0.03, F_treat + 0.05, lab_x - 0.02, F_treat + 0.38,
                      lwd = 0.7, col = "grey55")
  graphics::text(lab_x, F_treat + 0.42, "formal extension", cex = 0.78, adj = c(0, 0))
  graphics::text(lab_x, F_treat + 0.24, expression(omega[t] > 1 ~ "(treated)"),
                 cex = 0.78, adj = c(0, 0))

  graphics::legend("bottomright", legend = c("displacement F", "quadratic approximation"),
                    lty = c(1, 2), lwd = c(2.0, 2.0), col = c("black", COL_ORANGE),
                    bty = "n", cex = 0.72, seg.len = 1.8, y.intersp = 1.3)
  invisible(NULL)
}

#' The conditional average treatment effect figure (Figure 2 of Ospina, 2026)
#'
#' Simulates one dataset from [simulate_bic()], fits it with [bic_fit()],
#' and plots (a) the true conditional average treatment effect (CATE)
#' against the g-computation estimate from that single fit, with an RMSE
#' band, and (b) the true discrete- and continuous-component contributions
#' that add up to the CATE (the population-level counterpart of panel (b)
#' of [plot_concept()]).
#'
#' @param n,seed,gamma,beta,phi,rho As in [simulate_bic()]; the defaults
#'   reproduce the paper's figure exactly.
#' @param rmse Half-width of the plotted uncertainty band around the true
#'   CATE in panel (a). Defaults to `0.0427`, the `R = 200`-replicate,
#'   `n = 200` root-mean-squared error at the median covariate profile
#'   reported in Table 2 of Ospina (2026); this is **not** recomputed by
#'   this function (that would need hundreds of refits), so pass your own
#'   value if you change `n` or the generating parameters.
#'
#' @return Invisibly, a list with `grid` (the covariate values plotted),
#'   `truth` (a data frame of `tau`, `tau_alpha`, `tau_mu` at each grid
#'   point) and `estimate` (the g-computation CATE from the single fitted
#'   model). Called mainly for its plotting side effect; draws both panels
#'   in the current graphics device (set `par(mfrow = c(1, 2))` first).
#'
#' @examples
#' plot_cate()
#'
#' @export
plot_cate <- function(n = 200, seed = 7, gamma = c(-1.5, 0.3, 1.5),
                       beta = c(-1.0, 0.5, 1.2), phi = 4, rho = 0.4,
                       rmse = 0.0427) {
  COL_BLUE <- .causalbic_blue; COL_ORANGE <- .causalbic_orange
  op <- graphics::par(mar = c(4.2, 4.4, 2.4, 1.0), cex.lab = 0.88,
                       cex.main = 0.96, cex.axis = 0.82)
  on.exit(graphics::par(op), add = TRUE)

  cate_true <- function(w) {
    a1 <- stats::plogis(gamma[1] + gamma[2] * w + gamma[3])
    a0 <- stats::plogis(gamma[1] + gamma[2] * w)
    m1 <- stats::plogis(beta[1]  + beta[2]  * w + beta[3])
    m0 <- stats::plogis(beta[1]  + beta[2]  * w)
    ta <- -(a1 - a0) * m0
    tm <- (1 - a1) * (m1 - m0)
    data.frame(tau = ta + tm, tau_alpha = ta, tau_mu = tm)
  }
  wv <- seq(-2, 2, length.out = 100)
  ct <- cate_true(wv)

  ## ---- Panel (a): true vs. estimated CATE, with an RMSE band ---------
  dat <- simulate_bic(n, gamma = gamma, beta = beta, phi = phi, rho = rho, seed = seed)
  names(dat)[names(dat) == "W1"] <- "W1"  # alpha-submodel covariate
  fit <- bic_fit(y ~ W2 + T, nu.formula = ~ W1 + T, data = dat)

  profiles <- data.frame(W1 = wv, W2 = wv)
  est <- bic_cate(fit, "T", profiles)$tau

  graphics::plot(wv, ct$tau, type = "l", lwd = 2.3, las = 1,
       ylim = range(c(ct$tau - 1.96 * rmse, ct$tau + 1.96 * rmse)),
       xlab = "covariate value", ylab = "conditional average treatment effect",
       main = "(a) estimation of the conditional effect")
  graphics::polygon(c(wv, rev(wv)),
          c(ct$tau - 1.96 * rmse, rev(ct$tau + 1.96 * rmse)),
          col = grDevices::adjustcolor(COL_ORANGE, 0.14), border = NA)
  graphics::lines(wv, ct$tau, lwd = 2.3)
  pts <- seq(5, 100, by = 9)
  graphics::points(wv[pts], est[pts], pch = 19, cex = 0.8, col = COL_ORANGE)
  graphics::legend("bottomleft",
         legend = c("true conditional effect",
                    sprintf("g-computation estimate (n=%d fit)", n),
                    "approximate RMSE band"),
         lty = c(1, NA, NA), pch = c(NA, 19, 15),
         col = c("black", COL_ORANGE, grDevices::adjustcolor(COL_ORANGE, 0.3)),
         lwd = c(2.3, NA, NA), pt.cex = c(NA, 0.8, 1.4),
         bty = "n", cex = 0.72, y.intersp = 1.35)

  ## ---- Panel (b): the two component contributions --------------------
  rng <- range(c(ct$tau_alpha, ct$tau_mu, ct$tau))
  rng <- rng + c(-0.05, 0.05) * diff(rng)
  graphics::plot(wv, ct$tau_mu, type = "l", lwd = 2.3, las = 1, ylim = rng,
       col = COL_BLUE, xlab = "covariate value", ylab = "contribution to the effect",
       main = "(b) discrete and continuous components")
  graphics::lines(wv, ct$tau_alpha, lwd = 2.3, col = COL_ORANGE)
  graphics::lines(wv, ct$tau, lwd = 1.4, col = "grey40", lty = 2)
  graphics::abline(h = 0, col = "grey75", lwd = 0.8)
  graphics::legend("bottomleft",
         legend = c("continuous component", "discrete component", "total (CATE)"),
         lty = c(1, 1, 2), lwd = c(2.3, 2.3, 1.4),
         col = c(COL_BLUE, COL_ORANGE, "grey40"), bty = "n", cex = 0.72,
         y.intersp = 1.35)

  invisible(list(grid = wv, truth = ct, estimate = est))
}

#' Goodness-of-fit diagnostics for a fitted BIc model (Figure 5 of Ospina, 2026)
#'
#' Randomized quantile residuals (Dunn and Smyth, 1996) against the fitted
#' mean and, optionally, a covariate, a normal QQ plot, and the residual
#' density against the standard normal. Scatter panels subsample for
#' plotting (the smoothers and all other statistics use the full data,
#' since `gamlss`'s residuals are unweighted even under survey weights,
#' see Ospina (2026), Section 8.4): the subsample always keeps the
#' `n_extreme` most extreme residuals, shown in orange, on top of a random
#' draw of the rest, shown in blue, rather than a uniform random draw
#' alone, which is biased toward hiding exactly the tail behavior a
#' goodness-of-fit plot exists to show.
#'
#' @param fit A fitted model from [bic_fit()].
#' @param data The data frame `fit` was fitted on.
#' @param covariate Optional character, the name of a covariate in `data`
#'   to plot residuals against in an extra panel (used for the paper's
#'   `log household income` panel). `NULL` (default) omits that panel.
#' @param covariate_lab Axis label for `covariate`'s panel; defaults to
#'   `covariate` itself.
#' @param n_extreme Number of most-extreme residuals always shown.
#' @param n_bulk Size of the random subsample of the remaining residuals.
#' @param seed Optional seed (randomized quantile residuals depend on it
#'   at the boundary observations; the paper fixes it).
#'
#' @return Invisibly, a list with `residuals` (the full vector of
#'   randomized quantile residuals), `deviance`, `AIC`, `BIC`, `filliben`
#'   (the probability-plot correlation coefficient) and `shapiro` (the
#'   `shapiro.test()` result on a random subsample of at most 5000, the
#'   largest the test accepts). Called mainly for its plotting side
#'   effect; draws all panels in the current graphics device.
#'
#' @examples
#' dat <- simulate_bic(600, seed = 1)
#' fit <- bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
#' plot_diagnostics(fit, dat, covariate = "W1", seed = 1)
#'
#' @export
plot_diagnostics <- function(fit, data, covariate = NULL, covariate_lab = covariate,
                              n_extreme = 150, n_bulk = 8000, seed = NULL) {
  COL_BLUE <- .causalbic_blue; COL_ORANGE <- .causalbic_orange
  if (!is.null(seed)) set.seed(seed)
  n <- nrow(data)

  rq  <- stats::residuals(fit)
  mom <- c(mean = mean(rq), sd = stats::sd(rq),
           skew = mean((rq - mean(rq))^3) / stats::sd(rq)^3,
           kurt = mean((rq - mean(rq))^4) / stats::sd(rq)^4)
  fil <- stats::cor(sort(rq), stats::qnorm(stats::ppoints(n)))
  sub <- sample(n, min(5000, n))
  sw  <- stats::shapiro.test(rq[sub])

  n_extreme <- min(n_extreme, n)
  extreme <- order(abs(rq), decreasing = TRUE)[seq_len(n_extreme)]
  bulk <- setdiff(seq_len(n), extreme)
  shw_bulk <- sort(sample(bulk, min(n_bulk, length(bulk))))
  shw <- sort(c(shw_bulk, extreme))
  pt_col <- ifelse(shw %in% extreme, grDevices::adjustcolor(COL_ORANGE, 0.65),
                                      grDevices::adjustcolor(COL_BLUE, 0.30))

  has_cov <- !is.null(covariate)
  op <- graphics::par(mfrow = if (has_cov) c(2, 2) else c(1, 3),
                       mar = c(4.2, 4.2, 2.4, 1), cex.main = 1.05)
  on.exit(graphics::par(op), add = TRUE)

  fm <- stats::fitted(fit, "mu")
  graphics::plot(fm[shw], rq[shw], pch = 16, cex = 0.35, col = pt_col, las = 1,
       xlab = "Fitted interior mean", ylab = "Quantile residual",
       main = "(a) Residuals vs fitted")
  graphics::abline(h = 0, lty = 2); graphics::lines(stats::lowess(fm, rq), lwd = 1.8)

  qq <- stats::qqnorm(rq, plot.it = FALSE)
  graphics::plot(qq$x[shw], qq$y[shw], pch = 16, cex = 0.35, col = pt_col, las = 1,
       main = "(b) Normal QQ plot", xlab = "Theoretical quantile",
       ylab = "Sample quantile")
  stats::qqline(rq, lwd = 1.8)
  graphics::legend("topleft",
         legend = c("random subsample", sprintf("most extreme %d", n_extreme)),
         pch = 16, col = c(COL_BLUE, COL_ORANGE), bty = "n", cex = 0.75)

  if (has_cov) {
    cov_vals <- data[[covariate]]
    graphics::plot(cov_vals[shw], rq[shw], pch = 16, cex = 0.35, col = pt_col, las = 1,
         xlab = covariate_lab, ylab = "Quantile residual",
         main = "(c) Residuals vs covariate")
    graphics::abline(h = 0, lty = 2); graphics::lines(stats::lowess(cov_vals, rq), lwd = 1.8)
  }

  dens <- stats::density(rq)
  graphics::plot(dens, lwd = 1.8, las = 1,
       main = sprintf("(%s) Residual density", if (has_cov) "d" else "c"),
       xlab = "Quantile residual", ylab = "Density",
       xlim = range(c(dens$x, -3, 3)))
  xx <- seq(-4, 4, length.out = 300)
  graphics::lines(xx, stats::dnorm(xx), lty = 2, lwd = 1.4)
  graphics::legend("topright", legend = c("residuals", "N(0,1)"), lty = c(1, 2),
         lwd = c(1.8, 1.4), bty = "n", cex = 0.85)

  invisible(list(residuals = rq, deviance = stats::deviance(fit),
                 AIC = stats::AIC(fit), BIC = fit$sbc,
                 filliben = fil, shapiro = sw))
}
