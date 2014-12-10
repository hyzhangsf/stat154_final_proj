library(e1071)
library(randomForest)
setwd('~/Desktop/Stat 154/Final Submit')

##### tuning functions #####
my.tune.RF=function(x,y,ntreeStart=50,mtryStart=round(sqrt(ncol(x))),stepFactor=1.5,speed=1){
  ntreeLast=ntreeStart
  mtryLast=mtryStart
  OOBLast=randomForest(x,y,ntree=ntreeLast,mtry=mtryLast)$err.rate[ntreeLast]
  print(cat("Starting OOB Error Rate:",OOBLast))
  print("")
  while(stepFactor>1.05){
    tmp=sample(c(1,2,3,4))
    for(i in 1:4){
      if(tmp[i]==1){
        ntree=max(5,ntreeLast-max(3,round(ntreeLast*(stepFactor-1))))
        mtry=mtryLast
      }
      if(tmp[i]==2){
        ntree=max(5,ntreeLast+max(3,round(ntreeLast*(stepFactor-1))))
        mtry=mtryLast
      }
      if(tmp[i]==3){
        ntree=ntreeLast
        mtry=min(ncol(x),mtryLast+round(max(1,mtryLast*(stepFactor-1))))
      }
      if(tmp[i]==4){
        ntree=ntreeLast
        mtry=max(1,mtryLast-max(1,round(mtryLast*(stepFactor-1))))
      }
      OOBErr=randomForest(x,y,ntree=ntree,mtry=mtry)$err.rate[ntree,1]
      print(paste("ntree",ntree, "mtry",mtry, "OOB Error Rate:",OOBErr))
      if(OOBErr<OOBLast){
        OOBLast=OOBErr
        ntreeLast=ntree
        mtryLast=mtry
        break
      }
    }
    if(OOBLast!=OOBErr){
      stepFactor=(1/speed*5*stepFactor+1)/(1/speed*5+1)
      stepFactor=(1/speed*5*stepFactor+1)/(1/speed*5+1)
    }
    stepFactor=(1/speed*5*stepFactor+1)/(1/speed*5+1)
    print("")
  }
  return(c(ntreeLast,mtryLast))
}
my.tune.svm=function(x,y,logcostStart=1,loggammaStart=-2,stepStart=1,rate=0.8){
  step=stepStart
  logcostLast=logcostStart
  loggammaLast=loggammaStart
  cvErrLast=100-mean(svm(x,y,cost=10^logcostLast,gamma=10^loggammaLast,cross=5)$accuracies)
  print(paste("cost",10^logcostLast,"Gamma",10^loggammaLast,"Cross Validation Error",cvErrLast,"%"))
  print("")
  while(step>0.1){
    tmp=sample(c(1,2,3,4))
    for(i in 1:4){
      if(tmp[i]==1){
        logcost=logcostLast-step
        loggamma=loggammaLast
      }
      if(tmp[i]==2){
        logcost=logcostLast+step
        loggamma=loggammaLast
      }
      if(tmp[i]==3){
        logcost=logcostLast
        loggamma=loggammaLast-step
      }
      if(tmp[i]==4){
        logcost=logcostLast
        loggamma=loggammaLast+step
      }
      cvErr=100-mean(svm(x,y,cost=10^logcost,gamma=10^loggamma,cross=5)$accuracies)
      print(paste("cost",10^logcost, "gamma",10^loggamma, "cv Error Rate:",cvErr,"%"))
      if(cvErr<cvErrLast){
        cvErrLast=cvErr
        logcostLast=logcost
        loggammaLast=loggamma
        break
      }
    }
    if(cvErrLast!=cvErr){
      step=step*rate^2
    }
    step=step*rate
    print("")
  }
  return(c(10^logcostLast,10^loggammaLast))
}

set.seed(1)
##### Prediction with only word features #####
#Import data from csv
train.word = read.csv('train_word.csv')
train.labels=train.word[,1]
train.word=train.word[,-1]
test.word = read.csv('test_word.csv')
original.train = train.word
original.test=test.word

#restore data sets
train.word=original.train
test.word=original.test

#count the number of appearances of each word
count = rep(NA, ncol(train.word))
for (i in 1:ncol(train.word)) {
  count[i] = sum(train.word[,i]!=0)
}

#filter works that appear infrequently
selected=(count>=20)
train.word = train.word[,selected]

