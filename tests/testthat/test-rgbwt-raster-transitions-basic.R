
test_that("rgbwt -> rgba_int -> raster transition does not fail on trivial data", {
  rgbwt <- scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)))
  rgba_int <- expect_silent(rgbwt_to_rgba_int(rgbwt))
  raster <- expect_silent(rgba_int_to_raster(rgba_int))
})

test_that("rgbwt -> rgba_float -> rgba_int -> raster transition does not fail on trivial data", {
  rgbwt <- scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)))
  rgba_float <- expect_silent(rgbwt_to_rgba_float(rgbwt))
  rgba_int <- expect_silent(rgba_float_to_rgba_int(rgba_float))
  raster <- expect_silent(rgba_int_to_raster(rgba_int))
})
