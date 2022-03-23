# generating vertex primes for the encoding setup results analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# create dataframes for 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 and 10000 encoded vertices
numberOfVertices <- c( "1000", "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000")

lengthVertices <- length(numberOfVertices)
iss <- data.frame()

# iterate over all performance experiments for different number of vertices and create a dataframe for all observations from the csv files 
for (i in seq_along(numberOfVertices)) {
  print(i)
  path <- paste("measure-setup-encoding-2022-03-22")
  print(path)
  csvFolder <- paste("measureSetupEncoding-signer-infra-",numberOfVertices[i], sep = "")
  print(csvFolder)
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Method-list--CPU\\.csv", numberOfVertices[i])
  iss <- rbind(iss, iss_temp)
  print(numberOfVertices[i])
}

# rename headings
genVertexPrimes <- renameHeadings(iss, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(genVertexPrimes)

(filtered_genVPrimes <- genVertexPrimes[with(genVertexPrimes, grepl("eu.prismacloud.primitives.grs.bench.SetupEncodingBenchmark.measureSetupEncoding(Blackhole)*", genVertexPrimes$Method)), ])
str(filtered_genVPrimes)

(genVertexPrimesTime <- data_summary(filtered_genVPrimes, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

ggplot(genVertexPrimesTime, aes(x = reorder(factor(Vertices)), y = mean, group = 1)) +
  geom_line(linetype = "dashed" ) +
  geom_point() +
  labs(x = "Graph size (number of vertices)", y = "CPU time (ms)") + 
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside"
  )

# store csv file in paper's data folder for producing paper figure
genVPrimesDataFile <- "generateVPrimes"
kCSVFilePath <- paste0(paperDataFolderPath, genVPrimesDataFile, ".csv", collapse = "")
writeCSV(genVertexPrimesTime,kCSVFilePath)
