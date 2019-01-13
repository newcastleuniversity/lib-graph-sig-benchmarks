# commitment computation results analysis
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

# read data
dataFile <- "results-commitment-raw-2019-01-11_08-14-56"
dataPath <- getFilePath("../data/", dataFile, ".csv")
commitmentData <- read.csv(dataPath, sep=",")

# rename headings 
col_headings <- c('Benchmark','Mode', 'Score', 'Unit', 'Bases', 'KeyLength')
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

ggplot(commitmentData, aes(x=factor(commitmentData$KeyLength), y=commitmentData$Score)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(fill="cornflowerblue", color="black", notch=FALSE) +
  geom_point(position="jitter", color="blue", alpha=.5) +
  geom_rug( color="black") + 
  labs( x="Key size",  y = "computing commitments time (msec)", fill="Graph size") 

ggplot(commitmentData, aes(x=factor(commitmentData$KeyLength), y=commitmentData$Score, fill=factor(commitmentData$Bases))) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(outlier.colour="black", outlier.shape=18, outlier.size=4, notch=FALSE, fatten=2) + 
  labs( x="Key size",  y = "Computing commitments time (msec)", fill="Graph size") 

# calculate means
(means<- round(tapply(commitmentData$Score, commitmentData$KeyLength, mean), digits=2)) 

# plot means
plotmeans(commitmentData$Score ~ commitmentData$KeyLength, digits=3, ccol="red", xlab = "Key size", ylab="computing time for commitments (msec)",  mean.labels=T, main="Plot of computing commitments means by key length")

(cdata <- ddply(commitmentData, c("KeyLength", "Bases", "Score"), summarise,
               N    = sum(!is.na(commitmentData$Score)),
               mean = mean(commitmentData$Score, na.rm=TRUE),
               sd   = sd(commitmentData$Score, na.rm=TRUE),
               se   = sd / sqrt(N)
))


ggplot(commitmentData, aes(x = factor(commitmentData$KeyLength), y = commitmentData$Score, fill = factor(commitmentData$Bases))) + 
        geom_bar(stat="identity", position = "dodge") + 
        labs( x="Key size",  y = "Computing commitments time (msec)", fill="Graph size") 

#stacked bar chart
ggplot(commitmentData, aes(x = factor(commitmentData$KeyLength), y = commitmentData$Score, fill = factor(commitmentData$Bases))) + 
  geom_bar(stat="identity") + 
  labs( x="Key size",  y = "Computing commitments time (msec)", fill="Graph size") 

#proportional stacked bar chart
ce <- ddply(commitmentData, "KeyLength", transform, percent_time = Score / sum(Score) * 100)

ggplot(ce, aes(x=factor(KeyLength), y = percent_time, fill= factor(Bases))) +
  geom_bar(stat="identity")

boxplot(commitmentData$Score ~ commitmentData$KeyLength, main="Key generation by key length (mean is black dot)", xlab="key length", ylab="execution time (msec) for computing commitments", col=rainbow(7))

# create density plots
plot(density(commitmentData$Score), main="Density Plot: Score", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(commitmentData$Score), 2)))  # density plot for 'speed'
polygon(density(commitmentData$Score), col="red")

(df2 <- data_summary(commitmentData, varname = "Score", groupnames = c("KeyLength", "Bases")))
 
ggplot(df2, aes(x=factor(df2$KeyLength), y=df2$mean,  fill = factor(df2$Bases))) +
  geom_bar(stat="identity",  position=position_dodge())+
  theme_minimal() +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.15,
                position=position_dodge(0.9)) +
  labs(x="Key length", y="Mean commitment computation time (msec)", fill="Number of Bases") 

# read data
imgFileName <- "mean-commitment-execution-time"
imgPath <- getFilePath("../figures/", imgFileName, ".pdf")

#save plot
ggsave(imgPath)