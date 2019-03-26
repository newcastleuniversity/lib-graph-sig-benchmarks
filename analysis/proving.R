# proving computation results analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")

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

dProving <- filtered_50 #filterProving(filtered_50)

(jitterOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "") )
savePlot(last_plot(), "proving-jitter-ordered-boxplot.pdf")

(facetOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot(last_plot(), "proving-facet-ordered-boxplot.pdf")

(facetOrderedMeanBarplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot(last_plot(), "proving-ordered-mean-barplot.pdf")

(dsummaryProving <- data_summary(dProving, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummaryProving, dsummaryProving$Method, dsummaryProving$mean, dsummaryProving$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
savePlot(last_plot(), "proving-mean-sd-barplot.pdf")

# create dataframe from proving with 500 vertices
(proving_500 <- createDataSetFromCSV("compute-4000", "proving-profile-500-csv", "Method-list--CPU\\.csv", 500))

# rename headings 
proving_500 <- renameHeadings(proving_500, c('ExpID','ExpID.1', 'Method','Time_ms', 'OwnTime_ms', 'KeyLength', 'Vertices'))
str(proving_500)

filtered_500 <- filterMethods(proving_500)
dProving_500 <- filtered_500 #filterProving(filtered_500)

(jitterOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "") )
savePlot(last_plot(), "proving-jitter-ordered-boxplot-500.pdf")

(facetOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot(last_plot(), "proving-facet-ordered-boxplot-500.pdf")

(facetOrderedMeanBarplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot(last_plot(), "proving-ordered-mean-barplot-500.pdf")

(dsummary_500 <- data_summary(dProving_500, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
savePlot(last_plot(), "proving-mean-sd-barplot-500.pdf")

v_50 <- bind_rows(dsummaryProving, .id="expID")
v_50['Vertices'] = 50

v_500 <- bind_rows(dsummary_500, .id = "expID")
v_500['Vertices'] = 500

dProving_50_500 <- rbind(v_50, v_500)

p <- (createMeanSDBarplots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

p + facet_grid(dProving_50_500$Vertices ~ dProving_50_500$KeyLength)
savePlot(last_plot(), "proving-facet-mean-sd-barplot-50-500.pdf")

ol <- createOrderedLinePlots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, dProving_50_500$Vertices, "Methods", "Mean CPU time (ms)", "Key length")

(ol +  
    scale_linetype_manual(values=c("solid","twodash", "dotted", "dashed")) +
    theme(axis.text.x = element_text(angle = 77, vjust = 1, hjust=1)))
savePlot(last_plot(), "proving-facet-lineplot-50-500.pdf")

# calculate total proving time from ProverOrchestrator
## init() + executePreChallengePhase + computeChallenge + executePostChallenge

pmethods <- c("ProverOrchestrator.init", "ProverOrchestrator.executePreChallengePhase", "ProverOrchestrator.executePostChallengePhase", "ProverOrchestrator.computeChallenge", "ProverOrchestrator.computeCommitmentProvers", "ProverOrchestrator.computePairWiseProvers", "ProverOrchestrator.computeTildeZ")

# grepl(paste(pmethods, collapse = "|"), my_text)

(pOrchestrator <- dProving_50_500[with(dProving_50_500, grepl(paste(pmethods, collapse = "|"), dProving_50_500$Method)), ])


# detach plyr so we can work with dplyr otherwise the summation per group doesn't work
detach(package:plyr)    
library(dplyr)
(pOrchestrator_filtered <- pOrchestrator %>% 
    group_by(KeyLength, Vertices) %>%
    summarise(ProvingTime = sum(mean)))

ggplot(pOrchestrator_filtered, aes(x = reorder(factor( pOrchestrator_filtered$Vertices), pOrchestrator_filtered$ProvingTime), y = pOrchestrator_filtered$ProvingTime, group= pOrchestrator_filtered$KeyLength)) +
  geom_bar(stat = "summary", fun.y = "sum", position = "dodge", aes(fill = factor( pOrchestrator_filtered$KeyLength)))  +
  facet_grid(factor( pOrchestrator_filtered$KeyLength), margins = FALSE,  scales = "free", space = "free") +
  labs( x = "Graph size (number of vertices)",  y = "Proving time (ms)", fill = "") +
  # coord_flip() +  
  theme_bw()

ggplot() +
  geom_line(aes(x=factor(pOrchestrator_filtered$Vertices), y=pOrchestrator_filtered$ProvingTime, group=pOrchestrator_filtered$KeyLength, color=factor(pOrchestrator_filtered$KeyLength)), pOrchestrator_filtered) +
  # geom_point(data=pOrchestrator_filtered, aes(x=factor(pOrchestrator_filtered$Vertices), y=pOrchestrator_filtered$ProvingTime, color=factor(pOrchestrator_filtered$KeyLength),    shape=factor(pOrchestrator_filtered$KeyLength))) + 
  geom_line(aes(x=factor(pOrchestrator$Vertices), y=pOrchestrator$mean, group=factor(pOrchestrator$Method), color=factor(pOrchestrator$Method)), pOrchestrator) + 
  
  # geom_line(aes(x=factor(signer_issuing_time$Vertices), y=signer_issuing_time$IssuingTime, group=signer_issuing_time$KeyLength, color=factor(signer_issuing_time$KeyLength), linetype=factor(signer_issuing_time$KeyLength)), signer_issuing_time) +
  # geom_point(data=signer_issuing_time, aes(x=factor(signer_issuing_time$Vertices), y=signer_issuing_time$IssuingTime), color=factor(signer_issuing_time$KeyLength), shape=factor(total_issuing_time$KeyLength), size=2, fill="black") +
  
  # facet_grid(pOrchestrator_filtered$KeyLength) +
  labs( x = "Graph size (number of vertices)",  y = "Proving time (ms)", color = "", shape = "Key length") +
  theme_bw()

ggplot(pOrchestrator, aes(x = reorder(factor( pOrchestrator$Vertices), pOrchestrator$mean), y = pOrchestrator$mean, group= pOrchestrator$Method)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor( pOrchestrator$Method)))  +
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.25, position=position_dodge(0.9)) +
  facet_grid(factor( pOrchestrator$KeyLength), margins = FALSE,  scales = "free", space = "free") +
  labs( x = "Graph size (number of vertices)",  y = "Proving time (ms)", fill = "") +
  # coord_flip() +  
  theme_bw()


