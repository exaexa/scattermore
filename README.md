# scattermore 🎆 

## Fast Scatterplots with More Points

[![R-CMD-check](https://github.com/Teri934/scattermore/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Teri934/scattermore/actions/workflows/R-CMD-check.yaml) [![pkgdown](https://github.com/Teri934/scattermore/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Teri934/scattermore/actions/workflows/pkgdown.yaml)   [![test-coverage](https://github.com/Teri934/scattermore/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Teri934/scattermore/actions/workflows/test-coverage.yaml) [![codecov](https://codecov.io/gh/teri934/scattermore/branch/master/graph/badge.svg?token=3COU4T231C)](https://codecov.io/gh/teri934/scattermore)


### Installation 💻
```r
devtools::install_github('teri934/scattermore')
```

### Short Description 📝
R package with implemented C-based conversion of large scatterplot data to rasters plus other operations such as data blurring or data alpha blending. Speeds up plotting of data with millions of points.


### Simple Usage 🖱️

```r
library(scattermore)
```

#### Make Histograms...

```r
histogram <- scatter_histogram(cbind(rnorm(1e5), rnorm(1e5)), xlim=c(-5,5), ylim=c(-5,5))
blurred_histogram <- apply_kernel_histogram(histogram, kernel_pixels=10)
rgbwt <- histogram_to_rgbwt(blurred_histogram)
raster <- rgba_int_to_raster(rgbwt_to_rgba_int(rgbwt))
plot(raster)
```

#### ... Colorize Points...
```r
rgbwt <- scatter_points_rgbwt(points, RGBA= c(64,128,192,50), xlim=c(-5,5), ylim=c(-5,5))
blurred_rgbwt <- apply_kernel_rgbwt(rgbwt)
raster <- rgba_int_to_raster(rgbwt_to_rgba_int(blurred_rgbwt))
plot(raster)
```

#### ... Merge...
```r
p1 <- scatter_points_rgbwt(points, RGBA= c(64,128,192,50), xlim=c(-5,5), ylim=c(-5,5))
p2 <- scatter_points_rgbwt(points, RGBA= c(192,128,64,50), xlim=c(-5,5), ylim=c(-5,5))

merged <- merge_rgbwt(p1,p2)
raster <- rgba_int_to_raster(rgbwt_to_rgba_int(merged))
plot(raster)
```

#### ... and Blend
```r
p1 <- scatter_points_rgbwt(points, RGBA= c(64,128,192,50), xlim=c(-5,5), ylim=c(-5,5))
p2 <- scatter_points_rgbwt(points, RGBA= c(192,128,64,50), xlim=c(-5,5), ylim=c(-5,5))

p1_frgba <- rgbwt_to_rgba_float(p1)
p2_frgba <- rgbwt_to_rgba_float(p2)
blended <- blend_rgba_float(p1_frgba,p2_frgba)
raster <- rgba_int_to_raster(rgba_float_to_rgba_int(blended))
plot(raster)
```
#### You can find more information in vignettes.

### Really Fast ⏩

Compare `scattermore` with default R functionality. `Scattermore2` only creates raster graphics for the plots, its result can be plotted afterwards.

```r
# create 10 million 2D datapoints
points <- cbind(rnorm(1e7),rnorm(1e7))
```
```r
# plot the datapoints and see how long it takes
system.time(plot(rgba_int_to_raster(rgbwt_to_rgba_int(scatter_points_rgbwt(points, RGBA= c(64,128,192,50), xlim=c(-5,5), ylim=c(-5,5))))))

   user  system elapsed 
  0.743   0.216   0.959 
```

You should see something like this:

<kbd><img src="https://raw.githubusercontent.com/teri934/scattermore/master/pictures/blue_circle.png" width="500" height="500"></kbd>

Now the default:

```r
system.time(plot(points, pch='.', xlim=c(-5,5), ylim=c(-5,5), col=rgb(0.25,0.5,0.75,0.04)))

   user  system elapsed 
  6.944   0.060   7.012 
```


### Scattermore2 and Archaelogy 🦴

Nice examples for creating histograms from archaelogical data. Smithsonian Institute provides a lot of interesting data, including [mammoth skeleton](https://3d.si.edu/explorer/woolly-mammoth) 
and [T-rex skeleton eating triceratops skeleton](https://3d.si.edu/object/3d/tyrannosaurus-rex:d8c62d28-4ebc-11ea-b77f-2e728ce88125).


<kbd><img src="https://raw.githubusercontent.com/teri934/scattermore/master/pictures/mammoth_blurred.png" width="300" height="300"></kbd> &nbsp;&nbsp;&nbsp; <kbd><img src="https://raw.githubusercontent.com/teri934/scattermore/master/pictures/trex.png" width="300" height="300"></kbd>
