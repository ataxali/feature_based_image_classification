gabor_function: 
 it's logorithm implemented in R

gabor_filter: 
5*8 filters setting
gabor_filter = matrix(NA,nrow=1024,ncol = 40)
theta = c(0,23,45,68,90,113,135,158)
for(i in 1:5){
  for(j in 1:8){
    gabor_filter[,(i-1)*8+j] =  as.vector(gabor_fn(i,theta[j],1,1,1,32))   
  }
}