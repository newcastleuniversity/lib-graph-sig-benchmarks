data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE), 
      N = length(x[[col]]),
      se = sd(x[[col]], na.rm=TRUE)/sqrt(length(x[[col]]))
    ) 
    
  }
  data_sum <- ddply(data, groupnames, .fun=summary_func, varname)
  #data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}

## constructs a file path 
getFilePath <- function(folderPath, fileName, extension){
  filePath <- paste0(folderPath, fileName, extension, collapse = "" )
  return(filePath)
}

## creates ordered boxplots with jitter
jitterOrderedBoxplot <- function(dataFrame, dx , dy, xlabel, ylabel, flabel){
  p <- ggplot(dataFrame, aes(x = reorder(factor(dx), dy), y = dy)) +
    stat_boxplot(geom = 'errorbar', color = "black") +
    geom_boxplot(fill = factor(dataFrame$KeyLength), color = "black", notch = FALSE) +
    geom_point(position = "jitter", color = "blue", alpha = .5) +
    geom_rug( color = "black") + 
    labs( x = xlabel,  y = ylabel, fill = flabel) + 
    coord_flip()
  return(p)
}

## creates an ordered barplot that calculates the mean 
orderedMeanBarplot <- function(dataframe, dx, dy, xlabel, ylabel) {
  p <- ggplot(dataframe, aes(x = reorder(factor(dx), dy), y = dy)) +
    geom_bar(stat = "summary", fun.y = "mean", position = "dodge", fill = 'blue')  +
    labs( x=xlabel,  y = ylabel) +  coord_flip() +  theme(panel.grid.major = element_blank()) 
  return(p)
}

## read csv files
readCSVs <- function(a_csv) {
  print(a_csv)
  the_data <- read.csv(a_csv, header = TRUE, sep = ",", stringsAsFactors=FALSE)
}

## create a list of dataframes from csv files
getCSVData <- function(dPattern, path, fPattern ){
  dirs <- grep(dPattern,list.dirs(path,recursive=FALSE),value=TRUE)
  lfiles <- list.files(dirs, pattern = fPattern, recursive = TRUE, full.names = TRUE, include.dirs = TRUE)
  data <- lapply(lfiles, FUN = readCSVs)
  return(data)
}

