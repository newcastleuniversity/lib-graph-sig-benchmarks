# commitment computation results analysis

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
dataFile <- "results-commitment-raw-2019-01-02_07-02-11"
dataPath <- paste0("../data/", dataFile, ".csv", collapse = "" )
commitmentData <- read.csv(dataPath, sep=",")

# rename headings 
col_headings <- c('Benchmark','Mode', 'Score', 'Unit', 'Vertices', 'KeyLength')
names(commitmentData) <- col_headings
str(commitmentData)

scatter.smooth(x=commitmentData$KeyLength, y=commitmentData$Score, main="Keylength ~ Score")  # scatterplot

summary(commitmentData$Score)
max(commitmentData$Score)
table(commitmentData$Score)
hist(commitmentData$Score)

(kmean <- mean(commitmentData$Score))

ggplot(commitmentData, aes(x = commitmentData$Score)) + 
  geom_histogram(binwidth = 2)

ggplot(commitmentData, aes(x = commitmentData$Score)) + 
  geom_density(adjust = 0.25)

ggplot(commitmentData, aes(x=factor(commitmentData$KeyLength), y=commitmentData$Score/1000)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(fill="cornflowerblue", color="black", notch=FALSE) +
  geom_point(position="jitter", color="blue", alpha=.5) +
  geom_rug( color="black") + 
  labs( x="Key size",  y = "computing commitments time (msec)", fill="Graph size") 

ggplot(commitmentData, aes(x=factor(commitmentData$KeyLength), y=commitmentData$Score/1000, fill=factor(commitmentData$Vertices))) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(outlier.colour="black", outlier.shape=18, outlier.size=4, notch=FALSE, fatten=2) + 
  labs( x="Key size",  y = "Computing commitments time (msec)", fill="Graph size") 

# calculate means
(means<- round(tapply(commitmentData$Score, commitmentData$KeyLength, mean), digits=2)) 

# plot means
plotmeans(commitmentData$Score/1000 ~ commitmentData$KeyLength, digits=2, ccol="red", xlab = "Key size", ylab="computing time for commitments (msec)",  mean.labels=T, main="Plot of computing commitments means by key length")

(cdata <- ddply(commitmentData, c("KeyLength", "Vertices", "Score"), summarise,
               N    = sum(!is.na(commitmentData$Score)),
               mean = mean(commitmentData$Score, na.rm=TRUE),
               sd   = sd(commitmentData$Score, na.rm=TRUE),
               se   = sd / sqrt(N)
))


ggplot(commitmentData, aes(x = factor(commitmentData$KeyLength), y = commitmentData$Score, fill = factor(commitmentData$Vertices))) + 
        geom_bar(stat="identity", position = "dodge") + 
        labs( x="Key size",  y = "Computing commitments time (μsec)", fill="Graph size") + 
        scale_fill_brewer(palette="Pastel1")

#stacked bar chart
ggplot(commitmentData, aes(x = commitmentData$KeyLength, y = commitmentData$Score, fill = factor(commitmentData$Vertices))) + 
  geom_bar(stat="identity") + 
  labs( x="Key size",  y = "Computing commitments time (μsec)", fill="Graph size") + 
  scale_fill_brewer(palette="Pastel1")

#proportional stacked bar chart
library(dplyr)
ce <- ddply(commitmentData, "KeyLength", transform, percent_time = Score / sum(Score) * 100)

ggplot(ce, aes(x=KeyLength, y = percent_time, fill= factor(Vertices))) +
  geom_bar(stat="identity")

boxplot(commitmentData$Score ~ commitmentData$KeyLength, main="Key generation by key length (mean is black dot)", xlab="key length", ylab="execution time (sec) for generating keys", col=rainbow(7))

# create density plots
plot(density(commitmentData$Score), main="Density Plot: Score", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(commitmentData$Score), 2)))  # density plot for 'speed'
polygon(density(commitmentData$Score), col="red")

(aov_cont<- aov(commitmentData$Score ~ factor(commitmentData$KeyLength)))
ls(aov_cont)
summary(aov_cont)
confint(aov_cont, level = 0.9)
summary.lm(aov_cont)
plot(aov_cont)
outlierTest(aov_cont)

# perform Tukey test
(tuk<- TukeyHSD(aov_cont, conf.level = 0.95))
plot(tuk)

lmo <- lm(commitmentData$Score ~ commitmentData$KeyLength)
summary(lmo)
coef(lmo)
confint(lmo, level = 0.9)
anova(lmo)
plot(lmo)
outlierTest(lmo)

# discard outliers 
commitmentData$Score<-ifelse(commitmentData$Score==outlier(commitmentData$Score),NA,commitmentData$Score)
commitmentData

influence.measures(lmo)

ares <- aov(commitmentData$Score ~ factor(commitmentData$KeyLength), data = commitmentData)
TukeyHSD(ares)
plot(TukeyHSD(ares), las=0)
summary(ares)

kruskal.test(commitmentData$Score ~ commitmentData$KeyLength, commitmentData)

barplot(commitmentData$Score)

meansg <- aggregate(commitmentData$Score, by=list(commitmentData$KeyLength), FUN=mean)
meansg
barplot(meansg$x, names.arg=meansg$Group.1,main="Means bar plot", xlab="Key Length", ylab="Mean",          col=c("red", "yellow","green", "blue"))

plot(commitmentData$KeyLength)

res <- HSD.test(ares, 'commitmentData$KeyLength')
res
plot(res)

posthoc <- TukeyHSD(x=aov_cont, factor(commitmentData$KeyLength), conf.level=0.95)
plot(posthoc)

leveneTest(commitmentData$Score ~ factor(commitmentData$KeyLength), commitmentData)

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
   
 (df2 <- data_summary(commitmentData, varname = "Score", groupnames = c("KeyLength")))
 
 (mean(commitmentData$Score, na.rm=TRUE))
 (sd(commitmentData$Score, na.rm=TRUE))

ggplot(df2, aes(x=df2$KeyLength, y=df2$mean,  fill = df2$KeyLength)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal() +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.15,
                position=position_dodge(0.9)) +
  labs( x="Key length",  y = "Mean commitment computation time (sec)", fill="") 


# calculate quantiles
quantile(commitmentData$Score)
t.test(commitmentData$Score, mu=95)
pairwise.t.test(commitmentData$Score, commitmentData$KeyLength)

glimpse(commitmentData)

(totalMean <- mean(commitmentData$Score, na.rm=TRUE))

