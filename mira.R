update.weights=function(data,weights,target)
{
pred=which.max(weights%*%data)
tau=((weights[pred,]-weights[target,])%*%data+1)/(2*sum(data^2))
if(prediction!=target)
{
weights[pred,]=weights[pred,]-tau*data
weights[target,]=weights[target,]+tau*data
  
  
  
}
  
return(weights)  
  
  
  
  
  
}

predict.mira=function(data,weights)
{
 return(apply(weights%*%t(data)),2,which.max)) 
}

mira=function(x,y)
{
weights=matrix(rep(1,prod(dim(x)),nrow=length(unique(y))))  
weights=update.weights(x[1,],weights,y[1,])
pred=predict.mira(x,weights)
errorid=which(pred!=y)
while(!is.na(errorid))
{
weights=update.weights(x[errorid[1],],weights,y[errorid[1],])
pred=predict.mira(x,weights)
errorid=which(pred!=y)

  
}
return(weights)               
}