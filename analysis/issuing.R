# issuing computation results analysis
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
  path <- paste("issuing-csv-new-",numberOfVertices[i],sep = "")
  # print(path)
  csvFolder <- paste("issuing-signer-infra-",numberOfVertices[i], sep = "")
  # print(csvFolder)
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Call-tree--by-thread\\.csv", numberOfVertices[i])
  iss <- rbind(iss, iss_temp)
  # print(numberOfVertices[i])
}

# rename headings
issuing <- renameHeadings(iss, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing)

filtered <- filterMethods(issuing)
(filtered_signer <- filtered[with(filtered, grepl("SignerOrchestrator.java:536 <...> QRElement.modPow", filtered$Method)), ])
str(filtered_signer)

# summary(filtered_signer$Time_ms)
# hist(filtered_signer$Time_ms)

(signer_issuing_time <- data_summary(filtered_signer, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

ggplot(signer_issuing_time, aes(x = reorder(factor(signer_issuing_time$Vertices)), y = signer_issuing_time$mean, group = signer_issuing_time$KeyLength)) +
  geom_errorbar(aes(colour = factor(signer_issuing_time$KeyLength), ymin = mean - se, ymax = mean + se), width= .1) +
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

# # filter dataframe to include only methods with cpu time > 50 ms
# # filtered <- filter(filtered, filtered$Time_ms > 0)
# # 
# # filteredSmall <- filter(filtered, filtered$Time_ms < 50)
# # 
# # (uniqueM <- unique(filtered$Method))
# 
signer_issuing_time <- bind_rows(signer_issuing_time, .id = "Type")
signer_issuing_time["Type"] <- "Signer issuing time"

(recipient_filtered <- filtered[with(filtered, grepl("GSSignatureValidator.java:79 <...> QRElement.modPow", filtered$Method)), ])

(recipient_issuing_time <- data_summary(recipient_filtered, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))
recipient_issuing_time <- bind_rows(recipient_issuing_time, .id = "Type")
recipient_issuing_time["Type"] <- "Recipient issuing time"

(issuing_time <- rbind(signer_issuing_time, recipient_issuing_time))
# str(issuing_time)

kDataFile <- "issuing_time"
kCSVFilePath <- paste0(paperDataFolderPath, kDataFile, ".csv", collapse = "")
writeCSV(issuing_time,kCSVFilePath)