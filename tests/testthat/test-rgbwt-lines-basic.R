test_that("apply_kernel_rgbwt does not fail with different filters", {
  rgbwt <- expect_silent(scatter_lines_rgbwt(matrix(rnorm(40000),ncol=4,byrow=F)))

  expect_silent(apply_kernel_rgbwt(rgbwt))

  expect_silent(apply_kernel_rgbwt(rgbwt, filter = "square"))

  expect_silent(apply_kernel_rgbwt(rgbwt, filter = "gauss"))

  expect_silent(apply_kernel_rgbwt(rgbwt, filter = "own", mask = array(1, c(5, 5))))
})
