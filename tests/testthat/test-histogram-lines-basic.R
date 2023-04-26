
test_that("scatter_lines_histogram does not fail on trivial data", {
  expect_silent(scatter_lines_histogram(matrix(rnorm(40000),ncol=4,byrow=F)))
})

test_that("apply_kernel_histogram does not fail with different filters", {
  histogram <- scatter_lines_histogram(matrix(rnorm(40000),ncol=4,byrow=F))

  expect_silent(apply_kernel_histogram(histogram))

  expect_silent(apply_kernel_histogram(histogram, filter = "square"))

  expect_silent(apply_kernel_histogram(histogram, filter = "gauss"))

  expect_silent(apply_kernel_histogram(histogram, filter = "own", mask = array(1, c(5, 5))))
})

test_that("histogram_to_rgbwt does not fail", {
  histogram <- scatter_lines_histogram(matrix(rnorm(40000),ncol=4,byrow=F))

  expect_silent(histogram_to_rgbwt(histogram))

  rgba <- array(c(250, 128, 114, 255, 144, 238, 144, 255), c(4, 2))
  expect_silent(histogram_to_rgbwt(histogram, RGBA = rgba))
})
