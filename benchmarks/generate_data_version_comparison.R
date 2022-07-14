library(scattermore)

#preload data sizes array
data_sizes = c()
size = 10
while (size <= 1e7){
    data_sizes <- append(data_sizes, size)
    size = size * 10
}

data = c()
time_scattermore = c()
time_r = c()
for (d in data_sizes) {
current_data <- cbind(rnorm(d), rnorm(d))
    for (m in 1:10) {
        data <- append(data, d)

        t_scattermore <- system.time(plot(rgba_int_to_raster(rgbwt_to_rgba_int(scatter_points_rgbwt(current_data)))))
        t_r <- system.time(plot(current_data, pch='.'))

        time_scattermore <- append(time_scattermore, t_scattermore['elapsed'])
        time_r <- append(time_r, t_r['elapsed'])
    }
}

df = data.frame(data, time_scattermore, time_r)

if (!dir.exists("data")) dir.create("data")
saveRDS(df, file="data/version_comparison.Rda")