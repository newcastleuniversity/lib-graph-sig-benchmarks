# proving computation results analysis
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

# create dataframe from proving-verifying with 50 vertices
(proving_50 <- createDataSetFromCSV("compute-400", "proving-profile-50-csv", "Method-list--CPU\\.csv", 50))

# rename headings 
proving_50 <- renameHeadings(proving_50, c('ExpID', 'ExpID.1', 'Method','Time_ms', 'OwnTime_ms', 'KeyLength', 'Vertices'))
str(proving_50)
summary(proving_50)

(filtered_50 <- filterMethods(proving_50))

scatter.smooth(x=factor(filtered_50$Method), y=filtered_50$Time_ms, main="Method ~ Time_ms")  # scatterplot

summary(filtered_50$Time_ms)
max(filtered_50$Time_ms)
table(filtered_50$Time_ms)
hist(filtered_50$Time_ms)

ggplot(filtered_50, aes(x = filtered_50$Time_ms)) + 
  geom_histogram(binwidth = 2)

(uniqueM <- unique(filtered_50$Method))

dProving <- filterProving(filtered_50)

(jitterOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "") )

(facetOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(facetOrderedMeanBarplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(dsummaryProving <- data_summary(dProving, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummaryProving, dsummaryProving$Method, dsummaryProving$mean, dsummaryProving$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
