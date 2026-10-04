dat <- simulate_bic(300, seed = 42)
fit <- suppressMessages(
  bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
)

test_that("g-computation decomposition is an exact identity", {
  g <- bic_gcomp(fit, "T", dat)
  expect_equal(unname(g["tau"]), unname(g["tau_alpha"] + g["tau_mu"]),
               tolerance = 1e-12)
})

test_that("g-computation recovers the known truth approximately", {
  g <- bic_gcomp(fit, "T", dat)
  truth <- attr(dat, "truth")
  expect_lt(abs(g["tau"] - truth$tau), 0.03)
})

test_that("CCNC block decomposition is additive, with a near-zero cross term", {
  cv <- bic_curvature(fit, "T", dat)
  expect_equal(cv$BdT, cv$BdT_discrete + cv$BdT_continuous, tolerance = 1e-8)
  expect_lt(abs(cv$cross_term), 1e-6)
  expect_gte(cv$BdT, 0)
  expect_gte(cv$BdT_discrete, 0)
  expect_gte(cv$BdT_continuous, 0)
})

test_that("ICIM is non-negative, additive across blocks, and types are valid", {
  cv <- bic_curvature(fit, "T", dat)
  icim <- bic_icim(cv)
  expect_true(all(icim$ICIM >= -1e-10))
  expect_equal(icim$ICIM, icim$ICIM_discrete + icim$ICIM_continuous,
               tolerance = 1e-8)
  expect_true(all(icim$type %in% c("discrete", "continuous", "mixed")))
})

test_that("the sensitivity bound is attained at the stated Gamma_star", {
  g <- bic_gcomp(fit, "T", dat)
  cv <- bic_curvature(fit, "T", dat)
  sens <- bic_sensitivity(cv, fit, "T", dat, tau_hat = g["tau"])
  expect_gt(sens$L1, 0)
  if (!is.na(sens$Gamma_star)) {
    expect_equal(unname(sens$bound(sens$Gamma_star)), unname(abs(g["tau"])),
                 tolerance = 1e-8)
  }
})

test_that("bic_fit dispatches BEZI for one boundary and BEINF for two", {
  fit1 <- suppressMessages(bic_fit(y ~ T, nu.formula = ~T, data = dat))
  expect_equal(fit1$family[1], "BEZI")

  dat2 <- dat
  dat2$y[1:5] <- 1  ## introduce a second boundary at one
  fit2 <- suppressMessages(
    bic_fit(y ~ T, nu.formula = ~T, tau.formula = ~T, data = dat2)
  )
  expect_equal(fit2$family[1], "BEINF")
})
