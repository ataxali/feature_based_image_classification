####################################################
# Course : STAT 503
# File: Final Project - Image Classification
# Components : PCA feature extraction component  
# Author: Yung-Chun LEE
####################################################

get_pca_infos = function(data,number_of_pcs){
  tmp = 
    t(as.matrix(test_grey)) %*% as.matrix(test_grey) %>%
    eigen()
  tmp_eigen_value = t$values[1:number_of_pcs]
  tmp_pca_loadings = t$vectors[,1:number_of_pcs]
  
  return(list(eigen_values = tmp_eigen_value,
              pca_loading = tmp_pca_loadings))
  remove(tmp,tmp_eigen_value,tmp_pca_loadings)
}


pca_feature_extraction = function(target_data,loading_data,number_of_features){
  df_pca_loagings = get_pca_infos(loading_data,number_of_pcs = number_of_features)[[2]]
  pc_transformed_data = as.matrix(target_data) %*% df_pca_loagings
  return(pc_transformed_data)
  
  remove(df_pca_loagings, pc_transformed_data)
}
