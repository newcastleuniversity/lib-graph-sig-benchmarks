# issuing computation results analysis
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")

# # read data
# dataFile <- "results-commitment-raw-2019-01-13_01-20-05"
# dataPath <- getFilePath("../data/", dataFile, ".csv")
# commitmentData <- read.csv(dataPath, sep=",")

(dirs <- grep("issuing-400-512*",list.dirs("../data/issuing-profile-50-csv",recursive=FALSE),value=TRUE))
(lfiles <- list.files(dirs, pattern = "Method-list--CPU\\.csv", recursive = TRUE, full.names = TRUE, include.dirs = TRUE))

list.dirs("../data",pattern= "issuing-400-512", recursive = TRUE )

folderPattern512 = "^issuing-400-512"
folderPattern1024 = "^issuing-400-1024"
folderPattern2048 = "^issuing-400-2048"
folderPattern3072 = "^issuing-400-3072"

folders <- dir("../data/issuing-profile-50-csv", pattern = folderPattern512 , full.names = TRUE, ignore.case = TRUE)
lapply(folders, 1, function(folders){
  folders
})

readCSVs <- function(a_csv) {
  print(a_csv)
   the_data <- read.csv(a_csv, header = TRUE, sep = ",", stringsAsFactors=FALSE)
}

str(d)
(data <- lapply( lfiles, FUN = readCSVs))

(dfd <- data[1])

df <- ldply (dfd, data.frame)
str(df$Method)  
(df$Method <- as.character(df$Method))

(filtered <- df[with(df, grepl("eu.prismacloud.primitives.zkpgs.*",df$Method) | grepl("java.math.BigInteger.*",df$Method)), ])

# rename headings 
col_headings <- c('Method','Time_ms ', 'OwnTime_ms')
names(filtered) <- col_headings
str(filtered)


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
str(filtered$`Time_ms `)
length(filtered$`Time_ms `)
length(filtered$Method)

(filtered$Method <- gsub(pattern = "eu.prismacloud.primitives.zkpgs.", replacement = "", filtered$Method)) 

(filtered$Method <- gsub(pattern = " (/.)*[a-zA-Z]*.java", replacement = "", filtered$Method)) 
(filtered$Method <- gsub(pattern = "\\(.*?\\)", replacement = "", filtered$Method)) 
length(filtered$Method)
head(filtered)

ggplot(filtered, aes(x=filtered$Method, y=filtered$Time_ms)) +
  stat_boxplot(geom ='errorbar', color="black") +
  geom_boxplot(fill="cornflowerblue", color="black", notch=FALSE) +
  geom_point(position="jitter", color="blue", alpha=.5) +
  geom_rug( color="black") + 
  labs( x="Method",  y = "cpu  time (msec)", fill="Graph size") + 
  coord_flip() #+ theme(axis.text.y = element_text( hjust = 0.95, vjust = 0.1)) # + scale_x_discrete( labels= abbreviate, expand=c(0, 0)) 

ggplot(filtered, aes(x=reorder(filtered$Method, filtered$Time_ms), 
                     y=filtered$Time_ms)) +
       #stringr::str_wrap(filtered$Method, 15), filtered$Timems) + xlab(NULL) + 
  # theme(axis.text.x = element_text( size = 9,
  #       color = "black", face = "plain", vjust = 1, hjust = 1),
  #       plot.margin = margin(10, 10, 10, 100))
  # ylab("Method") + scale_x_discrete(labels = abbreviate) +  
  #stat_boxplot(geom ='errorbar', color="black") +
  geom_bar(stat = "identity", position = "dodge", fill = 'blue')  +
  labs( x="Method",  y = "CPU time (msec)") +  coord_flip()

# calculate means
#(means<- round(tapply(filtered$Score, commitmentData$KeyLength, mean), digits=2)) 

# plot means
plotmeans(filtered$Time_ms ~ filtered$Method, digits=3, ccol="red", xlab = "Methods", ylab="CPU time for issuing methods (msec)",las=2, cex.axis=0.4, mean.labels=F, mar=c(10.1,4.1,4.1,2.1),n.label = FALSE, mgp=c(3,1,0) , main="Plot of issuing methods")

str(filtered)
(filtered$`Time_ms `)
mm <- as.character(filtered$Method)
str(mm)
tt <- filtered$Time_ms
ggbarplot(filtered, x=mm, y=tt,
          fill = "blue"               # change fill color by cyl
          # color = "white",            # Set bar border colors to white
          # palette = "jco",            # jco journal color palett. see ?ggpar
          # sort.val = "asc",           # Sort the value in dscending order
          # sort.by.groups = FALSE,      # Sort inside each group
          # x.text.angle = 90           # Rotate vertically x axis texts
          )

ggbarplot(filtered, x= filtered$Method, y=filtered$Time_ms, orientation = "horiz")

(stable.p <- ggtexttable(filtered, rows = NULL, theme = ttheme("mBlueWhite")))

