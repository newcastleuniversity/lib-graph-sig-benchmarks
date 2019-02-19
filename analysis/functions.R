data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE), 
      N = length(x[[col]]), 
      se = sd(x[[col]], na.rm=TRUE)/sqrt(length(x[[col]]))
    ) 
      
  }
  data_sum <- ddply(data, groupnames, .fun=summary_func, .inform= TRUE, varname)
  #data_sum <- rename(data_sum, c("mean" = varname))

  return(data_sum)
}

## constructs a file path 
getFilePath <- function(folderPath, fileName, extension){
  filePath <- paste0(folderPath, fileName, extension, collapse = "" )
  return(filePath)
}

## creates ordered boxplots with jitter
jitterOrderedBoxplot <- function(df, dx , dy, dfill, xlabel, ylabel, flabel){
  p <- ggplot(df, aes(x = reorder(factor(dx), dy), y = dy)) +
    stat_boxplot(geom = 'errorbar', color = "black") +
    geom_boxplot(aes(fill = factor(dfill)), color = "black", notch = FALSE) +
    geom_point(position = "jitter", color = "blue", alpha = .5) +
    geom_rug( color = "black") + 
    labs(x = xlabel,  y = ylabel, fill = flabel) + 
    coord_flip() + theme_bw()
  return(p)
}

## creates an ordered boxplot with facets 
facetOrderedBoxplot <- function(df, dx, dy, dg,  xlabel, ylabel, flabel) {
  p <- ggplot(df, aes(x = reorder(factor(dx), dy), y = dy)) +
    geom_boxplot(aes(fill = factor(dg)), notch = FALSE, width = 0.8) +
    facet_grid(dg, margins = FALSE,  scales = "free", space = "free") +
    labs(x = xlabel,  y = ylabel, fill = flabel) +
    coord_flip() + theme_bw() 
  return(p)
}

## creates an ordered barplot that calculates the mean 
facetOrderedMeanBarplot <- function(dataframe, dx, dy, dg, xlabel, ylabel, flabel) {
  p <- ggplot(dataframe, aes(x = reorder(factor(dx), dy), y = dy)) +
    geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(dg)))  +
    facet_grid(dg, margins = FALSE,  scales = "free", space = "free") +
    labs( x = xlabel,  y = ylabel, fill = flabel) +  
    coord_flip() +  theme_bw()
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

filterIssuing <- function(df) {
  d <- filter(df, df$Method == "SignerOrchestrator.round2" | df$Method == "SignerOrchestrator.encodeSignerGraph" |  df$Method == "SignerOrchestrator.createPartialSignature" | df$Method == "RecipientOrchestrator.round3" | df$Method == "RecipientOrchestrator.serializeFinalSignature" | df$Method == "SignerOrchestrator$SignatureData.computeRandomPrimeE" | df$Method == "GSUtils.isPrime" |  df$Method == "QRElement.modPow" | df$Method == "graph.GraphRepresentation.encodeGraph" | df$Method == "RecipientOrchestrator.round1" | df$Method == "RecipientOrchestrator.computeChallenge" | df$Method == "SignerOrchestrator.prepareProvingSigningQ" | df$Method == "SignerOrchestrator.verifyRecipientCommitment" |  df$Method == "SigningQVerifierOrchestrator.computeChallenge" | df$Method == "SigningQVerifierOrchestrator.executeVerification" | df$Method == "SigningQVerifierOrchestrator.populateChallengeList" | df$Method == "GSSignature.verify" | df$Method == "GSSignatureValidator.computeQ" | df$Method == "GSSignatureValidator.verify"| df$Method == "GSUtils.computeHash" |  df$Method == "GSCommitment.createCommitment" | df$Method == "RecipientOrchestrator.createProofSignature" |  df$Method == "SignerOrchestrator.computeChallenge" | df$Method == "SignerOrchestrator.computeQ" | df$Method == "SigningQProverOrchestrator.computeChallenge" | df$Method == "SigningQProverOrchestrator.populateChallengeList" | df$Method == "GSSignatureValidator.verifySignature" |  df$Method == "AbstractCommitmentVerifier.computeVerifierWitness" | df$Method == "AbstractCommitmentVerifier.executeVerification" | df$Method == "RecipientOrchestrator.generateRecipientMSK" | df$Method == "AbstractCommitmentProver.computeWitness" | df$Method == "AbstractCommitmentProver.executePreChallengePhase" | df$Method == "SignerOrchestrator.populateChallengeList" | df$Method == "AbstractCommitmentProver.computeWitnessRandomness" | df$Method == "AbstractCommitmentProver.computeResponses" | df$Method == "AbstractCommitmentProver.executePostChallengePhase" | df$Method == "SignerOrchestrator.computeA" | df$Method == "GSSignatureValidator.verifyAgainstHatQ" |  df$Method == "QRElement.modInverse" | df$Method == "QRElement.multiply" | df$Method == "SignerOrchestrator.round0" | df$Method == "SignerOrchestrator$SignatureData.computeVPrimePrimeRandomness" |  df$Method == "GSUtils.createRandomNumber" |  df$Method == "AbstractCommitmentVerifier.checkLengths" |  df$Method == "GSUtils.randomMinusPlusNumber" | df$Method == "SigningQCorrectnessVerifier.executeVerification" | df$Method == "GSRecipient.generatevPrime" |  df$Method == "SigningQProverOrchestrator.executePreChallengePhase" | df$Method == "SigningQCorrectnessProver.executePreChallengePhase" | df$Method == "SigningQCorrectnessVerifier.checkLengths" | df$Method == "SigningQVerifierOrchestrator.checkLengths" | df$Method == "SigningQProverOrchestrator.executePostChallengePhase" | df$Method == "SigningQCorrectnessProver.executePostChallengePhase" )
  return(d)
}

