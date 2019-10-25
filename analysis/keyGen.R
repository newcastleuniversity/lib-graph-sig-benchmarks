# key generation performance results analysis

## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# read data
dataFile <- "results-keygen-raw-2018-11-13_11-52-31"
dataPath <- paste0("../data/", dataFile, ".csv", collapse = "" )
keyGenData <- read.csv(dataPath, sep=",")

# rename headings 
col_headings <- c('Name','Mode', 'Score', 'Type','KeyLength')
names(keyGenData) <- col_headings
str(keyGenData)

scatter.smooth(x=keyGenData$KeyLength, y=keyGenData$Score, main="Keylength ~ Score")  # scatterplot

summary(keyGenData$Score)
max(keyGenData$Score)
table(keyGenData$Score)
hist(keyGenData$Score)

kmean <- mean(keyGenData$Score)
kmean

khist <- ggplot(keyGenData, aes(x = keyGenData$Score)) + 
  geom_histogram(binwidth = 2) + theme_bw() 
# savePlot(khist, "key-histogram.pdf")

ggplot(keyGenData, aes(x = keyGenData$Score)) + 
  geom_density(adjust = 0.25) + theme_bw() 

# savePlot(last_plot(), "key-dens-histogram.pdf")


ggplot(keyGenData, aes(x=factor(keyGenData$KeyLength), y=keyGenData$Score)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(fill="cornflowerblue", color="black", notch=FALSE) +
  geom_point(position="jitter", color="blue", alpha=.5) +
  geom_rug( color="black") + theme_bw() +
  labs( x="Key size",  y = "Key generation time (sec)", fill="") 

savePlot(last_plot(), "key-jitter-boxplot.pdf")


ggplot(keyGenData, aes(x=factor(keyGenData$KeyLength), y=keyGenData$Score, fill=keyGenData$KeyLength)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(outlier.colour="black", outlier.shape=18, outlier.size=4, notch=FALSE, fatten=2) + 
  labs( x="Key size",  y = "Key generation time (sec)", fill="") 

savePlot(last_plot(), "key-boxplot.pdf")


# calculate means
(means<- round(tapply(keyGenData$Score, keyGenData$KeyLength, mean), digits=2)) 

# plot means
plotmeans(keyGenData$Score ~ keyGenData$KeyLength, digits=2, ccol="red", mean.labels=T, main="Plot of executing key generation means by key length")

boxplot(keyGenData$Score ~ keyGenData$KeyLength, main="Key generation by key length (mean is black dot)", xlab="key length", ylab="execution time (sec) for generating keys", col=rainbow(7))

# create density plots
plot(density(keyGenData$Score), main="Density Plot: Score", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(keyGenData$Score), 2)))  # density plot for 'speed'
polygon(density(keyGenData$Score), col="red")

(meansg <- aggregate(keyGenData$Score, by=list(keyGenData$KeyLength), FUN=mean))

barplot(meansg$x, names.arg=meansg$Group.1,main="Means bar plot", xlab="Key Length", ylab="Mean",          col=c("red", "yellow","green", "blue"))

 (df2 <- data_summary(keyGenData, varname = "Score", groupnames = c("KeyLength")))
 
 (mean(keyGenData$Score, na.rm=TRUE))
 (sd(keyGenData$Score, na.rm=TRUE))

# writeCSV(df2,"../data/keyGenData.csv")

kDataFile <- "keyGenData"
kCSVFilePath <- paste0(paperDataFolderPath, kDataFile, ".csv", collapse = "")
writeCSV(df2,kCSVFilePath)

ggplot(df2, aes(x=factor(df2$KeyLength), y=df2$mean,  fill = factor(df2$KeyLength))) +
  geom_bar(stat="identity", position=position_dodge())+
  # theme_minimal() +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.15,
                position=position_dodge(0.9)) +
  labs( x="Key length",  y = "Mean key generation time (sec)", fill="") +
  theme(
    aspect.ratio = 1/0.9,
    legend.position="none",
    axis.title = element_text(colour= "black", size = 12, face = "plain"),
    axis.text = element_text(colour = "black", size = 10, face = "plain"),
    # strip.text.x = element_text(colour = "black", size = 14, face = "bold"),
    strip.background = element_blank(),
    strip.placement = "outside"
  )

savePlot( "mean-key-generation-time.pdf")

# ggplot(df2, aes(x = reorder(factor(df2$KeyLength)), y = df2$mean,  color = factor(df2$KeyLength), linetype = factor(df2$KeyLength), shape = factor(df2$KeyLength))) +
#   # geom_line(aes(linetype = factor(attrData$Components), color = factor(attrData$Components))) +
#   geom_line() +
#   geom_point() +
#   # geom_point(aes(colour = factor(attrData$Components), shape = factor(attrData$Components))) +
#   labs(x = "Key length", y = "Mean Key generation Time (sec)", color = "", shape = "") +
#   # guides(colour = guide_legend(), shape = guide_legend(), linetype = FALSE) +
#   scale_colour_discrete("") +
#   # scale_shape_manual(values = c(4,8,15,16)) + #,17,18,21,22,3,42,4,8,15,16)) +
#   # scale_linetype_manual(values=c("solid", "dashed","dotted", "dotdash")) + #, "longdash", "twodash", "solid", "dashed","dotted", "dotdash", "longdash", "twodash","solid", "dashed")) +
#   # guides( size = guide_legend(),
#   # shape = guide_legend(), linetype= FALSE) +
#   theme(
#     aspect.ratio = 1/1,
#     strip.text.x = element_text(colour = "black", size = 10),
#     strip.background = element_blank(),
#     strip.placement = "outside"
#   )
