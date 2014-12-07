library(e1071)
library(hmeasure)
library(ROCR)

#Import data from csv
data=read.csv(file="/Users/yiwenchen/Downloads/stat154_final_proj-master/train_word.csv",header=T)
original.data = data
head(data)
#Size of data
nrow(data)
ncol(data)
count = rep(NA, ncol(data))
for (i in 1:ncol(data)) {
  count[i] = sum(data[,i]!=0)
}
data = data[,-which(count<20)]
nrow(data)
ncol(data)
index = 1:nrow(data)
test.index = sample(index, trunc(length(index)/3))
test.set = data[test.index,]
train.set = data[-test.index,]
bestfit=best.tune(svm,class~.,data=train.set,kernel="radial")
svm.model=svm(class ~ ., data = train.set, cost=bestfit$cost, gamma=bestfit$gamma,method="radial",cross=10,probability=TRUE)
svm.model
svm.pred=predict(svm.model, test.set,decision.values=TRUE,probability=TRUE)
svm.model$accuracies
#[1] 97.84173 97.49104 95.69892 97.48201 97.84946 97.84946 95.32374 97.49104 96.41577 95.69892
svm.model$tot.accuracy
#[1] 96.91424
tab = table(svm.pred,test.set$class)
(tab[1,1]+tab[2,2])/sum(tab)
tab
#plot ROC curve
prob.ham=attr (svm.pred, "probabilities")[, "ham"]
roc.pred=prediction (prob.ham, test.set$class == "ham")
perf=performance (roc.pred, "tpr", "fpr")
plot(perf)
plotROC(HMeasure(test.set$class=="ham",attr(svm.pred,"probabilities")),which=1)

#random forest
set.seed(1)
rf=randomForest(class~.,data=train.set,importance=TRUE,mtry=223)
rfpred=predict(rf,test.set)
tab=table(rfpred,test.set$class)
(tab[1,1]+tab[2,2])/sum(tab)
# 0.9720029
cvRF=rfcv(train.set[,-1],train.set[,1],cv.fold=10)
# 446        223        112         56         28         14          7          3          1 
# 0.02296376 0.02188733 0.02224614 0.02583423 0.03229279 0.04269824 0.05740940 0.06925009 0.11051310
#ROC
rf.pr = predict(rf,type="prob",newdata=test.set)[,2]
rf.pred = prediction(rf.pr, test.set$class)
rf.perf = performance(rf.pred,"tpr","fpr")
plot(rf.perf)
plotROC(HMeasure(test.set$class=="ham",predict(rf,type="prob",newdata=test.set)[,1]),which=1)
#POWER
pwr.data=read.csv(file="/Users/yiwenchen/Downloads/stat154_final_proj-master/train_pwr.csv",header=T)
index = 1:nrow(pwr.data)
test.index = sample(index, trunc(length(index)/3))
test.set = pwr.data[test.index,]
train.set = pwr.data[-test.index,]
bestfit=best.tune(svm,class_label~.,data=train.set,kernel="radial")
svm.model=svm(class_label ~ ., data = train.set, cost=bestfit$cost, gamma=bestfit$gamma,method="radial",cross=10,probability=TRUE)
svm.model
svm.pred=predict(svm.model, test.set,decision.values=TRUE,probability=TRUE)
svm.model$accuracies
#99.64029 98.20789 98.56631 98.56115 97.13262 97.84946 98.92086 98.56631 96.41577 97.84946
svm.model$tot.accuracy
#[1] 98.17008
prob.ham=attr (svm.pred, "probabilities")[, "ham"]
roc.pred=prediction (prob.ham, test.set$class_label == "ham")
perf=performance (roc.pred, "tpr", "fpr")
plot(perf)

set.seed(1)
rf=randomForest(class_label~.,data=train.set,importance=TRUE,mtry=12)
rfpred=predict(rf,test.set)
tab=table(rfpred,test.set$class_label)
(tab[1,1]+tab[2,2])/sum(tab)
# 0.982771
cvRF=rfcv(train.set[,-1],train.set[,1],cv.fold=10)
cvRF$error.cv
#12          6          3          1 
#0.01829925 0.01973448 0.02116972 0.05561536 
rf.pr = predict(rf,type="prob",newdata=test.set)[,2]
rf.pred = prediction(rf.pr, test.set$class_label)
rf.perf = performance(rf.pred,"tpr","fpr")
plot(rf.perf)

#Combine
combined=cbind(pwr.data,data)
combined=combined[-14]
index = 1:nrow(combined)
test.index = sample(index, trunc(length(index)/3))
test.set = combined[test.index,]
train.set = combined[-test.index,]
bestfit=best.tune(svm,class_label~.,data=train.set,kernel="radial")
svm.model=svm(class_label ~ ., data = train.set, cost=bestfit$cost, gamma=bestfit$gamma,method="radial",cross=10,probability=TRUE)
svm.model
svm.pred=predict(svm.model, test.set,decision.values=TRUE,probability=TRUE)
svm.model$accuracies
# 97.12230 97.13262 98.92473 97.84173 98.20789 98.92473 98.56115 98.20789 98.20789 97.49104
svm.model$tot.accuracy
# 98.06243
tab=table(svm.pred,test.set$class_label)
(tab[1,1]+tab[2,2])/sum(tab)
prob.ham=attr (svm.pred, "probabilities")[, "ham"]
roc.pred=prediction (prob.ham, test.set$class_label == "ham")
perf=performance (roc.pred, "tpr", "fpr")
plot(perf)
set.seed(1)
rf=randomForest(class_label~.,data=train.set,importance=TRUE,mtry=229)
rfpred=predict(rf,test.set)
tab=table(rfpred,test.set$class_label)
(tab[1,1]+tab[2,2])/sum(tab)
# 0.9863604
cvRF=rfcv(train.set[,-1],train.set[,1],cv.fold=10)
cvRF$error.cv
#458        229        114         57         29         14          7          4          1 
#0.01542878 0.01399354 0.01435235 0.01578759 0.01542878 0.01758163 0.02116972 0.02081091 0.05166846 
rf.pr = predict(rf,type="prob",newdata=test.set)[,2]
rf.pred = prediction(rf.pr, test.set$class_label)
rf.perf = performance(rf.pred,"tpr","fpr")
plot(rf.perf)

library(gbm)
# BOOSTING(combined data)
train.boost=train.set
train.boost[,1]=ifelse(train.boost[,1]=="ham",1,0)
boost.model=gbm(class_label~.,data=train.set,distribution="bernoulli",n.trees=5000, interaction.depth=4)
boost.pred=predict(boost.model,test.set,n.trees=5000)
BPrediction=ifelse(boost.pred>0,0,1)
table(BPrediction,test.set$class_label)
# 0.9798995
