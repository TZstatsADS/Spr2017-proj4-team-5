
setwd("C:/Users/yftang/Documents/GitHub/Spr2017-proj4-team-5/lib/")
library(stringr)

data.lib="../data/nameset"
data.files=list.files(path=data.lib, "*.txt")

#data.files

## remove "*.txt"
query.list=substring(data.files, 
                     1, nchar(data.files)-4)

#query.list

## add a space
query.list=paste(substring(query.list, 1, 1), 
                 " ", 
                 substring(query.list, 
                           2, nchar(query.list)),
                 sep=""
)

# query.list

f.line.proc=function(lin, nam.query="."){
  
  # remove unwanted characters
  char_notallowed <- "\\@#$%^&?" # characters to be removed
  lin.str=str_replace(lin, char_notallowed, "")
  
  # get author id
  lin.str=strsplit(lin.str, "_")[[1]]
  author_id=as.numeric(lin.str[1])
  
  # get paper id
  lin.str=lin.str[2]
  paper_id=strsplit(lin.str, " ")[[1]][1]
  lin.str=substring(lin.str, nchar(paper_id)+1, nchar(lin.str))
  paper_id=as.numeric(paper_id)
  
  # get coauthor list
  lin.str=strsplit(lin.str, "<>")[[1]]
  coauthor_list=strsplit(lin.str[1], ";")[[1]]
  
  #print(lin.str)
  for(j in 1:length(coauthor_list)){
    if(nchar(coauthor_list[j])>0){
      nam = strsplit(coauthor_list[j], " ")[[1]]
      if(nchar(nam[1])>0){
        first.ini=substring(nam[1], 1, 1)
      }else{
        first.ini=substring(nam[2], 1, 1)
      }
    }
    last.name=nam[length(nam)]
    nam.str = paste(first.ini, last.name)
    coauthor_list[j]=nam.str
  }
  
  match_ind = charmatch(nam.query, coauthor_list, nomatch=-1)
  
  # print(nam.query)
  # print(coauthor_list)
  # print(match_ind)
  
  if(match_ind>0){
    
    coauthor_list=coauthor_list[-match_ind]
  }
  
  paper_title=lin.str[2]
  journal_name=lin.str[3]
  
  list(author_id, 
       paper_id, 
       coauthor_list, 
       paper_title, 
       journal_name)
}


data_list=list(1:length(data.files))

for(i in 1:length(data.files)){
  
  ## Step 0 scan in one line at a time.
  
  dat=as.list(readLines(paste(data.lib, data.files[i], sep="/")))
  data_list[[i]]=lapply(dat, f.line.proc, nam.query=query.list[i])
  
}




