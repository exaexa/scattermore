test_that("pixels do not overlap", {
  histogram <- scatter_lines_histogram(matrix(0.95*cbind(sin(pi*1:6/3), cos(pi*1:6/3), sin(pi*2:7/3), cos(pi*2:7/3)),ncol=4,byrow=F))

  expect_equal(1, max(histogram))
})