#alter the test set so that it has the same columns as train set.
common_columns=intersect(colnames(test.word),colnames(train.word))
add_columns=setdiff(colnames(train.word),common_columns)
tmp=data.frame(matrix(rep(0,length(add_columns)*length(test.word[,1])),ncol=length(add_columns)))
test.word=test.word[common_columns]
if(length(tmp)>0){
  colnames(tmp)=add_columns
  test.word=cbind(test.word,tmp)
}
test.word=test.word[,colnames(train.word)]
  
##### Prediction with only the word feature using svm ######
#tmp=my.tune.svm(train.word,train.labels)
#"cost 22.9086765276777 gamma 0.000790160289722006 cv Error Rate: 2.41626794258373 %"
tmp=c(22.9086765276777, 0.000790160289722006)
model.svm.word = svm(isHam ~ ., data = cbind(train.word,isHam=train.labels), cost = tmp[1], gamma = tmp[2], probability=T)
pred.svm.word = predict(model.svm.word,test.word,decision.values=T,probability=T)
result.svm.word=as.numeric(pred.svm.word)-1

##### Prediction with only the word feature using randomForest ########
#tmp=my.tune.RF(train.word,train.labels)
#"ntree 50 mtry 32 OOB Error Rate: 0.0241626794258373"
tmp=c(50,32)
model.rf.word=randomForest(train.word,train.labels,ntree=tmp[1],mtry=tmp[2])
pred.rf.word = predict(model.rf.word,test.word)
result.rf.word=as.numeric(pred.rf.word)-1

##### Prediction with only power features #####
#Import data from csv
train.pwr = read.csv('train_pwr.csv')
train.labels=train.pwr[,1]
train.pwr=train.pwr[,-1]
test.pwr = read.csv('test_pwr.csv')

##### Prediction with only the power feature using svm ######
#tmp=my.tune.svm(train.pwr,train.labels)
#"cost 1 gamma 0.134177593976502 cv Error Rate: 1.86602870813397 %"
tmp=c(1,0.134177593976502)
model.svm.pwr = svm(isHam ~ ., data = cbind(train.pwr,isHam=train.labels), cost=tmp[1],gamma=tmp[2], probability=T)
pred.svm.pwr = predict(model.svm.pwr,test.pwr,decision.values=T,probability=T)
result.svm.pwr=as.numeric(pred.svm.pwr)-1

##### Prediction with only the power feature using randomForest ########
#tmp=my.tune.RF(train.pwr,train.labels)
#"ntree 29 mtry 5 OOB Error Rate: 0.0177033492822967"
tmp=c(29,5)
model.rf.pwr=randomForest(train.pwr,train.labels,ntree=tmp[1],mtry=tmp[2])
pred.rf.pwr = predict(model.rf.pwr,test.pwr)
result.rf.pwr=as.numeric(pred.rf.pwr)-1

##### Prediction with combined features #####

#Combining matrices
train.full = cbind(train.word,train.pwr)
test.full = cbind(test.word,test.pwr)

##### Prediction with both features using svm ######
# tmp=my.tune.svm(train.full,train.labels)
#"cost 3.89403633879717 gamma 0.001 cv Error Rate: 1.36363636363636 %"
tmp=c(3.89403633879717 , 0.001)
model.svm.full = svm(isHam ~ ., data = cbind(train.full,isHam=train.labels), cost=tmp[1],gamma=tmp[2], probability=T)
pred.svm.full = predict(model.svm.full,test.full,decision.values=T,probability=T)
result.svm.full=as.numeric(pred.svm.full)-1

##### Prediction with both features using randomForest ########
# tmp=my.tune.RF(train.full,train.labels)
#"ntree 50 mtry 29 OOB Error Rate: 0.0126794258373206"
tmp=c(50,29)
model.rf.full=randomForest(train.full,train.labels,ntree=tmp[1],mtry=tmp[2])
pred.rf.full = predict(model.rf.full,test.full)
result.rf.full=as.numeric(pred.rf.full)-1


##### confusioin matrices #####
key=read.csv("key.csv",head=F)$V1
### svm, word feature ###
tab.svm.word=table(result.svm.word,key)

### rf, word feature ###
tab.rf.word=table(result.rf.word,key)

### svm, power feature ###
tab.svm.pwr=table(result.svm.pwr,key)

### rf, power feature ###
tab.rf.pwr=table(result.rf.pwr,key)

### svm, combined feature ###
tab.svm.full=table(result.svm.full,key)

### rf, combined feature ###
tab.rf.full=table(result.rf.full,key)

