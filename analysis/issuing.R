# issuing computation results analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# create dataframes for 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 and 10000 encoded vertices
numberOfVertices <- c( "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000")
totalVertices <- c("3000", "12000", "17000", "21000", "26000") #, "36000", "41000", "46000", "51000", "57000" )
keyLengths <- c("512", "1024", "2048", "3072")

lengthVertices <- length(numberOfVertices)
iss <- data.frame()

# iterate over all performance experiments for different number of vertices and create a dataframe for all observations from the csv files 
for (i in seq_along(numberOfVertices)) {
  print(i)
  path <- paste("issuing-csv-",numberOfVertices[i],sep = "")
  print(path)
  csvFolder <- paste("issuing-signer-infra-", numberOfVertices[i], sep = "")
  print(csvFolder)
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Call-tree--by-thread\\.csv", numberOfVertices[i])
  iss <- rbind(iss, iss_temp)
  print(numberOfVertices[i])
}

# rename headings
issuing <- renameHeadings(iss, c("ExpID", "ExpID.1", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing)

filtered <- filterMethods(issuing)
(filtered_signer <- filtered[with(filtered, grepl("SignerOrchestrator.java:536 <...> QRElement.modPow", filtered$Method)), ])
(filtered_recipient <- filtered[with(filtered, grepl("GSSignatureValidator.java:79 <...> QRElement.modPow", filtered$Method)), ])

str(filtered_signer)
scatter.smooth(x = factor(filtered_signer$KeyLength), y = filtered_signer$Time_ms, main = "KeyLength ~ Time_ms") # scatterplot
scatter.smooth(x = factor(filtered_recipient$KeyLength), y = filtered_recipient$Time_ms, main = "KeyLength ~ Time_ms") # scatterplot

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

signer_issuing_time <- bind_rows(signer_issuing_time, .id = "Type")
signer_issuing_time["Type"] <- "Signer issuing time"

(recipient_issuing_time <- data_summary(filtered_recipient, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

recipient_issuing_time <- bind_rows(recipient_issuing_time, .id = "Type")
recipient_issuing_time["Type"] <- "Recipient issuing time"

(issuing_time <- rbind( recipient_issuing_time, signer_issuing_time))
str(issuing_time)

# kDataFile <- "issuing_time"
# kCSVFilePath <- paste0(paperDataFolderPath, kDataFile, ".csv", collapse = "")
# writeCSV(issuing_time,kCSVFilePath)

to_string_is <- as_labeller(c(`Signer issuing time` = "Signer Issuing time", `Recipient issuing time` = "Recipient Issuing time"))

# issuing_time$Type <- factor(issuing_time$Type, levels = c("Signer Issuing time", "Recipient Issuing time"))
ggplot(issuing_time, aes(x = reorder(factor(issuing_time$Vertices)), y = issuing_time$mean, group = issuing_time$KeyLength)) +
  geom_line(aes(linetype = factor(issuing_time$KeyLength), color = factor(issuing_time$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(issuing_time$KeyLength), shape = factor(issuing_time$KeyLength))) +
  facet_wrap(issuing_time$Type ~ ., scales = "free_y", labeller = to_string_is, ncol = 1) +
  labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", color = "Key length", shape = "") + 
   # coord_trans( y="log2") +
   # coord_trans( y="log10") +
  # scale_y_continuous(labels = scientific) +
  # annotation_logticks() +
  # scale_y_continuous(trans = log2_trans(),
  # breaks = trans_breaks("log2", function(x) 2^x),
  # labels = trans_format("log2", math_format(2^.x))) +
  #
  # scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #                labels = trans_format("log10", math_format(10^.x))) +
  guides(shape = FALSE, linetype = FALSE) +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )
