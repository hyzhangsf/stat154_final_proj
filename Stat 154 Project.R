library(e1071)

#Import data from csv
data = read.csv('~/stat154_final_proj/svm_features.csv')
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
test.label = label[test.index]
train.label = label[-test.index]




tune.svm(isHam~., data = data, gamma = 2^(-3:3), cost = 2^(1:6))

######## RUN UP TO HERE ########


svm.model <- svm(isHam ~ ., data = train.set, cost = 100, gamma = 1)
svm.pred <- predict(svm.model, test.set)

tab = table(svm.pred,label[test.index])
(tab[1,1]+tab[2,2])/sum(tab)
tab
sum(test.label==1)/length(test.label)

