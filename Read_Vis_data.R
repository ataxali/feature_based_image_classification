# Read binary file and convert to integer vectors
# [Necessary because reading directly as integer() 
# reads first bit as signed otherwise]
#
# File format is 10000 records following the pattern:
# [label x 1][red x 1024][green x 1024][blue x 1024]
# NOT broken into rows, so need to be careful with "size" and "n"
#
# (See http://www.cs.toronto.edu/~kriz/cifar.html)
setwd("C:\\Users\\amant\\Desktop\\Winter2018\\Stats503\\final_project\\trunk")
library(tidyverse)
library(MASS)
#==================#
#  code reference: #
#==================#
##the code below is from the URL:
##https://stackoverflow.com/questions/32113942/importing-cifar-10-data-set-to-r



#==================#
#  Data processing #
#==================#

#===============#
# Training data #
#===============#

labels <- readr::read_table2("./cifar-10-batches-bin/batches.meta.txt",col_names = "Class")[-11,]
images.rgb <- list()
train_class =  list()
train_R = list()
train_G = list()
train_B = list()
num.images = 10000 # Set to 10000 to retrieve all images per file to memory

# Cycle through all 5 binary files
for (f in 1:5) {
  to.read <- file(paste("cifar-10-batches-bin/data_batch_", f, ".bin", sep=""), "rb")
  for(i in 1:num.images) {
    l <- readBin(to.read, integer(), size=1, n=1, endian="big")
    r <- as.integer(readBin(to.read, raw(), size=1, n=1024, endian="big"))
    g <- as.integer(readBin(to.read, raw(), size=1, n=1024, endian="big"))
    b <- as.integer(readBin(to.read, raw(), size=1, n=1024, endian="big"))
    index <- num.images * (f-1) + i
    images.rgb[[index]] = data.frame(r, g, b)
    train_R[[index]] = r
    train_G[[index]] = g
    train_B[[index]] = b
    train_class[[index]] = l+1
  }
  close(to.read)
  remove(l,r,g,b,f,i,index, to.read)
}

train_R = 
  train_R %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
train_G = 
  train_G %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
train_B = 
  train_B %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
train_class = 
  train_class %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
colnames(train_class)="Class"

colnames(train_R) = paste0("R",1:1024)
colnames(train_G) = paste0("G",1:1024)
colnames(train_B) = paste0("B",1:1024)

save(train_R,train_G,train_B,train_class, file = "./Data/train_cifar_10.RData")

#===========#
# Test data #
#===========#

test_class =  list()
test_R = list()
test_G = list()
test_B = list()
num.images = 10000

test.read <- "cifar-10-batches-bin/test_batch.bin"
for(i in 1:num.images) {
  l <- readBin(test.read, integer(), size=1, n=1, endian="big")
  r <- as.integer(readBin(test.read, raw(), size=1, n=1024, endian="big"))
  g <- as.integer(readBin(test.read, raw(), size=1, n=1024, endian="big"))
  b <- as.integer(readBin(test.read, raw(), size=1, n=1024, endian="big"))
  index <- num.images * (1-1) + i
  test_R[[index]] = r
  test_G[[index]] = g
  test_B[[index]] = b
  test_class[[index]] = l+1
}
remove(l,r,g,b,i,index, test.read)

test_R = 
  test_R %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
test_G = 
  test_G %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
test_B = 
  test_B %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
test_class = 
  test_class %>%
  do.call(cbind,.) %>%
  t() %>% as.tibble()
colnames(test_class)="Class"

colnames(test_R) = paste0("R",1:1024)
colnames(test_G) = paste0("G",1:1024)
colnames(test_B) = paste0("B",1:1024)

save(test_R,test_G,test_B,test_class, file = "./Data/test_cifar_10.RData")

# function to run sanity check on photos & labels import


#==============#
#  Draw Images #
#==============#

drawImage <- function(index) {
  # Testing the parsing: Convert each color layer into a matrix,
  # combine into an rgb object, and display as a plot
  img <- images.rgb[[index]]
  img.r.mat <- matrix(img$r, ncol=32, byrow = TRUE)
  img.g.mat <- matrix(img$g, ncol=32, byrow = TRUE)
  img.b.mat <- matrix(img$b, ncol=32, byrow = TRUE)
  img.col.mat <- rgb(img.r.mat, img.g.mat, img.b.mat, maxColorValue = 255)
  dim(img.col.mat) <- dim(img.r.mat)
  
  # Plot and output label
  library(grid)
  grid.raster(img.col.mat, interpolate=FALSE)
  
  # clean up
  remove(img, img.r.mat, img.g.mat, img.b.mat, img.col.mat)
  
  labels[[1]][images.lab[[index]]]
}

drawImage(sample(1:(num.images*5), size=1))

