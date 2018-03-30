
require(dplyr)

Strata_srs_cv_index = function(class_index = train_class, K=10){
  num_class = length(table(class_index))
  class_len = table(class_index)
  
  ## tibble to store cv index length for each class
  
  cv_index_len = matrix(NA,ncol = num_class, nrow=K) %>%as.tibble()
  cv_index_len[1:K-1,] = class_len * 1/K
  cv_index_len[K,] = class_len - apply(cv_index_len[1:K-1,],2,sum)
  
  #create pseudo K-fold cv index for each class
  
  cv_index = 
    lapply(1:num_class, function(x) sample(rep(x=1:K, times=cv_index_len[[x]]))) %>%
    unlist(.)
  
  ##create seq_index
  seq_index = 1:sum(class_len)
  ##combine class_index and cv_index and determine 
  ##each fold training and testing for K folds
  
  df = 
    cbind(seq_index,cv_index) %>%
    as.data.frame() %>%
    dplyr::mutate(class_index= sort(class_index[[1]])) 
  
  
  make_fold_with_cv_index = function(x){
    training = 
      df %>% 
      filter(cv_index != x) %>%
      dplyr::select(seq_index)
    test = 
      df %>% 
      filter(cv_index == x) %>%
      dplyr::select(seq_index)
    
    return(list(training=training[[1]],test=test[[1]]))
  }
  
  out = lapply(1:K, function(x) make_fold_with_cv_index(x))
  #give meaningful names
  names(out) = paste("fold",1:K,sep="")
  return(out)
}
