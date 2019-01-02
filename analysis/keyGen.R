# key generation results analysis

# packages
# install.packages('DMwR')
# install.packages("gplots")
# install.packages('DAAG')
#install.packages("agricolae")
library(agricolae)
library(ggplot2)
library(gplots)
library(DAAG)
library(e1071)
library(dplyr)
library(outliers)
library(plyr)
library(reshape2)
library(car)

options(digits=10)

# read data
dataFile <- "results-keygen-raw-2018-11-13_11-52-31"
dataPath <- paste0("../data/", dataFile, ".csv", collapse = "" )
keyGenData <- read.csv(dataPath, sep=",")

# rename headings 
col_headings <- c('Name','Mode', 'Score', 'Type','KeyLength')
names(keyGenData) <- col_headings
str(keyGenData)

scatter.smooth(x=keyGenData$KeyLength, y=keyGenData$Score, main="Keylength ~ Score")  # scatterplot

fKeyLength <- factor(keyGenData$KeyLength)
fKeyLength

keyGenTime <- sub1<-subset(keyGenData, keyGenData$Type == "s/op")
keyGenTime

fKeyLength <- factor(keyGenTime$KeyLength)
fKeyLength

keyGenTime$KeyLength <- factor(keyGenTime$KeyLength)


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

ggplot(keyGenTime, aes(x=keyGenTime$KeyLength, y=keyGenTime$Score)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(fill="cornflowerblue", color="black", notch=FALSE) +
  geom_point(position="jitter", color="blue", alpha=.5) +
  geom_rug( color="black") + 
  labs( x="Key size",  y = "Key generation time (sec)", fill="") 

ggplot(keyGenTime, aes(x=keyGenTime$KeyLength, y=keyGenTime$Score, fill=keyGenTime$KeyLength)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(outlier.colour="black", outlier.shape=18, outlier.size=4, notch=FALSE, fatten=2) + 
  labs( x="Key size",  y = "Key generation time (sec)", fill="") 

# calculate means
(means<- round(tapply(keyGenTime$Score, keyGenTime$KeyLength, mean), digits=2)) 

# plot means
plotmeans(keyGenTime$Score ~ keyGenTime$KeyLength, digits=2, ccol="red", mean.labels=T, main="Plot of executing key generation means by key length")

boxplot(keyGenTime$Score ~ keyGenTime$KeyLength, main="Key generation by key length (mean is black dot)", xlab="key length", ylab="execution time (sec) for generating keys", col=rainbow(7))


# create density plots
plot(density(keyGenTime$Score), main="Density Plot: Score", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(keyGenTime$Score), 2)))  # density plot for 'speed'
polygon(density(keyGenTime$Score), col="red")

(aov_cont<- aov(keyGenTime$Score ~ keyGenTime$KeyLength))
ls(aov_cont)
summary(aov_cont)
confint(aov_cont, level = 0.9)
summary.lm(aov_cont)
plot(aov_cont)
outlierTest(aov_cont)

# perform Tukey test
(tuk<- TukeyHSD(aov_cont, conf.level = 0.95))
plot(tuk)

lmo <- lm(keyGenTime$Score ~ keyGenTime$KeyLength)
summary(lmo)
coef(lmo)
confint(lmo, level = 0.9)
anova(lmo)
plot(lmo)
outlierTest(lmo)


# discard outliers 
keyGenTime$Score<-ifelse(keyGenTime$Score==outlier(keyGenTime$Score),NA,keyGenTime$Score)
keyGenTime

influence.measures(lmo)

ares <- aov(keyGenTime$Score ~ keyGenTime$KeyLength, data = keyGenTime)
TukeyHSD(ares)
plot(TukeyHSD(ares), las=0)
summary(ares)

kruskal.test(keyGenTime$Score ~ keyGenTime$KeyLength, keyGenTime)

barplot(keyGenTime$Score)
(counts <- table(keyGenTime$KeyLength))

barplot(counts,main=" Bar Plot",         xlab="Key Length", ylab="Frequency",          col=c("red", "yellow","green", "blue"),         legend=rownames(counts))

meansg <- aggregate(keyGenTime$Score, by=list(keyGenTime$KeyLength), FUN=mean)
meansg
barplot(meansg$x, names.arg=meansg$Group.1,main="Means bar plot", xlab="Key Length", ylab="Mean",          col=c("red", "yellow","green", "blue"))

plot(keyGenTime$KeyLength)

res <- HSD.test(ares, 'keyGenTime$KeyLength')
res
plot(res)

posthoc <- TukeyHSD(x=aov_cont, 'keyGenTime$KeyLength', conf.level=0.95)
plot(posthoc)

leveneTest(keyGenTime$Score ~ keyGenTime$KeyLength, keyGenTime)

data_summary <- function(data, varname, groupnames){
   require(plyr)
   summary_func <- function(x, col){
     c(mean = mean(x[[col]], na.rm=TRUE),
       sd = sd(x[[col]], na.rm=TRUE), 
       N = length(x[[col]]),
       se = sd(x[[col]], na.rm=TRUE)/sqrt(length(x[[col]]))
       ) 
      
   }
   data_sum <- ddply(data, groupnames, .fun=summary_func, varname)
   #data_sum <- rename(data_sum, c("mean" = varname))
   return(data_sum)
 }
   
 (df2 <- data_summary(keyGenTime, varname = "Score", groupnames = c("KeyLength")))
 
 
 (mean(keyGenTime$Score, na.rm=TRUE))
 (sd(keyGenTime$Score, na.rm=TRUE))

ggplot(df2, aes(x=df2$KeyLength, y=df2$mean,  fill = df2$KeyLength)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal() +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.15,
                position=position_dodge(0.9)) +
  labs( x="Key length",  y = "Mean key generation time (sec)", fill="") 


# calculate quantiles
quantile(keyGenTime$Score)
t.test(keyGenTime$Score, mu=95)
pairwise.t.test(keyGenTime$Score, keyGenTime$KeyLength)

glimpse(keyGenTime)

(totalMean <- mean(keyGenTime$Score, na.rm=TRUE))


# demo <- keyGenTime %>%
#   #mutate(m = mean(Score, na.rm=TRUE)) %>%
#   #m = mean(keyGenTime$Score) %>%
#   group_by(KeyLength) 
#   summarise(mean = mean(Score, na.rm=TRUE), 
#             standardDeviation = sd(Score, na.rm = TRUE), 
#             standardError =  (sd(Score, na.rm=TRUE)/sqrt(n())))
# demo
# dd <- demo %>%
#   mutate(effect = totalMean - mean)
# dd
# 
# 
# glimpse(dd)
# add key lenght sizes 

