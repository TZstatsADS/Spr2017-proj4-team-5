update.weights=function(data,weights,target)
{
pred=which.max(weights%*%t(data.matrix(data)))
tau=(t(data.matrix(weights[pred,]-weights[target,]))%*%t(data.matrix(data))+1)/(2*sum(data^2))
if(pred!=target)
{
weights[pred,]=as.vector(weights[pred,])-as.vector(unlist(min(tau[1,1],0.008)*data))
weights[target,]=as.vector(weights[target,])+as.vector(unlist(min(tau[1,1],0.008)*data))
  
  
}
  
return(weights)  
  
  
  
  
  
}

predict.mira=function(data,weights)
{
 return(apply(weights%*%t(data.matrix(data)),2,which.max)) 
}

mira=function(x,y,levels=length(unique(y)))
{
#y=as.numeric(as.factor(y))
weights=matrix(rep(1,levels*length(x[1,])),nrow=levels)  
weights=update.weights(x[1,],weights,y[1])
pred=predict.mira(x,weights)
errorid=which(pred!=y)
diff=1
while(diff>0 && (length(errorid)!=0))
{
weights=update.weights(x[errorid[1],],weights,y[errorid[1]])
pred=predict.mira(x,weights)
errorid2=which(pred!=y)
diff=length(errorid)-length(errorid2)
errorid=errorid2
}
return(weights)               
}

df<- read.csv("df1.csv")
x=df[,-c(1,2)]
y=df$auther.id
data=x[1,]
target=y[1]
a=weights%*%t(data.matrix(data))
weights=mira(x,y)
trainid=sample(1:577,300)
trainx=x[trainid,]
trainy=y[trainid]
testx=x[-trainid,]
testy=y[-trainid]
weights=mira(trainx,trainy)
o=predict.mira(testx,weights)
sum(testy==o)
115/277

run=function(){
  res=c()
  temp=c("df1.csv","df2.csv","df4.csv","df6.csv","df7.csv","df9.csv","df10.csv","df11.csv","df12.csv")
  for (i in 1:length(temp)) {
    df = read.csv(temp[i], header = TRUE)
    x=df[,-c(1,2)]
    y=as.numeric(as.factor(df$auther.id))
    trainid=sample(1:length(y),length(y)/2)
    trainx=x[trainid,]
    trainy=y[trainid]
    testx=x[-trainid,]
    testy=y[-trainid]
    weights=mira(trainx,trainy,levels=length(unique(y)))
    o=predict.mira(testx,weights)
    res[i]=sum(testy==o)/length(testy)
    cat(i)
    cat(' ')
  }
 return (res)
}
weights=mira(trainx,trainy)
