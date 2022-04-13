
test_that("scattermoreplot does not fail on trivial data", {
  expect_silent(scattermoreplot(rnorm(10), rnorm(10), col = rainbow(10)))
})
