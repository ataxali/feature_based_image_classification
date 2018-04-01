
####################################################
# Course : STAT 503
# File: Final Project - Image Classification
# Data: CIFAR-10 
# Author: Yung-Chun LEE
####################################################

#**************#
# Color : Grey #
#**************#
#FLUX
source("../functions/Strata_srs_index.R")
source("../functions/pca_components.R")

#DESKTOP
# source("Strata_srs_cv_index.R")
# source("pca_components.R")

#**********#
# PACKAGES #
#**********#
library(dplyr)
library(e1071)
library(doParallel)

#***********#
# LOAD DATA #
#***********#
#FLUX
load("../Data/cifar_10_grey.RData")

#DESKTOP
# load("./Data/cifar_10_grey.RData")

#===============#
# Remove unnecessary data 
#===============#
remove(test_class,test_grey)

#====================#
# Parallel Setups
#====================#
number_of_cores = 4
#Cluster register
registerDoParallel(cores=number_of_cores)

#================#
# CV setups
#=================#
costs =exp(seq(-5,4,length.out = 30))
svm_cv_data = cbind(pca_feature_extraction(target_data=train_class,
                                           loading_data = train_class,
                                           number_of_features = 20),
                    train_grey)
svm_cv_formula = formula("Class ~.")
svm_cv_function = function(c) {
  tune.svm(svm_cv_formula, data = svm_cv_data, cost = c, kernels = "linear")
}

#============#
# Run parallel
#==============#
tune.out = 
  foreach(i = 1:length(costs)) %dopar%  svm_cv_function(costs[i])
#============#
# Save Result
#==============#
save(tune.out, file = "../Result/grey_linear_svm.RData")