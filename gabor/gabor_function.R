#Gabor filter
gabor_fn = function(sigma, theta, Lambda, psi, gamma, size){
    sigma_x = sigma
    sigma_y = sigma / gamma

    # Bounding box
    nstds = 10 # Number of standard deviation sigma
    xmax = max(abs(nstds * sigma_x * cos(theta)), abs(nstds * sigma_y * sin(theta)))
    xmax = ceiling(max(1, xmax))
    ymax = max(abs(nstds * sigma_x * sin(theta)), abs(nstds * sigma_y * cos(theta)))
    ymax = ceiling(max(1, ymax))
    xmin = -xmax
    ymin = -ymax
    y = matrix(rep(seq(ymin,ymax,length.out = size),size),byrow=T,ncol = size)
    x = t(matrix(rep(seq(xmin,xmax,length.out = size),size),byrow=T,ncol =size))
    #y, x = outer(c(ymin: ymax), c(xmin: xmax))

    # Rotation
    x_theta = x * cos(theta) + y * sin(theta)
    y_theta = -x * sin(theta) + y * cos(theta)

    gb = exp(-.5 * (x_theta ^ 2 / sigma_x ^ 2 + y_theta ^ 2 / sigma_y ^ 2)) * 
      cos(2 * pi / Lambda * x_theta + psi)
    
    tmp = gb[-13,-13]
    return (gb)
} 


# plot_image = function(data){
#   tmp = 
#     ggplot(data=reshape2::melt(data), 
#            aes(x = Var1, y = Var2)) +
#     geom_raster(aes(fill = value), interpolate = F)+
#     scale_fill_gradientn(colours = grey.colors(255, start=0, end=1, gamma=1.2, alpha = NULL),
#                          guide = FALSE) +
#     labs(x="",y="")+
#     theme(axis.ticks.y = element_blank(),
#           axis.ticks.x = element_blank(),
#           axis.text.y = element_blank(),
#           axis.text.x = element_blank())+
#     scale_y_reverse()
#   return(tmp)
# }