get.info<-function(n){
  # Input: n-the nameset
  # For each nameset, randomly split the data into train and test set equally.
  # Use train set to train the parameters needed for Naive Bayesian Classify based on Coauther.
  # Use Test set to predict the estimation and calculate the accuracy of Naive Bayesian based on Coauther.
  # 
  # Repeat the above process ten times for each nameset to get the mean accuracy and standard deviation of accuracy.  
  #  
  # 
  num.paper<-length(data_list[[n]])
  auther.id<-NULL
  coauther<-NULL
  for(i in 1:num.paper){
    auther.id[i]<-data_list[[n]][[i]][[1]]
    coauther<-unique(c(coauther,data_list[[n]][[i]][[3]]))
  }
  a.i<-factor(auther.id)
  uni.auther<-length(levels(a.i))
  levels(a.i)<-seq(uni.auther)
  auther.id<-a.i
  df<-data.frame(auther.id)
  
  num.coauther<-length(coauther)
  get.coauther<-function(i){
    coauthers<-rep(0,num.coauther)
    for(j in 1:length(data_list[[n]][[i]][[3]])){
      coauthers[which(data_list[[n]][[i]][[3]][j]==coauther)]<- 1
    }
    return(coauthers) 
  }
  ##########################################################
  #### build dataframe for auther coauther information######
  ##########################################################
  id_co<-NULL
  for(i in 1:num.paper){
    id_co<-rbind(id_co,get.coauther(i))
  }
  colnames(id_co)<-coauther
  df<-cbind(auther.id,id_co) 
  #df contains the auther coauther information in nameset 1: AGupta
  id.num.co<-apply(df[,-1],1,sum)
  df<-as.data.frame(cbind(id.num.co,df))
  freq.id<-as.data.frame(table(df$auther.id)/length(df$auther.id)) 
  # numbers of paper for each id
  colnames(freq.id)<-c("auther.id","Freq")
  num.id<-dim(freq.id)[1]
  
  start.time <- Sys.time()
  accuracy<-NULL
  
  for(s in 1:10){
    index<-c(2017,29,666,1024,38,97,10001,88,494,10)
    set.seed(index[s])
    ################################
    ####### Train Test set split####
    ################################
    
    sample_split<-function(i){
      
      Data<- df[df$auther.id==i,]
      bound <- floor(nrow(Data)/2)  #define 50 % of training and test set
      Data <- Data[sample(nrow(Data)), ]           #sample rows 
      df.train <- Data[1:bound, ]              #get training set
      df.test <- Data[(bound+1):nrow(Data), ]    #get test set
      return(list(df.train=df.train,df.test=df.test))
    }
    
    train<-NULL
    test<-NULL
    for(i in seq(num.id)){
      train[i]<-list(sample_split(i)[[1]])
      test[i]<-list(sample_split(i)[[2]])
    } 
    
    TT<-NULL
    for(i in 1:num.id){
      TT <- rbind(TT,test[[i]])
    }
    test_x<-TT[,-c(1,2)]  # test set as data.frame
    test_y<-TT[,2]        # test lable 
    
    
    
    #############################
    #### Train the parameter#####
    #############################
    NB_para<-function(data){
      # Input: df.train 
      # Output: 6 probability used for NB model
      
      paper.num<-dim(data)[1]
      p_0<-sum(data$id.num.co==0)/paper.num  
      #### P(N|X)
      p_1<-1-p_0  
      #### P(Co|x)
      colsum<-apply(data,2,sum)
      data<-rbind(data,colsum)
      p_s_cx<-sum(colsum>=2)/sum(colsum>=1)
      #### P(Seen|Co,X)
      p_u_cx<-1-p_s_cx
      #### P(Unseen|Co,X)
      total.num.co<-colsum[1]
      p_a_scx<-colsum/total.num.co    
      p_a_scx<-p_a_scx[-c(1,2)]             
      #### P(A|Seen,Co,X)
      p_a_ucx<-1/(num.coauther -sum(colsum>=1))  
      #### P(A|Unseen,Co,X)
      outcome<-list(P.N.X = p_0,
                    P.Co.X = p_1,
                    P.S.Co.X = p_s_cx,
                    P.U.Co.X = p_u_cx,
                    P.Ak.S.Co.X = p_a_scx,
                    P.Ak.U.Co.X = p_a_ucx
      )
      return(outcome)
    }
    
    P.N.X<-NULL
    P.Co.X <-NULL
    P.S.Co.X<-NULL
    P.U.Co.X<-NULL
    P.Ak.S.Co.X<-NULL
    P.Ak.U.Co.X<-NULL
    for(i in seq(num.id)){
      P.N.X[i]<-NB_para(train[[i]])$P.N.X
      P.Co.X[i]<-NB_para(train[[i]])$P.Co.X
      P.S.Co.X[i]<-NB_para(train[[i]])$P.S.Co.X
      P.U.Co.X[i]<-NB_para(train[[i]])$P.U.Co.X
      P.Ak.U.Co.X[i]<-NB_para(train[[i]])$P.Ak.U.Co.X
      P.Ak.S.Co.X[i]<-list(NB_para(train[[i]])$P.Ak.S.Co.X)
    }
    
    ###############################
    ######### Test Model###########
    ###############################
    
    freq.x<-NULL
    for(i in seq(num.id)){
      freq.x[i]<-dim(train[[i]])[1]  
    }
    px<-freq.x/sum(freq.x)  # px is the prior for the nameset
    
    
    
    #######################
    ##estimation model#####
    #######################
    NB_model<-function(data){
      # input: Test datafram
      # data.df=test_x
      # out<-NULL
      # for(m in seq(dim(data.df)[1])){
      # data = data.df[m,]
      if(sum(data)==0){
        out<-which.max(P.N.X)
      }
      else{
        condition<-function(id){
          i=id
          # i=id, k = k-th coauther
          P_Ak_X<-NULL
          
          significant<-length(P.Ak.S.Co.X[[i]][data>0])
          
          for(k in seq(significant)){
            P_Ak_X[k]<-P.Co.X[i] * ( P.S.Co.X[i] *       
                                       P.Ak.S.Co.X[[i]][data>0][k] + 
                                       P.Ak.U.Co.X[i] * P.U.Co.X[i])
          }
          return(prod(P_Ak_X))
        }
        target<-NULL
        for(i in seq(num.id)){ 
          target[i]<-condition(i)*px[i]
        }
        
        out <-which.max(target)
      }
      return(out)
    }
    est_y<-apply(test_x,1,NB_model) ## test estimate
    
    accuracy[s]<-sum(est_y==test_y)/length(test_y)
  }
  
  end.time <- Sys.time() 
  time_sclust <- end.time - start.time
  time_sclust
  
  mean(accuracy)
  sd(accuracy)
  # conclusion<-cat("Mean of Accuracy for Nameset ",n," is:",mean(accuracy),"\nSrdDev of Accuracy for Nameset  ",n," is:",sd(accuracy),"\nTime for Nameset  ",n," to process is",time_sclust)
  
  conclusion<-data.frame(Nameset=n,mean.accuracy=mean(accuracy),StdDev.accuracy=sd(accuracy))
  return(conclusion)
}

summary.all<-NULL
for(i in 1:length(data.files)){
  summary.all<- rbind(summary.all,get.info(i))
}
summary.all<-as.data.frame(summary.all)
summary.all$Nameset<-c("A Gupta","A Kumar","C Chen","D Johnson","J Lee","J Martin","J Robinson","J Smith","K Tanaka", "M Brown","M Jones","M Miller","S Lee","Y Chen")
