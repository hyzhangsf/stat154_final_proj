library(e1071)

#Import data from csv
data = read.csv('Desktop/stat154_final_proj/svm_features.csv')
label = read.csv('Desktop/stat154_final_proj/svm_labels.csv')
original.data = data

data = original.data
label = factor(label[,1])
#Size of data
nrow(data)
ncol(data)
data[5,"he"]

count = rep(NA, ncol(data))
for (i in 1:ncol(data)) {
  count[i] = sum(data[,i]!=0)
}

data = data[,-which(count<20)]
nrow(data)
ncol(data)

index = 1:nrow(data)
testindex = sample(index, trunc(length(index)/3))
testset = data[testindex,]
trainset = data[-testindex,]
testlabel = label[testindex]
trainlabel = label[-testindex]



tune.out=tune(svm,trainlabel∼.,data=dat,kernel="linear",
              ranges=list(cost=c(0.001, 0.01, 0.1, 1,5,10,100)))



svm.model <- svm(trainlabel ~ ., data = trainset, cost = 100, gamma = 1)
svm.pred <- predict(svm.model, testset)

tab = table(svm.pred,label[testindex])
(tab[1,1]+tab[2,2])/sum(tab)


