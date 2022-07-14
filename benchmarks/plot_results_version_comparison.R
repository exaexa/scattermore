library(cowplot)
library(ggplot2)
library(reshape2)
library(sitools)

df <- readRDS(file="data/version_comparison.Rda")
df <- melt(df, id.vars='data', variable.name='method', value.name='time')

df$time <- df$time + 0.001 #zeros correction

if (!dir.exists("plots")) dir.create("plots")
ggsave(filename = file.path("plots","version_comparison.pdf"), width = 6, height = 4, units='in',
ggplot(df, aes(data, time, color = method)) +
    geom_point(position = position_jitter(width = 0.1, height = 0)) + # jitter pomaha kdyz je mereni hodne
    geom_smooth(se=F) +
    scale_x_log10("Number of points", labels = function(x)paste(x,'points')) +
    scale_y_log10("Time", labels = function(x)f2si(x, 's')) +
    #ylim(0, 50) +
    ggtitle("Performance of scattermore vs standard R plot function") +
    scale_color_manual(name = "Computations", labels = c("scattermore", "default R"), values = c("time_scattermore" = "red", "time_r" = "green")) +
    theme_cowplot(font_size = 9) +
    theme(panel.grid.major = element_line(color='#dddddd'))
)