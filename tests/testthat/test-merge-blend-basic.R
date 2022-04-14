
test_that("merge does not fail on trivial data", {
p1 <- scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)), RGBA= c(64,128,192,50))
p2 <- scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)))
expect_silent(merge_rgbwt(p1, p2))
})

test_that("blend does not fail on trivial data", {
p1_float <- rgbwt_to_rgba_float(scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5)), RGBA= c(64,128,192,50)))
p2_float <- rgbwt_to_rgba_float(scatter_points_rgbwt(cbind(rnorm(1e5), rnorm(1e5))))
expect_silent(blend_rgba_float(p1_float, p2_float))
})