filterProving <- function(df){
  d <- filter(df, df$Method == "QRElement.modPow" | df$Method == "VerifierOrchestrator.executeVerification" | df$Method == "ProverOrchestrator.executePreChallengePhase" | df$Method == "VerifierOrchestrator.computeCommitmentVerifier" | df$Method == "AbstractCommitmentVerifier.computeVerifierWitnes" | df$Method == "AbstractCommitmentVerifier.executeVerificatio" | df$Method == "AbstractCommitmentProver.executePreChallengePhase" | df$Method == "PossessionVerifier.executeCompoundVerificatio" | df$Method == "PossessionVerifier.executeVerificatio" | df$Method == "ProverOrchestrator.computeTildeZ" | df$Method == "PossessionProver.executeCompoundPreChallengePhase" | df$Method == "ProverOrchestrator.computeCommitmentProvers" | df$Method == "ProverOrchestrator.readSignature" | df$Method == "AbstractCommitmentProver.computeWitness" | df$Method == "PossessionProver.computetildeZ" | df$Method == "GSSignature.verify" | df$Method == "AbstractCommitmentProver.computeResponses" | df$Method == "AbstractCommitmentProver.executePostChallengePhase" | df$Method == "ProverOrchestrator.computeIndexesCommitment" | df$Method == "ProverOrchestrator.computePairWiseCommitment" | df$Method == "GSCommitment.createCommitment" | df$Method == "VerifierOrchestrator.computeChallenge" | df$Method == "VerifierOrchestrator.constructBaseCollection" | df$Method == "VerifierOrchestrator.populateChallengeList" | df$Method == "VerifierOrchestrator.storeProofSignature" | df$Method == "AbstractCommitmentProver.computeWitnessRandomness" | df$Method == "GSProver.computeCommitments" | df$Method == "PossessionProver.executePostChallengePhase" | df$Method == "PossessionVerifier.checkLengths" | df$Method ==  "ProverOrchestrator.computeChallenge" | df$Method == "ProverOrchestrator.populateChallengeList" | df$Method == "PossessionProver.createWitnessRandomness" | df$Method == "GSUtils.computeHash" | df$Method == "GSSignatureValidator.computeQ" | df$Method == "GSSignatureValidator.verify" | df$Method == "GSSignatureValidator.verifySignature" | df$Method == "GSSignatureValidator.checkE" | df$Method == "QRElement.modInverse" | df$Method == "GSUtils.createRandomNumber" | df$Method == "AbstractCommitmentVerifier.checkLength" | df$Method == "GSSignatureValidator.verifyAgainstHatQ" | df$Method == "PairWiseDifferenceProver.computeResponses" | df$Method == "PairWiseDifferenceProver.executePostChallengePhase" | df$Method == "ProverOrchestrator.computePairWiseProvers" | df$Method == "PairWiseDifferenceProver.computeWitness" | df$Method == "PairWiseDifferenceProver.executeCompoundPreChallengePhase" | df$Method == "PairWiseDifferenceProver.executePreChallengePhas" | df$Method == "QRElement.multiply" | df$Method == "VerifierOrchestrator.computePairWiseVerifiers" | df$Method == "PairWiseDifferenceVerifier.executeVerification" | df$Method == "PairWiseDifferenceVerifier.checkLength" | df$Method == "PairWiseDifferenceProver.createWitnessRandomness" | df$Method == "VerifierOrchestrator.checkLengths" | df$Method == "PairWiseDifferenceProver.computeEEA" | df$Method == "PairWiseDifferenceProver.executePrecomputation" | df$Method == "VerifierOrchestrator.createQuery" | df$Method == "AbstractCommitmentVerifier.checkBasesLegal")
}

