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

# scatter.smooth(x=factor(filtered_50$Method), y=filtered_50$Time_ms, main="Method ~ Time_ms")  # scatterplot

summary(filtered_50$Time_ms)
max(filtered_50$Time_ms)
# table(filtered_50$Time_ms)
hist(filtered_50$Time_ms)

ggplot(filtered_50, aes(x = filtered_50$Time_ms)) + 
  geom_histogram(binwidth = 2)

(uniqueM <- unique(filtered_50$Method))

dProving <- filterProving(filtered_50)

# (jitterOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "") )
# savePlot(last_plot(), "proving-jitter-ordered-boxplot.pdf")

(facetOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("proving-facet-ordered-boxplot.pdf")

(facetOrderedMeanBarplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("proving-ordered-mean-barplot.pdf")

(dsummaryProving <- data_summary(dProving, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummaryProving, dsummaryProving$Method, dsummaryProving$mean, dsummaryProving$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
savePlot("proving-mean-sd-barplot.pdf")

# create dataframe from proving with 500 vertices
(proving_500 <- createDataSetFromCSV("compute-4000", "proving-profile-500-csv", "Method-list--CPU\\.csv", 500))

# rename headings 
proving_500 <- renameHeadings(proving_500, c('ExpID','ExpID.1', 'Method','Time_ms', 'OwnTime_ms', 'KeyLength', 'Vertices'))
str(proving_500)

filtered_500 <- filterMethods(proving_500)
dProving_500 <- filterProving(filtered_500)

# (jitterOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "") )
# savePlot("proving-jitter-ordered-boxplot-500.pdf")

(facetOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("proving-facet-ordered-boxplot-500.pdf")

(facetOrderedMeanBarplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
savePlot("proving-ordered-mean-barplot-500.pdf")

(dsummary_500 <- data_summary(dProving_500, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
savePlot("proving-mean-sd-barplot-500.pdf")

v_50 <- bind_rows(dsummaryProving, .id="expID")
v_50['Vertices'] = 50

v_500 <- bind_rows(dsummary_500, .id = "expID")
v_500['Vertices'] = 500

dProving_50_500 <- rbind(v_50, v_500)

p <- (createMeanSDBarplots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))

p + facet_grid(dProving_50_500$Vertices ~ dProving_50_500$KeyLength)
savePlot("proving-facet-mean-sd-barplot-50-500.pdf")

ol <- createOrderedLinePlots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, dProving_50_500$Vertices, "Methods", "Mean CPU time (ms)", "Key length")

(ol +  
    scale_linetype_manual(values=c("solid","twodash", "dotted", "dashed")) +
    theme(axis.text.x = element_text(angle = 77, vjust = 1, hjust=1)))
savePlot("proving-facet-lineplot-50-500.pdf")

# calculate total proving time from ProverOrchestrator
## init() + executePreChallengePhase + computeChallenge + executePostChallenge

pmethods <- c("ProverOrchestrator.init", "ProverOrchestrator.executePreChallengePhase", "ProverOrchestrator.executePostChallengePhase", "ProverOrchestrator.computeChallenge", "ProverOrchestrator.computeCommitmentProvers", "ProverOrchestrator.computePairWiseProvers", "ProverOrchestrator.computeTildeZ")

# grepl(paste(pmethods, collapse = "|"), my_text)

(pOrchestrator <- dProving_50_500[with(dProving_50_500, grepl(paste(pmethods, collapse = "|"), dProving_50_500$Method)), ])


# detach plyr so we can work with dplyr otherwise the summation per group doesn't work
# detach(package:plyr)   
# # library(plyr)
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

savePlot("pOrchestrator-proving-50-500.pdf")


ggplot() +
  geom_line(aes(x = factor(pOrchestrator_filtered$Vertices), y = pOrchestrator_filtered$ProvingTime, group = pOrchestrator_filtered$KeyLength, color = factor(pOrchestrator_filtered$KeyLength)), pOrchestrator_filtered) +
  # geom_point(data=pOrchestrator_filtered, aes(x=factor(pOrchestrator_filtered$Vertices), y=pOrchestrator_filtered$ProvingTime, color=factor(pOrchestrator_filtered$KeyLength),    shape=factor(pOrchestrator_filtered$KeyLength))) + 
  geom_line(aes(x = factor(pOrchestrator$Vertices), y = pOrchestrator$mean, group = factor(pOrchestrator$Method), color = factor(pOrchestrator$Method)), pOrchestrator) + 
  
  # geom_line(aes(x=factor(signer_issuing_time$Vertices), y=signer_issuing_time$IssuingTime, group=signer_issuing_time$KeyLength, color=factor(signer_issuing_time$KeyLength), linetype=factor(signer_issuing_time$KeyLength)), signer_issuing_time) +
  # geom_point(data=signer_issuing_time, aes(x=factor(signer_issuing_time$Vertices), y=signer_issuing_time$IssuingTime), color=factor(signer_issuing_time$KeyLength), shape=factor(total_issuing_time$KeyLength), size=2, fill="black") +
  
  # facet_grid(pOrchestrator_filtered$KeyLength) +
  labs( x = "Graph size (number of vertices)",  y = "Proving time (ms)", color = "", shape = "Key length") +
  theme_bw()

ggplot(pOrchestrator, aes(x = reorder(factor( pOrchestrator$Vertices), pOrchestrator$mean), y = pOrchestrator$mean, group = pOrchestrator$Method)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor( pOrchestrator$Method)))  +
  geom_errorbar(aes(ymin = mean-sd, ymax=mean+sd), width = .25, position = position_dodge(0.9)) +
  facet_grid(factor( pOrchestrator$KeyLength), margins = FALSE,  scales = "free", space = "free") +
  labs( x = "Graph size (number of vertices)",  y = "Proving time (ms)", fill = "") 
  # coord_flip() +  
  # theme_bw()

savePlot( "pOrchestrator-methods-proving-50-500.pdf")

# calculate verifying time from VerifierOrchestrator
vmethods <- c( "VerifierOrchestrator.computeChallenge", "VerifierOrchestrator.computeCommitmentVerifiers", "VerifierOrchestrator.computePairWiseVerifiers", "VerifierOrchestrator.executeVerification", "PossessionVerifier.executeCompoundVerification")

(vOrchestrator <- dProving_50_500[with(dProving_50_500, grepl(paste(vmethods, collapse = "|"), dProving_50_500$Method)), ])
# detach(package:cowplot)
ggplot(vOrchestrator, aes(x = reorder(factor( vOrchestrator$Vertices), vOrchestrator$mean), y = vOrchestrator$mean, group = vOrchestrator$KeyLength)) +
  geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor( vOrchestrator$KeyLength)))  +
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = .25, position = position_dodge(0.9)) +
  # facet_grid(. ~ vOrchestrator$Method,  scales='free_y') +
  facet_wrap(~ vOrchestrator$Method, ncol = 5) +
  labs( x = "Graph size (number of vertices)",  y = "Verifying time (ms)", fill = "Key Length") 
   # background_grid(major = "xy", minor = "none")

poss_verifier <- vOrchestrator %>% 
  filter(Method == 'PossessionVerifier.executeCompoundVerification')

(poss_verifier_lp <- ggplot(poss_verifier, aes(x = factor(poss_verifier$Vertices), y = poss_verifier$mean, group = poss_verifier$KeyLength, colour = factor(poss_verifier$KeyLength))) +
  geom_line() +
  geom_point() +
  labs( x = "Graph size (number of vertices)",  y = "Verifying time (ms)", colour= "Key length")) 

comm_verifier <- vOrchestrator %>%
  filter(Method == 'VerifierOrchestrator.computeCommitmentVerifiers')

(comm_verifier_lp <- ggplot(comm_verifier, aes(x = factor(comm_verifier$Vertices), y = comm_verifier$mean, group = comm_verifier$KeyLength, colour = factor(comm_verifier$KeyLength))) +
  geom_line() +
  geom_point() +
  labs( x = "Graph size (number of vertices)",  y = "Verifying time (ms)", colour= "Key length")) 


pair_wise_verifier <- vOrchestrator %>%
  filter(Method == 'VerifierOrchestrator.computePairWiseVerifiers')

(pair_wise_verifier_lp <- ggplot(pair_wise_verifier, aes(x = factor(pair_wise_verifier$Vertices), y = pair_wise_verifier$mean, group = pair_wise_verifier$KeyLength, colour = factor(pair_wise_verifier$KeyLength))) +
  geom_line() +
  geom_point() +
  labs( x = "Graph size (number of vertices)",  y = "Verifying time (ms)", colour= "Key length"))


exec_verifier <- vOrchestrator %>%
  filter(Method == 'VerifierOrchestrator.executeVerification')

(exec_verifier_lp <- ggplot(exec_verifier, aes(x = factor(exec_verifier$Vertices), y = exec_verifier$mean, group = exec_verifier$KeyLength, colour = factor(exec_verifier$KeyLength))) +
  geom_line() +
  geom_point() +
  labs( x = "Graph size (number of vertices)",  y = "Verifying time (ms)", colour= "Key length"))

# library(patchwork)
# poss_verifier_lp + comm_verifier_lp + pair_wise_verifier_lp + exec_verifier_lp
library(cowplot)
plot_grid(poss_verifier_lp+ background_grid(major = "xy", minor = "none"),
         comm_verifier_lp+ background_grid(major = "xy", minor = "none"),
         pair_wise_verifier_lp+ background_grid(major = "xy", minor = "none"),
         exec_verifier_lp+ background_grid(major = "xy", minor = "none"),
         labels = c('Possession Verifier','Commitments Verifier', 'Pair Wise Verifier', "Verification"),
         # label_x= 0.01,
         vjust = 0.5,
         # align="h", axis="tb",
         ncol = 2)


savePlot("vOrchestrator-verifying-50-500.pdf")

 
