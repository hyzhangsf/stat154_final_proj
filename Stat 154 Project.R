library(e1071)
library(ROCR)


#Import data from csv
data = read.csv('~/Desktop/stat154_final_proj/svm_features.csv')
test = read.csv('~/Desktop/stat154_final_proj/svm_test.csv')

power.data = read.csv('~/Desktop/stat154_final_proj/train_pwr.csv')
#data = read.table('~/Desktop/stat154_final_proj/svm_features.csv', sep=",", header=TRUE, encoding="UTF-8",stringsAsFactors=FALSE)
original.data = data
original.test = test
original.power.data = power.data
head(data)
head(test)

data = original.data
test = original.test
#Size of data
nrow(data)
ncol(data)


count = rep(NA, ncol(data))
for (i in 1:(ncol(data)-1)) {
  count[i] = sum(data[,i]!=0)
}

data = data[,-which(count<20)]
test = test[,-which(count<20)]
nrow(data)
ncol(data)


######## RUN UP TO HERE ########


svm.model <- svm(isHam ~ ., data = data, cost = 100, gamma = 0.0001)
svm.pred <- predict(svm.model, test)


tab = table(svm.pred,test$isHam)
tab
(tab[1,1]+tab[2,2])/sum(tab)
sum(test[,'isHam']=='ham')/nrow(test)



head(attributes(svm.pred)$decision.values))
head(svm.model$decision.values)
svm.model$decision.values



######## POWER FEATURES #########

test.index = sample(1:floor(nrow(power.data)/3))
train.index = -test.index
svm.model <- svm(class_label ~ ., data = power.data[train.index,], cost = 100, gamma = 0.0001)
svm.pred <- predict(svm.model, power.data[test.index,])

tab = table(svm.pred,power.data[test.index, 'class_label'])
tab
(tab[1,1]+tab[2,2])/sum(tab)
sum(test[,'isHam']=='ham')/nrow(test)

test.index[which(svm.pred != power.data[test.index, 'class_label'])]
