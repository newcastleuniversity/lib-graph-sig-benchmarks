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
  path <- paste("extended-key-gen-csv-",numberOfVertices[i],sep = "")
  print(path)
  csvFolder <- paste("measureKeyGen-signer-infra-",numberOfVertices[i], sep = "")
  print(csvFolder)
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Method-list--CPU\\.csv", numberOfVertices[i])
  iss <- rbind(iss, iss_temp)
  print(numberOfVertices[i])
}

# rename headings
extKeyGen <- renameHeadings(iss, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(extKeyGen)

filtered <- filterMethods(extKeyGen)

(filtered_extendedKeygen <- filtered[with(filtered, grepl("keys.ExtendedKeyPair.generateBases", filtered$Method)), ])
str(filtered_extendedKeygen)

scatter.smooth(x = factor(filtered_extendedKeygen$KeyLength), y = filtered_extendedKeygen$Time_ms, main = "KeyLength ~ Time_ms") # scatterplot

# plot the mean time for generate bases for the extended keypair
(generateBasesTime <- data_summary(filtered_extendedKeygen, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

# ekBasesDataFile <- "ekpBaseGen"
# kCSVFilePath <- paste0(paperDataFolderPath, ekBasesDataFile, ".csv", collapse = "")
# writeCSV(generateBasesTime,kCSVFilePath)

ggplot(generateBasesTime, aes(x = reorder(factor(generateBasesTime$Vertices)), y = generateBasesTime$mean, group = generateBasesTime$KeyLength)) +
  geom_line(aes(linetype = factor(generateBasesTime$KeyLength), color = factor(generateBasesTime$KeyLength)), size = 1) +
  geom_point(aes(colour = factor(generateBasesTime$KeyLength), shape = factor(generateBasesTime$KeyLength))) +
  labs(x = "Graph size (number of vertices)", y = "CPU time (ms)", color = "Key length", shape = "") + 
  guides(shape = FALSE, linetype = FALSE) +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )
