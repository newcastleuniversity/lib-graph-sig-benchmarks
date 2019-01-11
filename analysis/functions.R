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