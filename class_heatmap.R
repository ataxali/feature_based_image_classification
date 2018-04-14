require(dplyr)
require(ggplot2)



##class_heatmap function: 
# function to convert predicted result into heatmap of classification table. 

class_heatmap = function(df,title_name = "Heatmap of"){ 
  
  ##Input
  # df: a two columns data.frame, with 
  #       + 1st column : test class
  #       + 2nd column : predicted class
  #
  # title_names : The name desired to put in the heatmap. 
  #                Default: "Heatmap of "
  ##Output
  # Out: will be a list of 9, containing information created by ggplot2
  
  
  #preprocess the format of input data 
  colnames(df) = c("test","pred")
  plt_data = 
    df %>% ftable() %>% as.data.frame() %>%
    mutate(heat = ifelse(test==pred, 0, Freq),
           freq = ifelse(Freq==0,"",as.character(Freq))) %>%
    ## freq is used for adding frequencies count on the heatmap
    #       
    ## heat is used for the filling parameter, 
    #        since we want to correctly classified to be not noticable.
    dplyr::select(-Freq)
  
  #calculate the accuray rate for the subtitle
  accu = 1 - sum(plt_data$heat)/nrow(df)
  
  #calculate upper limits and mid point for heatmap scaling gradient 
  #
  ## n_class number of class
  #
  ## up_lim is defined by the possible number of error per class,
  #         i.e. total number of observations / number of class
  ## mid_point is set to be one-half of up_lim  
  n_class = dim(ftable(df))[1]
  up_lim = nrow(df)/n_class
  mid_point = up_lim/2
  
  #create Out(the ouput heatmap)
  Out = 
    ggplot(data=plt_data, aes(x= test, y= pred))+ 
    #add frequencies 
    geom_tile(aes(fill= heat))+
    labs(x = "True Class",
         y = "Predicted Class",
         subtitle = paste("Accuracy = ",accu, "%"),
         title = title_name)+
    scale_fill_gradient2(low = "white", mid = "yellow2", high = "red", 
                         midpoint = mid_point, limits=c(0,up_lim),
                         breaks = ceiling(seq(0,n_class,length.out = 3)),
                         name = "Err")+
    guides(fill = guide_colorbar(barwidth = 0.5, nbin=n_class,
                                 barheight = 12, ticks = F))+
    geom_text(aes(label = freq), color = "black", size = 4)+
    #theme settings:
    # title size =20 , subtitle size =16 
    # Legend bar background details
    theme(plot.title = element_text(size=13),
          plot.subtitle=element_text(size=11),
          legend.background = 
            element_rect(fill="grey92",size=0.5, linetype="solid",color="black"))+
    # fix x,y axis ratio
    coord_fixed()
  return(Out)
}