##### Plots and Accuracies
library(ROCR)
### svm, word feature ###
#ROC#
png(file="SVM_word feature.png",width=600,height=600)
plot(performance(prediction(attr(pred.svm.word,"probabilities")[,2],key),'tpr','fpr'),main="SVM, word feature")
dev.off()
acc.svm.word=(tab.svm.word[1,1]+tab.svm.word[2,2])/sum(tab.svm.word)
ppv.svm.word=tab.svm.word[2,2]/(tab.svm.word[1,2]+tab.svm.word[2,2])
npv.svm.word=tab.svm.word[1,1]/(tab.svm.word[1,1]+tab.svm.word[1,2])

### rf, word feature ###
png(file="RF_word feature.png",width=600,height=600)
plot(performance(prediction(predict(model.rf.word,test.word,type="prob")[,2],key),'tpr','fpr'),main="RF, word feature")
dev.off()
acc.rf.word=(tab.rf.word[1,1]+tab.rf.word[2,2])/sum(tab.rf.word)
ppv.rf.word=tab.rf.word[2,2]/(tab.rf.word[1,2]+tab.rf.word[2,2])
npv.rf.word=tab.rf.word[1,1]/(tab.rf.word[1,1]+tab.rf.word[1,2])

### svm, power feature ###
png(file="SVM_power feature.png",width=600,height=600)
plot(performance(prediction(attr(pred.svm.pwr,"probabilities")[,2],key),'tpr','fpr'),main="SVM, power feature")
dev.off()
acc.svm.pwr=(tab.svm.pwr[1,1]+tab.svm.pwr[2,2])/sum(tab.svm.pwr)
ppv.svm.pwr=tab.svm.pwr[2,2]/(tab.svm.pwr[1,2]+tab.svm.pwr[2,2])
npv.svm.pwr=tab.svm.pwr[1,1]/(tab.svm.pwr[1,1]+tab.svm.pwr[1,2])

### rf, power feature ###
png(file="RF_power feature.png",width=600,height=600)
plot(performance(prediction(predict(model.rf.pwr,test.pwr,type="prob")[,2],key),'tpr','fpr'),main="RF, power feature")
dev.off()
acc.rf.pwr=(tab.rf.pwr[1,1]+tab.rf.pwr[2,2])/sum(tab.rf.pwr)
ppv.rf.pwr=tab.rf.pwr[2,2]/(tab.rf.pwr[1,2]+tab.rf.pwr[2,2])
npv.rf.pwr=tab.rf.pwr[1,1]/(tab.rf.pwr[1,1]+tab.rf.pwr[1,2])

### svm, combined feature ###
png(file="SVM_combined features.png",width=600,height=600)
plot(performance(prediction(attr(pred.svm.full,"probabilities")[,2],key),'tpr','fpr'),main="SVM, combined features")
dev.off()
acc.svm.full=(tab.svm.full[1,1]+tab.svm.full[2,2])/sum(tab.svm.full)
ppv.svm.full=tab.svm.full[2,2]/(tab.svm.full[1,2]+tab.svm.full[2,2])
npv.svm.full=tab.svm.full[1,1]/(tab.svm.full[1,1]+tab.svm.full[1,2])

### rf, combined feature ###
png(file="RF_combined features.png",width=600,height=600)
plot(performance(prediction(predict(model.rf.full,test.full,type="prob")[,2],key),'tpr','fpr'),main="RF, combined features")
dev.off()
acc.rf.full=(tab.rf.full[1,1]+tab.rf.full[2,2])/sum(tab.rf.full)
ppv.rf.full=tab.rf.full[2,2]/(tab.rf.full[1,2]+tab.rf.full[2,2])
npv.rf.full=tab.rf.full[1,1]/(tab.rf.full[1,1]+tab.rf.full[1,2])

### save all models, predictions, and confusion matrices
save(key,train.label,train.word,test.word,train.pwr,test.pwr,train.full,test.full
     acc.svm.word,acc.rf.word,acc.svm.pwr,acc.rf.pwr,acc.svm.full,acc.rf.full,
     ppv.svm.word,ppv.rf.word,ppv.svm.pwr,ppv.rf.pwr,ppv.svm.full,ppv.rf.full,
     npv.svm.word,npv.rf.word,npv.svm.pwr,npv.rf.pwr,npv.svm.full,npv.rf.full,
     pred.svm.word,pred.rf.word,pred.svm.pwr,pred.rf.pwr,pred.svm.full,pred.rf.full,
     model.svm.word,model.rf.word,model.svm.pwr,model.rf.pwr,model.svm.full,model.rf.full,
     result.svm.word,result.rf.word,result.svm.pwr,result.rf.pwr,result.svm.full,result.rf.full,
     tab.svm.word,tab.rf.word,tab.svm.pwr,tab.rf.pwr,tab.svm.full,tab.rf.full,
     file="team 9.Rda")
