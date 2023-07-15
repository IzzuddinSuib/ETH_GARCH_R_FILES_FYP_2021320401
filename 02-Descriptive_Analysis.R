# Muhammad Izzuddin Bin Suib
# 2021320401
# CS790
# Ethereum Price Forecasting and Volaltility Modeling Using GARCH

# Descriptive Analysis
# Paper at <>
#
# This script will use the financial data from previous script,
# producing Figure 01 at the end of its execution

# OPTIONS
n_largest <- 5 # number of largest absolute returns to plot

# END OPTIONS

# load libraries
library(cowplot)
library(tidyverse)
library(fredr)  # fredr replaces GetBCBData
library(forecast)

# close all existing plot windows
graphics.off()

# change directory
my_d <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(my_d)
#setwd('/Users/izzuddin/Desktop/Final Sem/DSC 790 - Project/data/')

# make sure folder "fig" exists
if (!dir.exists('figs')) dir.create('figs')

# source functions 
source('fcts/garch_fcts.R')

# get price data
df_prices <- read_rds('data/RAC-GARCH-Data.rds')
series_name <- df_prices$series_name[1]

# create first plot
p1 <- ggplot(df_prices, aes(x = ref.date, y = price.adjusted)) + 
  geom_line() + 
  labs(title = paste0('Prices of ', series_name),
       subtitle = paste0('Total nominal arithmetic return equals to ', 
                         my_perc(total_ibov_ret),
                         ' (', my_perc(ret_ibov_year), ' per year)\n'),
       x = '',
       y = 'Ethereum Price ($)',
       caption = 'Data from Yahoo Finance') + 
  theme_bw(base_family = "TT Times New Roman") 

# calculate largest absolute price variations
largest_tab <- df_prices %>%
  group_by(ticker) %>%
  top_n(abs(log_ret), n = n_largest)

# create second plot
p2 <- ggplot(df_prices, 
             aes(x = ref.date, y = log_ret)) + 
  geom_line() + 
  labs(title = paste0('Nominal Daily Log Returns of ', series_name),
       subtitle = paste0('Red circles represent the largest ', n_largest, 
                         ' absolute price variations in the sample'),
       x = '',
       y = 'Log Returns',
       caption = 'Data from Yahoo Finance') + 
  theme_bw(base_family = "TT Times New Roman") +
  geom_point(data = largest_tab, aes(x = ref.date, y = log_ret), 
             size = 3, color = 'red'  ) +
  scale_y_continuous(labels = scales::percent) + 
  labs(size = 'Absolute Price Variation') # + 
scale_color_brewer(palette = 'BrBG')

# bind plots together
p <- plot_grid(p1, p2, nrow = 2, 
               labels = 'AUTO')

# show and save
# ERROR in old Code: invalid 'bg' value
#x11() ; p ; ggsave(filename = paste0('figs/fig02_', series_name, '_prices_returns.png'), 
#                  plot = p) 

x11() ; p1 ; ggsave(filename = paste0('figs/fig02a_', series_name, '_prices.png'), 
                    plot = p1)
x11() ; p2 ; ggsave(filename = paste0('figs/fig02b_', series_name, '_returns.png'), 
                    plot = p2)

# build autocorrelagram
p <- ggAcf(x = df_prices$log_ret, lag.max = 10) +
  labs(title = paste0('Autocorrelogram for the Log Returns of ', series_name)) +
  theme_bw(base_family = "TT Times New Roman")

x11()  ; p ; ggsave('figs/fig03_autocorrelation_logret.png')
