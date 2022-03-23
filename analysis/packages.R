# install the following packages for plotting performance evaluation
# renv package
# renv::init() # automatically install the packages declared in the lockfile
# renv::snapshot() # generate and update renv.lock
# renv::history() # view past versions of renv.lock
# renv::revert() # pulls out a previous version of renv.lock
# renv::restore() # restore state of the project

library(agricolae)
library(plyr) 
library(dplyr)
library(ggplot2)
# library(cowplot)
library(gplots)
library(DAAG)
library(e1071)
library(outliers)
library(reshape2)
library(car)
library(ggpubr)