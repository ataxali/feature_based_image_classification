####################################################
# Course : STAT 503
# File: Final Project - Image Classification
# Components : Plot grey scale image  
# Author: Yung-Chun LEE
####################################################

library(ggplot2)
library(gridExtra)

plt_raster_image = function(original_image,pca_loading){
  ## Need packages: gridExtra, ggplot2
  #original_image : [Vector-- 1 x 1024] grey scale pixels
  #pca_loading : [Matrix-- 1024 x n ] n-PCS pca loadings for transformation
  
  number_of_pcs = ncol(pca_loading)
  df_pca = lapply(1:number_of_pcs, 
                  function(x) as.numeric(original_image)* pca_loading[,x] )
  
  #====================#
  # Plot raster images #
  #====================#  
  
  plot_raster_image = function(data){
    tmp = 
      ggplot(data=vector_into_df(data), 
             aes(x = x, y = y)) +
      geom_raster(aes(fill = val), interpolate = TRUE)+
      scale_fill_gradientn(colours = grey.colors(255, start=0, end=1, gamma=1.2, alpha = NULL),
                           guide = FALSE) +
      labs(x="",y="")+
      theme_void() +
      theme(axis.ticks.y = element_blank(),
            axis.ticks.x = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_blank())+
      coord_fixed(ratio = 1)
    return(tmp)
  }
  
  #=====================#
  # Plot original image #
  #=====================#
  
  plot_original_image = 
    plot_image(original_image)+
    ggtitle("Original Image")+
    theme(plot.title = element_text(size=20))
  
  #=================#
  # Plot PCA images #
  #=================#
  
  plot_pca_images = 
    lapply(1:number_of_pcs, 
           function(x) plot_image(df_pca[[x]])+ggtitle(paste("PC",x)))
  
  #=================#
  # Organize Output #
  #=================#
  
  gs = append(list(plot_original_image),plot_pca_images)
  lay_main = rbind(c( 1, 1, 1,NA,NA),
                   c( 1, 1, 1,NA,NA),
                   c( 1, 1, 1,NA,NA)) 
  lay_pca = matrix(NA)
  if((length(gs)-1)%%5 == 0){
    lay_pca = matrix(2:length(gs),ncol=5,byrow = T)
  }else {
    lay_pca = matrix(c(2:length(gs),rep(NA,5-(length(gs)-1)%%5)),ncol=5,byrow = T)
  }
  lay = rbind2(lay_main,lay_pca)
  grid.arrange(grobs = gs, layout_matrix = lay)
}

#plt_raster_image(test_grey[2,],tmp_pca_loadings)
