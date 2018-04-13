#setwd("C:/Users/user/Desktop/Umich Stat/2018 Winter/STAT 503/Project")
#labels <- readr::read_table2("./cifar-10-batches-bin/batches.meta.txt",col_names = "Class")[-11,]
load("../Data/cifar_10_grey.RData")
load("../Data/train_cifar_10.RData")

library("dplyr")

airplane_train_index = which(train_class==1)
airplane_test_index = which(train_class==1)
automobile_train_index = which(train_class==2)
automobile_test_index = which(train_class==2)
ship_train_index = which(train_class==9)
ship_test_index = which(train_class==9)
truck_train_index = which(train_class==10)
truck_test_index = which(train_class==10)

save_list = paste0("img",1:5000)

#airplane_train

for(i in 1:5000){
  tmp = 
    array(c(train_R[airplane_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[airplane_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[airplane_train_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/airplane_train.RData")
remove(list=save_list)

#automobile_train

for(i in 1:5000){
  tmp = 
    array(c(train_R[automobile_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[automobile_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[automobile_train_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/automobile_train.RData")
remove(list=save_list)

#ship_train

for(i in 1:5000){
  tmp = 
    array(c(train_R[ship_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[ship_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[ship_train_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/ship_train.RData")
remove(list=save_list)

#truck_train

for(i in 1:5000){
  tmp = 
    array(c(train_R[truck_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[truck_train_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[truck_train_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/truck_train.RData")
remove(list=save_list)


#airplane_test
save_list = paste0("img",1:1000)

for(i in 1:1000){
  tmp = 
    array(c(train_R[airplane_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[airplane_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[airplane_test_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/airplane_test.RData")
remove(list=save_list)

#automobile_test

for(i in 1:1000){
  tmp = 
    array(c(train_R[automobile_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[automobile_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[automobile_test_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/automobile_test.RData")
remove(list=save_list)

#ship_test

for(i in 1:1000){
  tmp = 
    array(c(train_R[ship_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[ship_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[ship_test_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/ship_test.RData")
remove(list=save_list)

#truck_test

for(i in 1:1000){
  tmp = 
    array(c(train_R[truck_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_G[truck_test_index[i],] %>% as.numeric() %>% matrix(32,32),
            train_B[truck_test_index[i],] %>% as.numeric() %>% matrix(32,32)),
          dim=c(32,32,3))
  assign(paste0("img",i),tmp)
  remove(tmp)
}

save(list=save_list, file="../Result/truck_test.RData")
remove(list=save_list)