## create ordered mean barplots with standard deviation
createMeanSDBarplots <- function(df, dx, dy, dg, xlabel, ylabel, flabel) {
  
p <-  ggplot(df, aes(x = reorder(factor(dx), dy), y = dy)) +
    geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(dg)))  +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.25, position=position_dodge(0.9)) +
    facet_grid(dg, margins = FALSE,  scales = "free", space = "free") +
    labs( x = xlabel,  y = ylabel, fill = flabel) +
    coord_flip() +  theme_bw()
return(p) 
}


## create line plots 
createOrderedLinePlots <- function(df, dx, dy, dg, dv, xlabel, ylabel, flabel) {
  p <- ggplot(df, aes(x=reorder(factor(dx), dy), y=dy, group=factor(dg) )) +
          geom_line(aes( linetype=factor(dg), color=factor(dg))) +
          geom_point(aes(color=factor(dg))) + 
          labs( x = xlabel,  y = ylabel, color = flabel, linetype = flabel) +
          facet_grid(dv) +
          theme_bw()
  return(p)
}

## create a dataframe that includes data from csv file for all key lengths
createDataSetFromCSV <- function(csvFolder, expFolder, csvName, verticesNo) {
  (data_512 <- getCSVData(paste0(csvFolder,"-512*"), paste0("../data/", expFolder), csvName))
  # create a dataframe from the experiments
  df_512 <- bind_rows(data_512, .id="expID")
  df_512['KeyLength'] = 512
  
  (data_1024 <- getCSVData(paste0(csvFolder,"-1024*"), paste0("../data/", expFolder), csvName))
  df_1024 <- bind_rows(data_1024, .id="expID")
  df_1024['KeyLength'] = 1024
  
  (data_2048 <- getCSVData(paste0(csvFolder,"-2048*"), paste0("../data/", expFolder), csvName))
  df_2048 <- bind_rows(data_2048, .id="expID")
  df_2048['KeyLength'] = 2048
  
  (data_3072 <- getCSVData(paste0(csvFolder,"-3072*"), paste0("../data/", expFolder), csvName))
  df_3072 <- bind_rows(data_3072, .id="expID")
  df_3072['KeyLength'] = 3072
  
  perfData <- rbind(df_512, df_1024)
  perfData <- rbind(perfData, df_2048)
  perfData <- rbind(perfData, df_3072)
  
  perfData <- bind_rows(perfData, .id="expID")
  perfData['Vertices'] = verticesNo 
  return(perfData)
}

renameHeadings <- function(df, columns) {
  names(df) <- columns
  return(df)
}

## filters Method column for adding only graph signature library related functions and keeps only the name of the method
filterMethods <- function(df){
  (filtered <- df[with(df, grepl("eu.prismacloud.primitives.zkpgs.*", df$Method)), ])
  
  # truncate method names
  (filtered$Method <- gsub(pattern = "eu.prismacloud.primitives.zkpgs.", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = " (/.)*[a-zA-Z]*.java", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "\\(.*?\\)", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "prover.", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "verifier.", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "util.crypto.", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "orchestrator.", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "util.", replacement = "", filtered$Method)) 
  (filtered$Method <- gsub(pattern = "commitment.", replacement = "", filtered$Method)) 
  return(filtered)
}
