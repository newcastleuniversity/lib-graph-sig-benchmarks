# proving computation results analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")

## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# create dataframes for 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 and 10000 encoded vertices
numberOfVertices <- c("1000", "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000")
keyLengths <- c("512", "1024", "2048", "3072")

lengthVertices <- length(numberOfVertices)
iss <- data.frame()

# iterate over all performance experiments for different number of vertices and create a dataframe for all observations from the csv files 
for (i in seq_along(numberOfVertices)) {
  # print(i)
  path <- paste("proving-csv-new-",numberOfVertices[i],sep = "")
  # print(path)
  csvFolder <- paste("compute-signer-infra-",numberOfVertices[i], sep = "")
  # print(csvFolder)
  # iss_temp <- createDataSetFromCSV(csvFolder, path , "Call-tree--by-thread\\.csv", numberOfVertices[i])
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Method-list--CPU\\.csv", numberOfVertices[i])
  iss <- rbind(iss, iss_temp)
   print(numberOfVertices[i])
}

# rename headings
proving <- renameHeadings(iss, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(proving)

(fproving <- filterMethods(proving))

dProving <- filterProving(fproving)

# (filtered_proving <- dProving[with(dProving, grepl("QRElement.modPow", dProving$Method)), ])

# create line plot for commitmentProvers
(filtered_proving <- dProving[with(dProving, grepl("ProverOrchestrator.computeCommitmentProvers", dProving$Method)), ])

(commitment_provers <- data_summary(filtered_proving, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

ggplot(commitment_provers, aes(x = reorder(factor(commitment_provers$Vertices)), y = commitment_provers$mean, group = commitment_provers$KeyLength)) +
  geom_errorbar(aes(colour = factor(commitment_provers$KeyLength), ymin = mean - se, ymax = mean + se), width= .1) +
  geom_line(aes(linetype = factor(commitment_provers$KeyLength), color = factor(commitment_provers$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(commitment_provers$KeyLength), shape = factor(commitment_provers$KeyLength))) +
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

# create line plot for possession prover
(filtered_proving <- dProving[with(dProving, grepl("ProverOrchestrator.computeTildeZ", dProving$Method)), ])

(possession_prover <- data_summary(filtered_proving, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

ggplot(possession_prover, aes(x = reorder(factor(possession_prover$Vertices)), y = possession_prover$mean, group = possession_prover$KeyLength)) +
  geom_errorbar(aes(colour = factor(possession_prover$KeyLength), ymin = mean - se, ymax = mean + se), width= .1) +
  geom_line(aes(linetype = factor(possession_prover$KeyLength), color = factor(possession_prover$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(possession_prover$KeyLength), shape = factor(possession_prover$KeyLength))) +
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

(pmethods <- c("ProverOrchestrator.computeCommitmentProvers", "ProverOrchestrator.computeTildeZ"))

# create compound csv dataframe for proving stage
(proving <- dProving[with(dProving, grepl(paste(pmethods, collapse = "|"), dProving$Method)), ])
(provingCSV <- data_summary(proving, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

pDataFile <- "provingData"
pCSVFilePath <- paste0(paperDataFolderPath, pDataFile, ".csv", collapse = "")
writeCSV(provingCSV, pCSVFilePath)

# create line plot for commitment verifiers
(filtered_proving <- dProving[with(dProving, grepl("VerifierOrchestrator.computeCommitmentVerifiers", dProving$Method)), ])

(commitment_verifiers <- data_summary(filtered_proving, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

ggplot(commitment_verifiers, aes(x = reorder(factor(commitment_verifiers$Vertices)), y = commitment_verifiers$mean, group = commitment_verifiers$KeyLength)) +
  geom_errorbar(aes(colour = factor(commitment_verifiers$KeyLength), ymin = mean - se, ymax = mean + se), width= .1) +
  geom_line(aes(linetype = factor(commitment_verifiers$KeyLength), color = factor(commitment_verifiers$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(commitment_verifiers$KeyLength), shape = factor(commitment_verifiers$KeyLength))) +
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

# create line plot for possession verifiers
(filtered_proving <- dProving[with(dProving, grepl("PossessionVerifier.executeCompoundVerification", dProving$Method)), ])

(possession_verifier <- data_summary(filtered_proving, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

ggplot(possession_verifier, aes(x = reorder(factor(possession_verifier$Vertices)), y = possession_verifier$mean, group = commitment_verifiers$KeyLength)) +
  geom_errorbar(aes(colour = factor(possession_verifier$KeyLength), ymin = mean - se, ymax = mean + se), width= .1) +
  geom_line(aes(linetype = factor(possession_verifier$KeyLength), color = factor(possession_verifier$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(possession_verifier$KeyLength), shape = factor(possession_verifier$KeyLength))) +
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

(vmethods <- c("VerifierOrchestrator.computeCommitmentVerifiers", "PossessionVerifier.executeCompoundVerification"))

# create compound csv dataframe for verification stage
(verification <- dProving[with(dProving, grepl(paste(vmethods, collapse = "|"), dProving$Method)), ])
(verificationCSV <- data_summary(verification, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

vDataFile <- "verificationData"
vCSVFilePath <- paste0(paperDataFolderPath, vDataFile, ".csv", collapse = "")
writeCSV(verificationCSV, vCSVFilePath)


# (facetOrderedBoxplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))
# 
# savePlot("proving-facet-ordered-boxplot.pdf")
# 
# (facetOrderedMeanBarplot(dProving, dProving$Method, dProving$Time_ms, dProving$KeyLength, "Methods", "CPU time (ms)", "Key length"))
# savePlot("proving-ordered-mean-barplot.pdf")
# 
# (dsummaryProving <- data_summary(dProving, varname = "Time_ms", groupnames = c("KeyLength", "Method")))
# 
# (createMeanSDBarplots(dsummaryProving, dsummaryProving$Method, dsummaryProving$mean, dsummaryProving$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
# savePlot("proving-mean-sd-barplot.pdf")
# 
# # create dataframe from proving with 500 vertices
# (proving_500 <- createDataSetFromCSV("compute-4000", "proving-profile-500-csv", "Method-list--CPU\\.csv", 500))
# 
# # rename headings
# proving_500 <- renameHeadings(proving_500, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
# str(proving_500)
# 
# filtered_500 <- filterMethods(proving_500)
# dProving_500 <- filterProving(filtered_500)
# 
# # (jitterOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "") )
# # savePlot("proving-jitter-ordered-boxplot-500.pdf")
# 
# (facetOrderedBoxplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
# savePlot("proving-facet-ordered-boxplot-500.pdf")
# 
# (facetOrderedMeanBarplot(dProving_500, dProving_500$Method, dProving_500$Time_ms, dProving_500$KeyLength, "Methods", "CPU time (ms)", "Key length"))
# savePlot("proving-ordered-mean-barplot-500.pdf")
# 
# (dsummary_500 <- data_summary(dProving_500, varname = "Time_ms", groupnames = c("KeyLength", "Method")))
# 
# (createMeanSDBarplots(dsummary_500, dsummary_500$Method, dsummary_500$mean, dsummary_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
# 
# savePlot("proving-mean-sd-barplot-500.pdf")
# 
# v_50 <- bind_rows(dsummaryProving, .id = "expID")
# v_50["Vertices"] <- 50
# 
# v_500 <- bind_rows(dsummary_500, .id = "expID")
# v_500["Vertices"] <- 500
# 
# dProving_50_500 <- rbind(v_50, v_500)
# 
# p <- (createMeanSDBarplots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, "Methods", "Mean CPU time (ms)", "Key length"))
# 
# p + facet_grid(dProving_50_500$Vertices ~ dProving_50_500$KeyLength)
# savePlot("proving-facet-mean-sd-barplot-50-500.pdf")
# 
# ol <- createOrderedLinePlots(dProving_50_500, dProving_50_500$Method, dProving_50_500$mean, dProving_50_500$KeyLength, dProving_50_500$Vertices, "Methods", "Mean CPU time (ms)", "Key length")
# 
# (ol + scale_linetype_manual(values = c("solid", "twodash", "dotted", "dashed")) + theme(axis.text.x = element_text(angle = 77, vjust = 1, hjust = 1)))
# savePlot("proving-facet-lineplot-50-500.pdf")
# 
# # calculate total proving time from ProverOrchestrator
# # init() + executePreChallengePhase + computeChallenge + executePostChallenge
# 
# (pmethods <- c("ProverOrchestrator.init", "ProverOrchestrator.executePreChallengePhase", "ProverOrchestrator.executePostChallengePhase", "ProverOrchestrator.computeChallenge", "ProverOrchestrator.computeCommitmentProvers", "ProverOrchestrator.computePairWiseProvers", "ProverOrchestrator.computeTildeZ"))
# 
# # grepl(paste(pmethods, collapse = ""), my_text)
# 
# (pOrchestrator <- dProving_50_500[with(dProving_50_500, grepl(paste(pmethods, collapse = "|"), dProving_50_500$Method)), ])
# 
# # detach plyr so we can work with dplyr otherwise the summation per group doesn't work
# #
# detach(package:plyr)
# # # library(plyr)
# library(dplyr)
# 
# (pOrchestrator_filtered <- pOrchestrator %>%
#   group_by(KeyLength, Vertices) %>%
#   summarise(ProvingTime = sum(mean)))
# 
# ggplot(pOrchestrator_filtered, aes(x = reorder(factor(pOrchestrator_filtered$Vertices), pOrchestrator_filtered$ProvingTime), y = pOrchestrator_filtered$ProvingTime, group = pOrchestrator_filtered$KeyLength)) +
#   geom_bar(stat = "summary", fun.y = "sum", position = "dodge", aes(fill = factor(pOrchestrator_filtered$KeyLength))) +
#   facet_grid(factor(pOrchestrator_filtered$KeyLength), margins = FALSE, scales = "free", space = "free") +
#   labs(x = "Graph size (number of vertices)", y = "Proving time (ms)", fill = "") # coord_flip() + theme_bw()
# 
# savePlot("pOrchestrator-proving-50-500.pdf")
# 
# to_string_p <- as_labeller(c(`ProverOrchestrator.executePreChallengePhase` = "PreChallenge Phase", `ProverOrchestrator.executePostChallengePhase` = "PostChallenge Phase", `ProverOrchestrator.computeChallenge` = "Challenge computation", `ProverOrchestrator.computeCommitmentProvers` = "Commitment Provers", `ProverOrchestrator.computePairWiseProvers` = "PairWise Provers", `ProverOrchestrator.computeTildeZ` = "Possession Prover"))
# 
# ggplot(pOrchestrator, aes(x = reorder(factor(pOrchestrator$Vertices)), y = pOrchestrator$mean, group = pOrchestrator$KeyLength), width = 0.5) +
#   geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(pOrchestrator$KeyLength))) +
#   geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = .25, position = position_dodge(0.9)) +
#   facet_wrap(pOrchestrator$Method ~ ., scales = "free_y", labeller = to_string_p, ncol = 5) +
#   labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", fill = "Key Length") +
#   theme(
#     strip.text.x = element_text(colour = "black", size = 10),
#     strip.background = element_blank(), 
#     strip.placement = "outside", 
#     aspect.ratio = 1.4
#   )
# 
# savePlot("pOrchestrator-methods-proving-barplot-50-500.pdf", 15, 4)
# 
# ggplot(pOrchestrator, aes(x = reorder(factor(pOrchestrator$Vertices)), y = pOrchestrator$mean, group = pOrchestrator$KeyLength)) +
#   geom_line(aes(linetype = factor(pOrchestrator$KeyLength), color = factor(pOrchestrator$KeyLength)), size = 1) +
#   geom_point(aes(shape = factor(pOrchestrator$KeyLength), colour = factor(pOrchestrator$KeyLength)), size = 2) +
#   facet_wrap(pOrchestrator$Method ~ ., scales = "free_y", labeller = to_string_p, ncol = 5) +
#   labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", colour = "Key Length", shape = "") +
#   # background_grid(major = "xy", minor = "none") + 
#   guides(shape = FALSE, linetype = FALSE) +
#   theme(
#     strip.text.x = element_text(colour = "black", size = 10),
#     strip.background = element_blank(), 
#     strip.placement = "outside", 
#     aspect.ratio = 1.4)
# 
# pOrchestratorCSV <- pOrchestrator %>%
#   filter(Method != "ProverOrchestrator.executePreChallengePhase" & Method != "ProverOrchestrator.computeChallenge" & Method != "ProverOrchestrator.computePairWiseProvers") 
# 
# pDataFile <- "provingData"
# pCSVFilePath <- paste0(paperDataFolderPath, pDataFile, ".csv", collapse = "")
# writeCSV(pOrchestratorCSV, pCSVFilePath)
# 
# savePlot("facet-provers-keylength-lineplot.pdf", 15, 4)
# 
# 
# # calculate verifying time from VerifierOrchestrator and PossessionVerifier components
# vmethods <- c("VerifierOrchestrator.computeChallenge", "VerifierOrchestrator.computeCommitmentVerifiers", "VerifierOrchestrator.computePairWiseVerifiers", "VerifierOrchestrator.executeVerification", "PossessionVerifier.executeCompoundVerification")
# 
# (vOrchestrator <- dProving_50_500[with(dProving_50_500, grepl(paste(vmethods, collapse = "|"), dProving_50_500$Method)), ])
# 
# to_string <- as_labeller(c(`VerifierOrchestrator.computePairWiseVerifiers` = "PairWise Verifiers", `VerifierOrchestrator.computeChallenge` = "Challenge computation", `VerifierOrchestrator.computeCommitmentVerifiers` = "Commitment Verifiers", `VerifierOrchestrator.executeVerification` = "Verification", `PossessionVerifier.executeCompoundVerification` = "Possession Verifiers"))
# 
# ggplot(vOrchestrator, aes(x = reorder(factor(vOrchestrator$Vertices)), y = vOrchestrator$mean, group = vOrchestrator$KeyLength)) +
#   geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(vOrchestrator$KeyLength)), width = 0.5) +
#   geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = .25, position = position_dodge(0.5)) +
#   facet_wrap(vOrchestrator$Method ~ ., scales = "free_y", labeller = to_string, ncol = 5) +
#   labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", fill = "Key Length") + background_grid(major = "xy", minor = "none") +
#   theme(
#     strip.text.x = element_text(colour = "black", size = 10),
#     strip.background = element_blank(),
#     strip.placement = "outside", aspect.ratio = 1.4
#   )
# 
# savePlot("facet-verifiers-keylength-barplot.pdf", 15, 4)
# 
# ggplot(vOrchestrator, aes(x = reorder(factor(vOrchestrator$Vertices)), y = vOrchestrator$mean, group = vOrchestrator$KeyLength)) +
#   geom_line(aes(linetype = factor(vOrchestrator$KeyLength), color = factor(vOrchestrator$KeyLength)), size = 1) +
#   geom_point(aes(shape = factor(vOrchestrator$KeyLength), colour = factor(vOrchestrator$KeyLength)), size = 2) +
#   facet_wrap(vOrchestrator$Method ~ ., scales = "free_y", labeller = to_string, ncol = 5) +
#   labs(x = "Graph size (# of vertices)", y = "CPU time (ms)", colour = "Key Length", shape = "") +
#   # background_grid(major = "xy", minor = "none") + 
#   guides(shape = FALSE, linetype = FALSE) +
#   theme(
#     strip.text.x = element_text(colour = "black", size = 10),
#     strip.background = element_blank(), 
#     strip.placement = "outside", aspect.ratio = 1.4
#   )
# 
# vOrchestratorCSV <- vOrchestrator %>%
#   filter(Method != "VerifierOrchestrator.executePreChallengePhase" & Method != "VerifierOrchestrator.computeChallenge" & Method != "VerifierOrchestrator.computePairWiseVerifiers")
# 
# vDataFile <- "verifyingData"
# vCSVFilePath <- paste0(paperDataFolderPath, vDataFile, ".csv", collapse = "")
# writeCSV(vOrchestratorCSV, vCSVFilePath)
# 
# savePlot("facet-verifiers-keylength-lineplot.pdf", 15, 4)
# 
# # create multiple plots in a page for verifiers
# poss_verifier <- vOrchestrator %>%
#   filter(Method == "PossessionVerifier.executeCompoundVerification")
# 
# (poss_verifier_lp <- ggplot(poss_verifier, aes(x = factor(poss_verifier$Vertices), y = poss_verifier$mean, group = poss_verifier$KeyLength)) +
#   geom_line(aes(linetype = factor(poss_verifier$KeyLength), color = factor(poss_verifier$KeyLength)), size = 1) +
#   geom_point(aes(shape = factor(poss_verifier$KeyLength), colour = factor(poss_verifier$KeyLength)), size = 2) +
#   guides(shape = FALSE, linetype = FALSE) +
#   labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", colour = "Key length"))
# 
# comm_verifier <- vOrchestrator %>%
#   filter(Method == "VerifierOrchestrator.computeCommitmentVerifiers")
# 
# (comm_verifier_lp <- ggplot(comm_verifier, aes(x = factor(comm_verifier$Vertices), y = comm_verifier$mean, group = comm_verifier$KeyLength)) +
#   geom_line(aes(linetype = factor(comm_verifier$KeyLength), color = factor(comm_verifier$KeyLength)), size = 1) +
#   geom_point(aes(shape = factor(comm_verifier$KeyLength), colour = factor(comm_verifier$KeyLength)), size = 2) +
#   guides(shape = FALSE, linetype = FALSE) +
#   labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", colour = "Key length"))
# 
# 
# pair_wise_verifier <- vOrchestrator %>%
#   filter(Method == "VerifierOrchestrator.computePairWiseVerifiers")
# 
# (pair_wise_verifier_lp <- ggplot(pair_wise_verifier, aes(x = factor(pair_wise_verifier$Vertices), y = pair_wise_verifier$mean, group = pair_wise_verifier$KeyLength, colour = factor(pair_wise_verifier$KeyLength))) +
#   geom_line(aes(linetype = factor(pair_wise_verifier$KeyLength), color = factor(pair_wise_verifier$KeyLength)), size = 1) +
#   geom_point(aes(shape = factor(pair_wise_verifier$KeyLength), colour = factor(pair_wise_verifier$KeyLength)), size = 2) +
#   guides(shape = FALSE, linetype = FALSE) +
#   labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", colour = "Key length"))
# 
# exec_verifier <- vOrchestrator %>%
#   filter(Method == "VerifierOrchestrator.executeVerification")
# 
# (exec_verifier_lp <- ggplot(exec_verifier, aes(x = factor(exec_verifier$Vertices), y = exec_verifier$mean, group = exec_verifier$KeyLength, colour = factor(exec_verifier$KeyLength))) +
#   geom_line(aes(linetype = factor(exec_verifier$KeyLength), color = factor(exec_verifier$KeyLength)), size = 1) +
#   geom_point(aes(shape = factor(exec_verifier$KeyLength), colour = factor(exec_verifier$KeyLength)), size = 2) +
#   guides(shape = FALSE, linetype = FALSE) +
#   labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", colour = "Key length"))
# 
# # library(patchwork) # poss_verifier_lp + comm_verifier_lp + pair_wise_verifier_lp + exec_verifier_lp
# 
# library(cowplot)
# plot_grid(poss_verifier_lp + background_grid(major = "xy", minor = "none"),
#   comm_verifier_lp + background_grid(major = "xy", minor = "none"),
#   pair_wise_verifier_lp + background_grid(major = "xy", minor = "none"),
#   exec_verifier_lp + background_grid(major = "xy", minor = "none"),
#   labels = c("Possession Verifier", "Commitments Verifier", "Pair Wise Verifier", "Verification"),
#   rel_heights = c(1, 1),
#   rel_widths = c(1, 1),
#   align = "h",
#   axis = "tb", ncol = 2
# )
# 
# savePlot("vOrchestrator-multiplot-verifiers.pdf")
