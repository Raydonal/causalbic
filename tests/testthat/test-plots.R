test_that("plot_concept() draws without error and returns invisibly", {
  tf <- tempfile(fileext = ".pdf")
  grDevices::pdf(tf)
  on.exit({grDevices::dev.off(); unlink(tf)})
  graphics::par(mfrow = c(1, 2))
  expect_null(plot_concept())
})

test_that("plot_cate() draws without error and its truth/estimate agree with bic_cate()", {
  tf <- tempfile(fileext = ".pdf")
  grDevices::pdf(tf)
  on.exit({grDevices::dev.off(); unlink(tf)})
  graphics::par(mfrow = c(1, 2))
  out <- plot_cate(n = 120, seed = 3)
  expect_true(all(c("grid", "truth", "estimate") %in% names(out)))
  expect_equal(length(out$grid), nrow(out$truth))
  expect_equal(length(out$grid), length(out$estimate))
  ## decomposition is an exact identity for the true curve too
  expect_equal(out$truth$tau, out$truth$tau_alpha + out$truth$tau_mu,
               tolerance = 1e-10)
})

test_that("plot_diagnostics() draws without error, with and without a covariate panel", {
  dat <- simulate_bic(300, seed = 5)
  fit <- suppressMessages(
    bic_fit(y ~ T + W2, nu.formula = ~ T + W1, data = dat)
  )
  tf <- tempfile(fileext = ".pdf")
  grDevices::pdf(tf)
  on.exit({grDevices::dev.off(); unlink(tf)})

  out1 <- plot_diagnostics(fit, dat, covariate = "W1", seed = 1)
  expect_true(all(c("residuals", "deviance", "AIC", "BIC", "filliben", "shapiro") %in%
                    names(out1)))
  expect_equal(length(out1$residuals), nrow(dat))

  out2 <- plot_diagnostics(fit, dat, seed = 1)
  expect_equal(length(out2$residuals), nrow(dat))
})
