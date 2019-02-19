# proving computation results analysis
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

# create dataframe from proving-verifying with 50 vertices
(proving_50 <- createDataSetFromCSV("compute-400", "proving-profile-50-csv-15", "Method-list--CPU\\.csv", 50))

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


# create dataframe from proving with 500 vertices
(proving_500 <- createDataSetFromCSV("compute-4000", "proving-profile-500-csv", "Method-list--CPU\\.csv", 500))

# rename headings 
proving_500 <- renameHeadings(proving_500, c('ExpID','ExpID.1', 'Method','Time_ms', 'OwnTime_ms', 'KeyLength', 'Vertices'))
str(proving_500)

filtered_500 <- filterMethods(proving_500)
dProving_500 <- filterProving(filtered_500)

(jitterOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "") )

(facetOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(facetOrderedMeanBarplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(dsummary_500 <- data_summary(dProving_500, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

v_50 <- bind_rows(dsummaryProving, .id="expID")
v_50['Vertices'] = 50

v_500 <- bind_rows(dsummary_500, .id = "expID")
v_500['Vertices'] = 500

dProving_50_500 <- rbind(v_50, v_500)

p <- (createMeanSDBarplots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

p + facet_grid(dProving_50_500$Vertices ~ dProving_50_500$KeyLength)
