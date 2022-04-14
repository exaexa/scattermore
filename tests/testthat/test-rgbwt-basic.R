
test_that("rgbwt does not fail on different colorizations", {
  expect_silent(scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5))))

  # palette
  v <- c(255, 0, 0, 100, 0, 255, 0, 25, 0, 0, 255, 50, 0, 0, 0, 100)
  palette <- array(v, c(4, 4))
  map <- rep(c(1, 2, 3, 4), each = 25000)
  expect_silent(scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)), map = map, palette = palette))

  # color for each point
  v <- c(255, 0, 0, 100, 0, 255, 0, 10, 0, 0, 255, 10, 0, 0, 0, 0)
  colors <- array(v, c(4, 100000))
  expect_silent(scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)), RGBA = colors))
})

test_that("apply_kernel_rgbwt does not fail with different filters", {
  rgbwt <- scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)))

  expect_silent(apply_kernel_rgbwt(rgbwt))

  expect_silent(apply_kernel_rgbwt(rgbwt, filter = "square"))

  expect_silent(apply_kernel_rgbwt(rgbwt, filter = "gauss"))

  expect_silent(apply_kernel_rgbwt(rgbwt, filter = "own", mask = array(1, c(5, 5))))
})
