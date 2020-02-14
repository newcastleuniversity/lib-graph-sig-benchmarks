# issuing computation results analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# create dataframes for 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 and 10000 encoded vertices
numberOfVertices <- c("1000", "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000")
totalVertices <- c("3000", "12000", "17000", "21000", "26000") #, "36000", "41000", "46000", "51000", "57000" )
keyLengths <- c("512", "1024", "2048", "3072")

lengthVertices <- length(numberOfVertices)
iss <- data.frame()

# iterate over all performance experiments for different number of vertices and create a dataframe for all observations from the csv files 
for (i in seq_along(numberOfVertices)) {
  print(i)
  # path <- paste("issuing-profile-",numberOfVertices[i],"-csv",sep = "")
  path <- paste("issuing-csv-",numberOfVertices[i],sep = "")
  print(path)
  # csvFolder <- paste("issuing-", totalVertices[i], sep = "")
  csvFolder <- paste("issuing-signer-infra-",numberOfVertices[i], sep = "")
  print(csvFolder)
  # iss_temp <- createDataSetFromCSV("issuing-null", path , "Method-list--CPU\\.csv", numberOfVertices[i])
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Call-tree--by-thread\\.csv", numberOfVertices[i])
  iss <- rbind(iss, iss_temp)
  print(numberOfVertices[i])
}

# rename headings
issuing <- renameHeadings(iss, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing)

filtered <- filterMethods(issuing)
(filtered_signer <- filtered[with(filtered, grepl("SignerOrchestrator.java:536  QRElement.modPow", filtered$Method)), ])
str(filtered_signer)

scatter.smooth(x = factor(filtered_signer$KeyLength), y = filtered_signer$Time_ms, main = "KeyLength ~ Time_ms") # scatterplot

summary(filtered_signer$Time_ms)
max(filtered_signer$Time_ms)
table(filtered_signer$Time_ms)
hist(filtered_signer$Time_ms)

(kmean <- mean(filtered_signer$Time_ms))

ggplot(filtered_signer, aes(x = filtered_signer$Time_ms)) +
  geom_histogram(binwidth = 2)

ggplot(filtered_signer, aes(x = filtered_signer$Time_ms)) +
  geom_density(adjust = 0.25)

(signer_issuing_time <- data_summary(filtered_signer, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))


ggplot(signer_issuing_time, aes(x = reorder(factor(signer_issuing_time$Vertices)), y = signer_issuing_time$mean, group = signer_issuing_time$KeyLength)) +
  geom_line(aes(linetype = factor(signer_issuing_time$KeyLength), color = factor(signer_issuing_time$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(signer_issuing_time$KeyLength), shape = factor(signer_issuing_time$KeyLength))) +
  # facet_wrap(signer_issuing_time$Type ~ ., scales = "free_y", ncol = 3) +
  labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", color = "Key length", shape = "") + 
  # coord_trans( y="log2") +
  # coord_trans( y="log10") +
  # scale_y_continuous(labels = scientific) +
  # annotation_logticks() +
  # scale_y_continuous(trans = log2_trans(),
  # breaks = trans_breaks("log2", function(x) 2^x),
  # labels = trans_format("log2", math_format(2^.x))) +
  # scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #               labels = trans_format("log10", math_format(10^.x))) +
  guides(shape = FALSE, linetype = FALSE) +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )
# signer_issuing_time <- edit(signer_issuing_time)
# str(filtered$Method)
# str(filtered$Time_ms)
# length(filtered$Time_ms)
# length(filtered$Method)
# head(filtered)

# filter dataframe to include only methods with cpu time > 50 ms
filtered <- filter(filtered, filtered$Time_ms > 0)

filteredSmall <- filter(filtered, filtered$Time_ms < 50)

(uniqueM <- unique(filtered$Method))

dIssuing <- filterIssuing(filtered)

# (jitterOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", ""))

# savePlot("issuing-jitter-ordered-boxplot.pdf")

# (facetOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))

# savePlot("issuing-facet-ordered-boxplot.pdf")

(facetOrderedMeanBarplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("issuing-facet-ordered-mean-barplot.pdf")

(cpuKeySummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength")))

ggplot(cpuKeySummary, aes(x = factor(cpuKeySummary$KeyLength), y = cpuKeySummary$mean, fill = factor(cpuKeySummary$KeyLength))) +
  geom_bar(stat = "identity", position = position_dodge()) +
  theme_bw() +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
    width = .15,
    position = position_dodge(0.9)
  ) +
  labs(x = "Key length", y = "Mean CPU time (ms)", fill = "Key length")

(dsummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary, dsummary$Method, dsummary$mean, dsummary$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

savePlot("issuing-facet-mean-sd-barplot.pdf")

# plot means
# plotmeans(filtered_50$Time_ms ~ filtered_50$Method, digits = 3, ccol = "red", xlab = "Methods", ylab = "CPU time for issuing methods (msec)", las = 2, cex.axis = 0.4, mean.labels = F, mar = c(10.1, 4.1, 4.1, 2.1), n.label = FALSE, mgp = c(3, 1, 0), main = "Plot of issuing methods")

# create dataframe from issuing with 500 vertices
# (issuing_500 <- createDataSetFromCSV("issuing-3000", "issuing-profile-500-csv", "Method-list--CPU\\.csv", 500))

dIssuing <- renameHeadings(dIssuing, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))

# rename headings
# issuing_500 <- renameHeadings(issuing_500, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
# str(issuing_500)
# 
# filtered_500 <- filterMethods(issuing_500)
# dIssuing_500 <- filterIssuing(filtered_500)

# (jitterOrderedBoxplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", ""))
# savePlot("issuing-jitter-ordered-boxplot-500.pdf")

(facetOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("issuing-facet-ordered-boxplot-10000.pdf")

(facetOrderedMeanBarplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("issuing-facet-ordered-mean-barplot-10000.pdf")

(dsummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

(createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
savePlot("issuing-mean-sd-barplot-10000.pdf")

# v_50 <- bind_rows(dsummary, .id = "expID")
# v_50["Vertices"] <- 50
# 
# v_500 <- bind_rows(dsummary_500, .id = "expID")
# v_500["Vertices"] <- 500
# 
# dIssuing_50_500 <- rbind(v_50, v_500)

p <- (createMeanSDBarplots(dsummary, dsummary$Method, dsummary$mean, dsummary$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

p + facet_grid(dsummary$Vertices ~ dsummary$KeyLength)
savePlot("issuing-facet-mean-sd-barplot-10000.pdf")

# measure total issuing time for both parties
(filtered <- dsummary[with(dsummary, grepl("*.round*", dsummary$Method)), ])
str(filtered)
 
# (filteredModPow <- dsummary[with(dsummary, grepl("*QRElement.modPow*", dsummary$Method)), ])
(filteredModPow <- unique(issuing[with(issuing, grepl("*QRElement.modPow*", issuing$Method)), ]))
str(filteredModPow)
(dsummaryModPow <- data_summary(filteredModPow, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

# detach plyr so we can work with dplyr otherwise the summation per group doesn't work
detach(package:plyr)
library(dplyr)
(total_issuing_time <- dsummaryModPow %>%
  group_by(KeyLength, Vertices) %>%
    summarise(IssuingTime = sum(mean), SD = sum(sd), SE = sum(se)))

total_issuing_time <- bind_rows(total_issuing_time, .id = "Type")
total_issuing_time["Type"] <- "Total issuing time"

(signer_filtered <- filtered[with(filtered, grepl("SignerOrchestrator.*", filtered$Method)), ])

(signer_issuing_time <- signer_filtered %>%
  group_by(KeyLength, Vertices) %>%
    summarise(IssuingTime = sum(mean), SD = sum(sd), SE = sum(se)))

# signer_issuing_time$Type = "Signer issuing time"
signer_issuing_time <- bind_rows(signer_issuing_time, .id = "Type")
signer_issuing_time["Type"] <- "Signer issuing time"
issuing_time <- rbind(total_issuing_time, signer_issuing_time)

(recipient_filtered <- filtered[with(filtered, grepl("RecipientOrchestrator.*", filtered$Method)), ])

summary(recipient_filtered)

(recipient_issuing_time <- recipient_filtered %>%
  group_by(KeyLength, Vertices)      %>%
  summarise(IssuingTime = sum(mean), SD = sum(sd), SE = sum(se)))

# recipient_issuing_time$Type = "Recipient issuing time"

recipient_issuing_time <- bind_rows(recipient_issuing_time, .id = "Type")
recipient_issuing_time["Type"] <- "Recipient issuing time"

(issuing_time <- rbind(issuing_time, recipient_issuing_time))
str(issuing_time)

ggplot(dsummaryModPow, aes(x = reorder(factor(dsummaryModPow$Vertices)), y = dsummaryModPow$mean, group = dsummaryModPow$KeyLength)) +
  geom_line(aes(linetype = factor(dsummaryModPow$KeyLength), color = factor(dsummaryModPow$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(dsummaryModPow$KeyLength), shape = factor(dsummaryModPow$KeyLength))) +
  # facet_wrap(dsummaryModPow$Type ~ ., scales = "free_y", ncol = 3) +
  labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", color = "Key length", shape = "") + 
   # coord_trans( y="log2") +
   # coord_trans( y="log10") +
   # scale_y_continuous(labels = scientific) +
  # annotation_logticks() +
  # scale_y_continuous(trans = log2_trans(),
                     # breaks = trans_breaks("log2", function(x) 2^x),
                     # labels = trans_format("log2", math_format(2^.x))) +
  # scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #               labels = trans_format("log10", math_format(10^.x))) +
  guides(shape = FALSE, linetype = FALSE) +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )

kDataFile <- "issuingData"
kCSVFilePath <- paste0(paperDataFolderPath, kDataFile, ".csv", collapse = "")
writeCSV(issuing_time,kCSVFilePath)

savePlot("issuing-time-line-plot.pdf")

ggplot(issuing_time, aes(x = reorder(factor(issuing_time$Vertices), issuing_time$IssuingTime), y = issuing_time$IssuingTime, group = issuing_time$Type)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(issuing_time$Type))) +
  facet_grid(factor(issuing_time$KeyLength), margins = FALSE, scales = "free", space = "free") +
  labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", fill = "") +
  # background_grid(major = "xy", minor = "none") +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )

savePlot("issuing-time-bar-plot.pdf")

to_string_is <- as_labeller(c(`Total issuing time` = "Total issuing time", `Signer issuing time` = "Signer Issuing time", `Recipient issuing time` = "Recipient Issuing time"))

ggplot(issuing_time, aes(x = reorder(factor(issuing_time$Vertices)), y = issuing_time$mean, group = issuing_time$KeyLength)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(issuing_time$KeyLength))) +
  facet_wrap(issuing_time$Type ~ ., scales = "free_y", labeller = to_string_is, ncol = 3) +
  labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", fill = "Key Length") +
  # background_grid(major = "xy", minor = "none") +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside", aspect.ratio = 1.4
  )

savePlot("issuing-time-key-length-barplot.pdf")
