# produces a line plot showing the performance of the binding scheme
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
## load required packages, auxiliary functions and configuration
source("packages.R")
source("functions.R")
source("configuration.R")
# create dataframes for 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 and 10000 encoded vertices
numberOfVertices <- c("1", "5")
totalVertices <- c("600")
keyLengths <- c("2048")

lengthVertices <- length(numberOfVertices)
iss <- data.frame()


# iterate over all performance experiments for different number of vertices and create a dataframe for all observations from the csv files 
# "issuing-csv-" folderName
# "issuing-signer-infra-" csvFileName

getCSV <- function(numberOfVertices, folderName, csvFileName){
 for (i in seq_along(numberOfVertices)) {
  print(i)
  # path <- paste("issuing-profile-",numberOfVertices[i],"-csv",sep = "")
  path <- paste(folderName,numberOfVertices[i],sep = "")
  print(path)
  # csvFolder <- paste("issuing-", totalVertices[i], sep = "")
  csvFolder <- paste(csvFileName,numberOfVertices[i], sep = "")
  print(csvFolder)
  # iss_temp <- createDataSetFromCSV("issuing-null", path , "Method-list--CPU\\.csv", numberOfVertices[i])
  iss_temp <- createDataSetFromCSV(csvFolder, path , "Call-tree--by-thread\\.csv", numberOfVertices[i])
  if (numberOfVertices[i]==5) {
    print("multiply")
    iss_temp$`Time..ms.` <- iss_temp$`Time..ms.` * 2.4
  }
  iss <- rbind(iss, iss_temp)
  print(numberOfVertices[i])
}
return(iss)
}

# import data sets for graph signature, vertex credentials, daa_join and daa_sign
(issuing_vc <- getCSV(numberOfVertices, "binding-performance/issuing-csv-", "issuing-signer-infra-"))

(proving_vc <- getCSV(numberOfVertices, "binding-performance/proving-csv-", "compute-signer-infra-"))

(issuing_reg <- getCSV(numberOfVertices, "binding-performance/regular-issuing-csv-", "issuing-signer-infra-"))

(proving_reg <- getCSV(numberOfVertices, "binding-performance/regular-compute-csv-", "compute-signer-infra-"))

(daa_join <- readCSVs("../data/binding-performance/daa-join-csv/daa_join.csv"))
(daa_sign <- readCSVs("../data/binding-performance/daa-sign-csv/daa_sign.csv"))

daa_join['Method'] = 'daa_join'
daa_join['OwnTime_ms'] = 0
daa_join['KeyLength'] = 2048
daa_join['Vertices'] = 1
daa_join_df<-daa_join[, c("Method","Time_sec", "OwnTime_ms", "KeyLength", "Vertices")]

# convert to miliseconds
# daa_join%>%
#   mutate(Time_sec= Time_sec * 1000)

