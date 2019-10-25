## Measuring execution time proofs and issuing in attributes-based credential
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# read data
dataFile <- "sdhabc128"
dataPath <- paste0("../data/", dataFile, ".csv", collapse = "" )
attrData <- read.csv(dataPath, sep=",")

# rename headings 
col_headings <- c('Credential Size','Components','Time (ms)')
names(attrData) <- col_headings
str(attrData)

# create line plot
ggplot(attrData, aes(x = reorder(factor(attrData$`Credential Size`)), y = attrData$`Time (ms)`, group = attrData$Components, color = attrData$Components, linetype = attrData$Components, shape = attrData$Components)) +
  # geom_line(aes(linetype = factor(attrData$Components), color = factor(attrData$Components))) +
   geom_line() +
   geom_point() +
  # geom_point(aes(colour = factor(attrData$Components), shape = factor(attrData$Components))) +
  labs(x = "Number of attributes", y = "Mean Execution Time (ms)", color = "", shape = "") +
guides(colour = guide_legend(), shape = guide_legend(), linetype = FALSE) +
  scale_colour_discrete("") +
  scale_shape_manual(values = c(4,8,15,16,17,18,21,22,3,42,4,8,15,16)) +
  scale_linetype_manual(values=c("solid", "dashed","dotted", "dotdash", "longdash", "twodash", "solid", "dashed","dotted", "dotdash", "longdash", "twodash","solid", "dashed")) +
  # guides( size = guide_legend(),
         # shape = guide_legend(), linetype= FALSE) +
theme(
  aspect.ratio = 1/1,
  strip.text.x = element_text(colour = "black", size = 10),
  strip.background = element_blank(),
  strip.placement = "outside"
)

savePlot("attributes-time-line-plot.pdf")
