# issuing computation results analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

# create dataframe from issuing with 50 vertices
(issuing_50 <- createDataSetFromCSV("issuing-400", "issuing-profile-50-csv", "Method-list--CPU\\.csv", 50))

# rename headings
issuing_50 <- renameHeadings(issuing_50, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing_50)

filtered_50 <- filterMethods(issuing_50)

scatter.smooth(x = factor(filtered_50$Method), y = filtered_50$Time_ms, main = "Method ~ Time_ms") # scatterplot

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

(jitterOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", ""))

savePlot("issuing-jitter-ordered-boxplot.pdf")

(facetOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))

savePlot("issuing-facet-ordered-boxplot.pdf")

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
plotmeans(filtered_50$Time_ms ~ filtered_50$Method, digits = 3, ccol = "red", xlab = "Methods", ylab = "CPU time for issuing methods (msec)", las = 2, cex.axis = 0.4, mean.labels = F, mar = c(10.1, 4.1, 4.1, 2.1), n.label = FALSE, mgp = c(3, 1, 0), main = "Plot of issuing methods")

# create dataframe from issuing with 500 vertices
(issuing_500 <- createDataSetFromCSV("issuing-3000", "issuing-profile-500-csv", "Method-list--CPU\\.csv", 500))

# rename headings
issuing_500 <- renameHeadings(issuing_500, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing_500)

filtered_500 <- filterMethods(issuing_500)
dIssuing_500 <- filterIssuing(filtered_500)

(jitterOrderedBoxplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", ""))
savePlot("issuing-jitter-ordered-boxplot-500.pdf")

(facetOrderedBoxplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("issuing-facet-ordered-boxplot-500.pdf")

(facetOrderedMeanBarplot(dIssuing_500, dIssuing_500$Method, dIssuing_500$Time_ms, dIssuing_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("issuing-facet-ordered-mean-barplot-500.pdf")

(dsummary_500 <- data_summary(dIssuing_500, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
savePlot("issuing-mean-sd-barplot-500.pdf")

v_50 <- bind_rows(dsummary, .id = "expID")
v_50["Vertices"] <- 50

v_500 <- bind_rows(dsummary_500, .id = "expID")
v_500["Vertices"] <- 500

dIssuing_50_500 <- rbind(v_50, v_500)

p <- (createMeanSDBarplots(dIssuing_50_500, dIssuing_50_500$Method, dIssuing_50_500$mean, dIssuing_50_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

p + facet_grid(dIssuing_50_500$Vertices ~ dIssuing_50_500$KeyLength)
savePlot("issuing-facet-mean-sd-barplot-50-500.pdf")

# measure total issuing time for both parties
(filtered <- dIssuing_50_500[with(dIssuing_50_500, grepl("*.round*", dIssuing_50_500$Method)), ])
str(filtered)

# detach plyr so we can work with dplyr otherwise the summation per group doesn't work
detach(package:plyr)
library(dplyr)
(total_issuing_time <- filtered %>%
  group_by(KeyLength, Vertices) %>%
  summarise(IssuingTime = sum(mean)))

total_issuing_time <- bind_rows(total_issuing_time, .id = "Type")
total_issuing_time["Type"] <- "Total issuing time"

(signer_filtered <- filtered[with(filtered, grepl("SignerOrchestrator.*", filtered$Method)), ])

(signer_issuing_time <- signer_filtered %>%
  group_by(KeyLength, Vertices) %>%
  summarise(IssuingTime = sum(mean)))


# signer_issuing_time$Type = "Signer issuing time"
signer_issuing_time <- bind_rows(signer_issuing_time, .id = "Type")
signer_issuing_time["Type"] <- "Signer issuing time"
issuing_time <- rbind(total_issuing_time, signer_issuing_time)

(recipient_filtered <- filtered[with(filtered, grepl("RecipientOrchestrator.*", filtered$Method)), ])

(recipient_issuing_time <- recipient_filtered %>%
  group_by(KeyLength, Vertices) %>%
  summarise(IssuingTime = sum(mean)))
# recipient_issuing_time$Type = "Recipient issuing time"

recipient_issuing_time <- bind_rows(recipient_issuing_time, .id = "Type")
recipient_issuing_time["Type"] <- "Recipient issuing time"

(issuing_time <- rbind(issuing_time, recipient_issuing_time))
str(issuing_time)

ggplot(issuing_time, aes(x = reorder(factor(issuing_time$Vertices)), y = issuing_time$IssuingTime, group = issuing_time$KeyLength)) +
  geom_line(aes(linetype = factor(issuing_time$KeyLength), color = factor(issuing_time$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(issuing_time$KeyLength), shape = factor(issuing_time$KeyLength))) +
  facet_wrap(issuing_time$Type ~ ., scales = "free_y", ncol = 3) +
  labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", color = "Key length", shape = "") +
  guides(shape = FALSE, linetype = FALSE) +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )

savePlot("issuing-time-line-plot.pdf")

ggplot(issuing_time, aes(x = reorder(factor(issuing_time$Vertices), issuing_time$IssuingTime), y = issuing_time$IssuingTime, group = issuing_time$Type)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(issuing_time$Type))) +
  facet_grid(factor(issuing_time$KeyLength), margins = FALSE, scales = "free", space = "free") +
  labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", fill = "") +
  background_grid(major = "xy", minor = "none") +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )

savePlot("issuing-time-bar-plot.pdf")

to_string_is <- as_labeller(c(`Total issuing time` = "Total issuing time", `Signer issuing time` = "Signer Issuing time", `Recipient issuing time` = "Recipient Issuing time"))

ggplot(issuing_time, aes(x = reorder(factor(issuing_time$Vertices)), y = issuing_time$IssuingTime, group = issuing_time$KeyLength)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(issuing_time$KeyLength))) +
  facet_wrap(issuing_time$Type ~ ., scales = "free_y", labeller = to_string_is, ncol = 3) +
  labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", fill = "Key Length") +
  background_grid(major = "xy", minor = "none") +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside", aspect.ratio = 1.4
  )

savePlot("issuing-time-key-length-barplot.pdf")