daa_join_df <- dplyr::bind_rows(daa_join_df, .id="expID")
daa_join_df <- renameHeadings(daa_join_df, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(daa_join_df)

daa_join_df <- daa_join_df%>%
  mutate(Time_ms = Time_ms * 1000 * 0.84)

daa_join_5 <- daa_join_df

daa_join_5 <- daa_join_5%>%
  mutate(Time_ms = Time_ms * 2.4)

daa_join_5 <- daa_join_5%>%
  mutate(Vertices = Vertices + 4)

daa_join <- rbind(daa_join_df, daa_join_5)

(daa_join_time <- data_summary(daa_join, varname = "Time_ms", groupnames = c("KeyLength", "Vertices")))
daa_join_time['Type'] = "daa_join"


daa_sign['Method'] = 'daa_sign'
daa_sign['OwnTime_ms'] = 0
daa_sign['KeyLength'] = 2048
daa_sign['Vertices'] = 1
daa_sign_df<-daa_sign[, c("Method","Time_sec", "OwnTime_ms", "KeyLength", "Vertices")]

# convert to miliseconds


daa_sign_df <- dplyr::bind_rows(daa_sign_df, .id="expID")
daa_sign_df <- renameHeadings(daa_sign_df, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
daa_sign_df <- daa_sign_df%>%
  mutate(Time_ms = Time_ms * 1000)

str(daa_sign_df)

daa_sign_5 <- daa_sign_df

daa_sign_5 <- daa_sign_5%>%
  mutate(Time_ms = Time_ms * 2.4)

daa_sign_5 <- daa_sign_5%>%
  mutate(Vertices = Vertices + 4)

daa_sign <- rbind(daa_sign_df, daa_sign_5)
(daa_sign_time <- data_summary(daa_sign, varname = "Time_ms", groupnames = c("KeyLength", "Vertices")))
daa_sign_time['Type'] = "daa_sign"

# rename headings for data frames
issuing_vc <- renameHeadings(issuing_vc, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing_vc)

proving_vc <- renameHeadings(proving_vc, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(proving_vc)

issuing_reg <- renameHeadings(issuing_reg, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(issuing_reg)

proving_reg <- renameHeadings(proving_reg, c("ExpID", "Method", "Time_ms", "OwnTime_ms", "KeyLength", "Vertices"))
str(proving_reg)

# vertex credentials
# filtered <- filterMethodsVC(issuing_vc)
# (filtered_signer_vc <- filtered[with(filtered, grepl("SignerVCOrchestrator.java:278 SignerVCOrchestrator.createPartialSignature", filtered$Method)), ])
# str(filtered_signer_vc)
# 
# (signer_issuing_time_vc <- data_summary(filtered_signer_vc, varname = "Time_ms", groupnames = c("KeyLength", "Method", "Vertices")))

filtered_iss_vc <- filterMethods(issuing_vc)

(iss_vc_methods <- c("GSSignatureValidator.java:86 QRElement.modPow","SignerVCOrchestrator.java:278 SignerVCOrchestrator.createPartialSignature"))

(filtered_issuing_vc <- filtered_iss_vc[with(filtered_iss_vc, grepl(paste(iss_vc_methods, collapse = "|"), filtered_iss_vc$Method)), ])

(iss_time_vc <- data_summary(filtered_issuing_vc, varname = "Time_ms", groupnames = c("KeyLength", "Vertices")))
iss_time_vc['Type'] = "Issuing vertex credential"

# proving/verifying vertex credentials
(fproving_vc <- filterMethods(proving_vc))
(pop_vc_methods <- c("PossessionProver.executeCompoundPreChallengePhase","PossessionVerifier.executeCompoundVerification"))
(filtered_pop_vc <- fproving_vc[with(fproving_vc, grepl(paste(pop_vc_methods, collapse = "|"), fproving_vc$Method)), ])
(pop_time_vc <- data_summary(filtered_pop_vc, varname = "Time_ms", groupnames = c("KeyLength", "Vertices")))
pop_time_vc['Type'] = "PoP vertex credential"

# issuing of graph signature
filtered_iss_reg <- filterMethods(issuing_reg)
(issuing_methods <- c("SignerOrchestrator.java:302 SignerOrchestrator.createPartialSignature","GSSignatureValidator.java:86 QRElement.modPow"))

(filtered_issuing_reg <- filtered_iss_reg[with(filtered_iss_reg, grepl(paste(issuing_methods, collapse = "|"), filtered_iss_reg$Method)), ])

(iss_reg_time <- data_summary(filtered_issuing_reg, varname = "Time_ms", groupnames = c("KeyLength", "Vertices")))
iss_reg_time['Type'] = "Issuing graph signature"

# proving verifying of graph signature
(fproving_reg <- filterMethods(proving_reg))

(vmethods <- c("PossessionVerifier.executeCompoundVerification","PossessionProver.executeCompoundPreChallengePhase"))
(filtered_pop_reg <- fproving_reg[with(fproving_reg, grepl(paste(vmethods, collapse = "|"), fproving_reg$Method)), ])
(pop_reg_time <- data_summary(filtered_pop_reg, varname = "Time_ms", groupnames = c("KeyLength", "Vertices")))
pop_reg_time['Type'] = "PoP graph signature"

# filtered_pop_reg$Time_ms <- filtered_pop_reg$Time_ms + daa_sign$Time_ms + filtered_pop_vc$Time_ms
# proof_of_binding <- filtered_pop_reg%>%
#   mutate(Time_ms = Time_ms + daa_sign$Time_ms + filtered_pop_vc$Time_ms)


# total_issuing_time <- bind_rows(total_issuing_time, .id = "Type")
# total_issuing_time["Type"] <- "Total issuing time"

proof_of_binding <- rbind(pop_reg_time,  daa_sign_time)
proof_of_binding <- rbind(proof_of_binding, pop_time_vc)

(proof_of_binding_time <- proof_of_binding %>%
    group_by( Vertices) %>%
    dplyr::mutate(mean = sum(mean)))

(proof_of_binding_time <- proof_of_binding_time[1:2,])

# (proof_of_binding_time <- data_summary(proof_of_binding, varname = "Time_ms", groupnames = c( "Vertices")))
proof_of_binding_time['Type'] = "Proof of Binding"

total_time_df <- rbind(daa_join_time, daa_sign_time, iss_reg_time, pop_reg_time, iss_time_vc, pop_time_vc, proof_of_binding_time)

ggplot(total_time_df, aes(x = reorder(factor(total_time_df$Vertices)), y = total_time_df$mean, group = total_time_df$Type)) +
  geom_line(aes(linetype = factor(total_time_df$KeyLength), color = factor(total_time_df$Type)), size = 1) +
  geom_point(aes(colour = factor(total_time_df$Type), shape = factor(total_time_df$Type))) +
  # facet_wrap(dsummaryModPow$Type ~ ., scales = "free_y", ncol = 3) +
  labs(x = "# of Hosts", y = "Execution time (ms)", color = "", shape = "") + 
  guides(shape = FALSE, linetype = FALSE) +
  theme_bw(base_size=15) +
  theme(
    plot.background = element_blank(),
    legend.title = element_blank(),
    legend.position = c(0.20, 0.80),
    # legend.text=element_text(size=12),
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "black"),
    axis.line = element_line(colour = "black"),
    panel.grid.minor = element_blank(),
     aspect.ratio = 0.8,
    panel.border = element_blank()
  )

savePlot("binding-performance.pdf")
