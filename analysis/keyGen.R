# key generation results analysis
library(ggplot2)
options(digits=10)

dataFile <- "results-keygen-raw-2018-11-10_12-00-59"
dataPath <- paste0("../data/", dataFile, ".csv", collapse = "" )
keyGenData <- read.csv(dataPath, sep=",")

#rename headings 
col_headings <- c('Name','Mode', 'Score', 'Type','KeyLength')
names(keyGenData) <- col_headings
str(keyGenData)

fKeyLength <- factor(keyGenData$KeyLength)
fKeyLength

keyGenTime <- sub1<-subset(keyGenData, keyGenData$Type == "s/op")
keyGenTime
fKeyLength <- factor(keyGenTime$KeyLength)
fKeyLength
summary(keyGenTime$Score)
max(keyGenTime$Score)
table(keyGenTime$Score)
hist(keyGenTime$Score)

kmean <- mean(keyGenTime$Score)
kmean

ggplot(keyGenTime, aes(x = keyGenTime$Score)) + 
  geom_histogram(binwidth = 2)

ggplot(keyGenTime, aes(x = keyGenTime$Score)) + 
  geom_density(adjust = 0.25)

ggplot(keyGenTime, aes(x=fKeyLength, y=keyGenTime$Score)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(fill="cornflowerblue",
               color="black", notch=FALSE)+
  geom_point(position="jitter", color="blue", alpha=.5) +
  geom_rug(side="l", color="black") + 
  labs( x="Key Length",  y = "Key generation time (sec)", fill="") 

ggplot(keyGenTime, aes(x=fKeyLength, y=keyGenTime$Score, fill=fKeyLength)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(outlier.colour="black", outlier.shape=18,
               outlier.size=4, notch=FALSE, fatten=2) + 
  labs( x="",  y = "Key generation time (sec)", fill="") 



