# issuing computation results analysis
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

#list.dirs("../data",pattern= "^issuing-400-512", recursive = TRUE )

folderPattern512 = "^issuing-400-512"
folderPattern1024 = "^issuing-400-1024"
folderPattern2048 = "^issuing-400-2048"
folderPattern3072 = "^issuing-400-3072"

folders <- dir("../data/issuing-profile-50-csv", pattern = folderPattern512 , full.names = TRUE, ignore.case = TRUE)

(dirs <- grep("issuing-400-512*",list.dirs("../data/issuing-profile-50-csv",recursive=FALSE),value=TRUE))

(lfiles <- list.files(dirs, pattern = "Method-list--CPU\\.csv", recursive = TRUE, full.names = TRUE, include.dirs = TRUE))

(dirs1024 <- grep("issuing-400-1024*",list.dirs("../data/issuing-profile-50-csv",recursive=FALSE),value=TRUE))

(lfiles1024 <- list.files(dirs1024, pattern = "Method-list--CPU\\.csv", recursive = TRUE, full.names = TRUE, include.dirs = TRUE))

(data <- lapply( lfiles, FUN = readCSVs))

(data512 <- getCSVData("issuing-400-512*","../data/issuing-profile-50-csv", "Method-list--CPU\\.csv"))
# create a dataframe from the experiments
issuing512 <- bind_rows(data512, .id="expID")
issuing512['KeyLength'] = 512

(data1024 <- getCSVData("issuing-400-1024*","../data/issuing-profile-50-csv", "Method-list--CPU\\.csv"))
issuing1024 <- bind_rows(data1024, .id="expID")
issuing1024['KeyLength'] = 1024

(data2048 <- getCSVData("issuing-400-2048*","../data/issuing-profile-50-csv", "Method-list--CPU\\.csv"))
issuing2048 <- bind_rows(data2048, .id="expID")
issuing2048['KeyLength'] = 2048

(data3072 <- getCSVData("issuing-400-3072*","../data/issuing-profile-50-csv", "Method-list--CPU\\.csv"))
issuing3072 <- bind_rows(data3072, .id="expID")
issuing3072['KeyLength'] = 3072

datafull <- rbind(issuing512, issuing1024)
datafull <- rbind(datafull, issuing2048)
datafull <- rbind(datafull, issuing3072)



# (filtered <- issuing512[with(issuing512, grepl("eu.prismacloud.primitives.zkpgs.*",issuing512$Method) | grepl("java.math.BigInteger.*",issuing512$Method)), ])

(filtered <- datafull[with(datafull, grepl("eu.prismacloud.primitives.zkpgs.*",datafull$Method)), ])


# rename headings 
col_headings <- c('ExpID','Method','Time_ms', 'OwnTime_ms', 'KeyLength')
names(filtered) <- col_headings
str(filtered)

# truncate method names
(filtered$Method <- gsub(pattern = "eu.prismacloud.primitives.zkpgs.", replacement = "", filtered$Method)) 
(filtered$Method <- gsub(pattern = " (/.)*[a-zA-Z]*.java", replacement = "", filtered$Method)) 
(filtered$Method <- gsub(pattern = "\\(.*?\\)", replacement = "", filtered$Method)) 

scatter.smooth(x=factor(filtered$Method), y=filtered$Time_ms, main="Method ~ Time_ms")  # scatterplot

summary(filtered$Time_ms)
max(filtered$Time_ms)
table(filtered$Time_ms)
hist(filtered$Time_ms)

(kmean <- mean(filtered$Time_ms))

ggplot(filtered, aes(x = filtered$Time_ms)) + 
  geom_histogram(binwidth = 2)

ggplot(filtered, aes(x = filtered$Time_ms)) + 
  geom_density(adjust = 0.25)

str(filtered$Method)
str(filtered$Time_ms)
length(filtered$Time_ms)
length(filtered$Method)
head(filtered)

# filter dataframe to include only methods with cpu time > 50 ms
filtered <- filter(filtered, filtered$Time_ms > 0)

filteredSmall <- filter(filtered, filtered$Time_ms < 50)

(uniqueM <- unique(filtered$Method))

dIssuing <- filterIssuing(filtered)

(jitterOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "") )

(facetOrderedBoxplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(facetOrderedMeanBarplot(dIssuing, dIssuing$Method, dIssuing$Time_ms, dIssuing$KeyLength, "Methods", "CPU time (ms)", "Key length"))

(cpuKeySummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength")))

ggplot(cpuKeySummary, aes(x=factor(cpuKeySummary$KeyLength), y=cpuKeySummary$mean,  fill = factor(cpuKeySummary$KeyLength))) +
  geom_bar(stat="identity", position=position_dodge())+
  theme_bw() +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.15,
                position=position_dodge(0.9)) +
  labs( x = "Key length",  y = "Mean CPU time (ms)", fill = "Key length") 

(dsummary <- data_summary(dIssuing, varname = "Time_ms", groupnames = c("KeyLength", "Method")))

(createMeanSDBarplots(dsummary, dsummary$Method, dsummary$mean, dsummary$KeyLength, "Methods", "CPU time (ms)", "Key length"))

# plot means
plotmeans(filtered$Time_ms ~ filtered$Method, digits=3, ccol="red", xlab = "Methods", ylab="CPU time for issuing methods (msec)",las=2, cex.axis=0.4, mean.labels=F, mar=c(10.1,4.1,4.1,2.1),n.label = FALSE, mgp=c(3,1,0) , main="Plot of issuing methods")
