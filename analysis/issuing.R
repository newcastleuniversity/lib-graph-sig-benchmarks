# issuing computation results analysis
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

# create dataframe from issuing with 50 vertices
(issuing_50 <- createDataSetFromCSV("issuing-400", "issuing-profile-50-csv", "Method-list--CPU\\.csv", 50))

# rename headings 
issuing_50 <- renameHeadings(issuing_50, c('ExpID','Method','Time_ms', 'OwnTime_ms', 'KeyLength', 'Vertices'))
str(issuing_50)

filtered_50 <- filterMethods(issuing_50)

scatter.smooth(x=factor(filtered_50$Method), y=filtered_50$Time_ms, main="Method ~ Time_ms")  # scatterplot

summary(filtered_50$Time_ms)
max(filtered_50$Time_ms)
table(filtered_50$Time_ms)
hist(filtered_50$Time_ms)

(kmean <- mean(filtered_50$Time_ms))

ggplot(filtered_50, aes(x = filtered_50$Time_ms)) + 
  geom_histogram(binwidth = 2)

ggplot(filtered_50, aes(x = filtered_50$Time_ms)) + 
  geom_density(adjust = 0.25)

str(filtered_50$Method)
str(filtered_50$Time_ms)
length(filtered_50$Time_ms)
length(filtered_50$Method)
head(filtered_50)

# filter dataframe to include only methods with cpu time > 50 ms
filtered_50 <- filter(filtered_50, filtered_50$Time_ms > 0)

filteredSmall <- filter(filtered_50, filtered_50$Time_ms < 50)

(uniqueM <- unique(filtered_50$Method))

dIssuing <- filterIssuing(filtered_50)

(jitterOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "") )

(facetOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(facetOrderedMeanBarplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(cpuKeySummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength")))

ggplot(cpuKeySummary, aes(x=factor(cpuKeySummary$KeyLength), y=cpuKeySummary$mean,  fill = factor(cpuKeySummary$KeyLength))) +
  geom_bar(stat="identity", position=position_dodge())+
  theme_bw() +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.15,
                position=position_dodge(0.9)) +
  labs( x = "Key length",  y = "Mean CPU time (ms)", fill = "Key length") 

(dsummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary, dsummary$Method, dsummary$mean, dsummary$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

# plot means
plotmeans(filtered$Time_ms ~ filtered$Method, digits=3, ccol="red", xlab = "Methods", ylab="CPU time for issuing methods (msec)",las=2, cex.axis=0.4, mean.labels=F, mar=c(10.1,4.1,4.1,2.1),n.label = FALSE, mgp=c(3,1,0) , main="Plot of issuing methods")

# create dataframe from issuing with 500 vertices
(issuing_500 <- createDataSetFromCSV("issuing-3000", "issuing-profile-500-csv", "Method-list--CPU\\.csv", 500))

# rename headings 
issuing_500 <- renameHeadings(issuing_500, c('ExpID','ExpID.1', 'Method','Time_ms', 'OwnTime_ms', 'KeyLength', 'Vertices'))
str(issuing_500)

filtered_500 <- filterMethods(issuing_500)
dIssuing_500 <- filterIssuing(filtered_500)

(jitterOrderedBoxplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", "") )

(facetOrderedBoxplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(facetOrderedMeanBarplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(dsummary_500 <- data_summary(dIssuing_500, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

v_50 <- bind_rows(dsummary, .id="expID")
v_50['Vertices'] = 50

v_500 <- bind_rows(dsummary_500, .id = "expID")
v_500['Vertices'] = 500

dIssuing_50_500 <- rbind(v_50, v_500)

p <- (createMeanSDBarplots(dIssuing_50_500, dIssuing_50_500$Method, dIssuing_50_500$mean, dIssuing_50_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

p + facet_grid(dIssuing_50_500$Vertices ~ dIssuing_50_500$KeyLength)
