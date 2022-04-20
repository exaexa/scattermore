
test_that("geom scattermore does not fail on trivial data", {
  d <- data.frame(x = rnorm(1e5), y = rnorm(1e5))

  expect_silent(geom_scattermore(
    aes(d$x, d$y, color = d$x),
    pointsize = 3,
    alpha = 0.1,
    pixels = c(1000, 1000),
    interpolate = TRUE
  ))
})

test_that("geom scattermost does not fail on trivial data", {
  d <- data.frame(x = rnorm(1e5), y = runif(1e5))

  expect_silent(geom_scattermost(
    cbind(rnorm(1e6), runif(1e6)),
     col = rainbow(100, alpha = 0.05)[1 + 99 * d[, 2]],
     pointsize = 2,
    pixels = c(700, 700)
  ))
})
