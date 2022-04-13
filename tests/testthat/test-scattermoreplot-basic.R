
test_that("scattermoreplot does not fail on trivial data", {
  expect_silent(scattermoreplot(rnorm(10), rnorm(10)))

  expect_silent(scattermoreplot(rnorm(10), rnorm(10), col = "red"))

  expect_silent(scattermoreplot(rnorm(10), rnorm(10), col = rainbow(10), xlim = c(-3, 3), ylim = c(-3, 3)))
})
