# Using the tidy dataset spam on kernlab
library(kernlab)
data(spam)

# Performing the subsampling
set.seed(3435)
trainIndicator = rbinom(4601, size = 1, prob = 0.5)
table(trainIndicator)

trainSpam = spam[trainIndicator == 1, ]
testSpam = spam[trainIndicator == 0, ]

plot(trainSpam$capitalAve ~ trainSpam$type)

plot(log10(trainSpam$capitalAve + 1) ~ trainSpam$type)

plot(log10(trainSpam[, 1:4] + 1))

hCluster = hclust(dist(t(trainSpam[, 1:57])))
plot(hCluster)

hClusterUpdated = hclust(dist(t(log10(trainSpam[, 1:55] + 1))))
plot(hClusterUpdated)

# statistical prediction / modeling - logistic regression
trainSpam$numType = as.numeric(trainSpam$type) - 1
costFunction = function(x, y) sum(x != (y > 0.5))
cvError = rep(NA, 55)

library(boot)
for (i in 1:55) {
  lmFormula = reformulate(names(trainSpam)[i], response = "numType")
  glmFit = glm(lmFormula, family = "binomial", data = trainSpam)
  cvError[i] = cv.glm(trainSpam, glmFit, costFunction, 2)$delta[2]
}

# Which predictor has minimum cross-validated error?
names(trainSpam)[which.min(cvError)]
# output = "charDollar

# Measure of uncertainty - logistic regression

# Use the best model from the group
predictionModel = glm(numType ~ charDollar, family = "binomial", data = trainSpam)

# Get predictions on the test set
predictionTest = predict(predictionModel, testSpam)
predictedSpam = rep("nonspam", dim(testSpam)[1])

# Classify as 'spam' for those with prob > 0.5
predictedSpam[predictionModel$fitted > 0.5] = "spam"

table(predictedSpam, testSpam$type)
# Output -
# predictedSpam nonspam spam
#     nonspam    1346  458
#     spam         61  449

# The error rate is calculated by the diagonal values of the above table
(61+458) / (1346 + 458 + 61 + 449)
