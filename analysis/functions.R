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
  d <- filter(df, df$Method == "orchestrator.SignerOrchestrator.round2" | df$Method == "orchestrator.SignerOrchestrator.encodeSignerGraph" |  df$Method == "orchestrator.SignerOrchestrator.createPartialSignature" | df$Method == "orchestrator.RecipientOrchestrator.round3" | df$Method == "orchestrator.RecipientOrchestrator.serializeFinalSignature" | df$Method == "orchestrator.SignerOrchestrator$SignatureData.computeRandomPrimeE" | df$Method == "util.GSUtils.isPrime" |  df$Method == "util.crypto.QRElement.modPow" | df$Method == "graph.GraphRepresentation.encodeGraph" | df$Method == "orchestrator.RecipientOrchestrator.round1" | df$Method == "orchestrator.RecipientOrchestrator.computeChallenge" | df$Method == "orchestrator.SignerOrchestrator.prepareProvingSigningQ" | df$Method == "orchestrator.SignerOrchestrator.verifyRecipientCommitment" |  df$Method == "orchestrator.SigningQVerifierOrchestrator.computeChallenge" | df$Method == "orchestrator.SigningQVerifierOrchestrator.executeVerification" | df$Method == "orchestrator.SigningQVerifierOrchestrator.populateChallengeList" | df$Method == "signature.GSSignature.verify" | df$Method == "signature.GSSignatureValidator.computeQ" | df$Method == "signature.GSSignatureValidator.verify"| df$Method == "util.GSUtils.computeHash" |  df$Method == "commitment.GSCommitment.createCommitment" | df$Method == "orchestrator.RecipientOrchestrator.createProofSignature" |  df$Method == "orchestrator.SignerOrchestrator.computeChallenge" | df$Method == "orchestrator.SignerOrchestrator.computeQ" | df$Method == "orchestrator.SigningQProverOrchestrator.computeChallenge" | df$Method == "orchestrator.SigningQProverOrchestrator.populateChallengeList" | df$Method == "signature.GSSignatureValidator.verifySignature" |  df$Method == "verifier.AbstractCommitmentVerifier.computeVerifierWitness" | df$Method == "verifier.AbstractCommitmentVerifier.executeVerification" | df$Method == "orchestrator.RecipientOrchestrator.generateRecipientMSK" | df$Method == "prover.AbstractCommitmentProver.computeWitness" | df$Method == "prover.AbstractCommitmentProver.executePreChallengePhase" | df$Method == "orchestrator.SignerOrchestrator.populateChallengeList" | df$Method == "prover.AbstractCommitmentProver.computeWitnessRandomness" | df$Method == "prover.AbstractCommitmentProver.computeResponses" | df$Method == "prover.AbstractCommitmentProver.executePostChallengePhase" | df$Method == "orchestrator.SignerOrchestrator.computeA" | df$Method == "signature.GSSignatureValidator.verifyAgainstHatQ" |  df$Method == "util.crypto.QRElement.modInverse" | df$Method == "util.crypto.QRElement.multiply" | df$Method == "orchestrator.SignerOrchestrator.round0" | df$Method == "orchestrator.SignerOrchestrator$SignatureData.computeVPrimePrimeRandomness" |  df$Method == "util.GSUtils.createRandomNumber" |  df$Method == "verifier.AbstractCommitmentVerifier.checkLengths" |  df$Method == "util.GSUtils.randomMinusPlusNumber" | df$Method == "verifier.SigningQCorrectnessVerifier.executeVerification" | df$Method == "recipient.GSRecipient.generatevPrime" |  df$Method == "orchestrator.SigningQProverOrchestrator.executePreChallengePhase" | df$Method == "prover.SigningQCorrectnessProver.executePreChallengePhase" | df$Method == "verifier.SigningQCorrectnessVerifier.checkLengths" | df$Method == "orchestrator.SigningQVerifierOrchestrator.checkLengths" | df$Method == "orchestrator.SigningQProverOrchestrator.executePostChallengePhase" | df$Method == "prover.SigningQCorrectnessProver.executePostChallengePhase" )
  return(d)
}

filterProving <- function(df){
  d <- filter(df, df$Method == "util.crypto.QRElement.modPow" | df$Method == "orchestrator.VerifierOrchestrator.executeVerification" | df$Method == "orchestrator.ProverOrchestrator.executePreChallengePhase" | df$Method == "orchestrator.VerifierOrchestrator.computeCommitmentVerifier" | df$Method == "verifier.AbstractCommitmentVerifier.computeVerifierWitnes" | df$Method == "verifier.AbstractCommitmentVerifier.executeVerificatio" | df$Method == "prover.AbstractCommitmentProver.executePreChallengePhase" | df$Method == "verifier.PossessionVerifier.executeCompoundVerificatio" | df$Method == "verifier.PossessionVerifier.executeVerificatio" | df$Method == "orchestrator.ProverOrchestrator.computeTildeZ" | df$Method == "prover.PossessionProver.executeCompoundPreChallengePhase" | df$Method == "orchestrator.ProverOrchestrator.computeCommitmentProvers" | df$Method == "orchestrator.ProverOrchestrator.readSignature" | df$Method == "prover.AbstractCommitmentProver.computeWitness" | df$Method == "prover.PossessionProver.computetildeZ" | df$Method == "signature.GSSignature.verify" | df$Method == "prover.AbstractCommitmentProver.computeResponses" | df$Method == "prover.AbstractCommitmentProver.executePostChallengePhase" | df$Method == "orchestrator.ProverOrchestrator.computeIndexesCommitment" | df$Method == "orchestrator.ProverOrchestrator.computePairWiseCommitment" | df$Method == "commitment.GSCommitment.createCommitment" | df$Method == "orchestrator.VerifierOrchestrator.computeChallenge" | df$Method == "orchestrator.VerifierOrchestrator.constructBaseCollection" | df$Method == "orchestrator.VerifierOrchestrator.populateChallengeList" | df$Method == "orchestrator.VerifierOrchestrator.storeProofSignature" | df$Method == "prover.AbstractCommitmentProver.computeWitnessRandomness" | df$Method == "prover.GSProver.computeCommitments" | df$Method == "prover.PossessionProver.executePostChallengePhase" | df$Method == "verifier.PossessionVerifier.checkLengths" | df$Method ==  "orchestrator.ProverOrchestrator.computeChallenge" | df$Method == "orchestrator.ProverOrchestrator.populateChallengeList" | df$Method == "prover.PossessionProver.createWitnessRandomness" | df$Method == "util.GSUtils.computeHash" | df$Method == "signature.GSSignatureValidator.computeQ" | df$Method == "signature.GSSignatureValidator.verify" | df$Method == "signature.GSSignatureValidator.verifySignature" | df$Method == "signature.GSSignatureValidator.checkE" | df$Method == "util.crypto.QRElement.modInverse" | df$Method == "util.GSUtils.createRandomNumber" | df$Method == "verifier.AbstractCommitmentVerifier.checkLength" | df$Method == "signature.GSSignatureValidator.verifyAgainstHatQ" | df$Method == "prover.PairWiseDifferenceProver.computeResponses" | df$Method == "prover.PairWiseDifferenceProver.executePostChallengePhase" | df$Method == "orchestrator.ProverOrchestrator.computePairWiseProvers" | df$Method == "prover.PairWiseDifferenceProver.computeWitness" | df$Method == "prover.PairWiseDifferenceProver.executeCompoundPreChallengePhase" | df$Method == "prover.PairWiseDifferenceProver.executePreChallengePhas" | df$Method == "util.crypto.QRElement.multiply" | df$Method == "orchestrator.VerifierOrchestrator.computePairWiseVerifiers" | df$Method == "verifier.PairWiseDifferenceVerifier.executeVerification" | df$Method == "verifier.PairWiseDifferenceVerifier.checkLength" | df$Method == "prover.PairWiseDifferenceProver.createWitnessRandomness" | df$Method == "orchestrator.VerifierOrchestrator.checkLengths" | df$Method == "prover.PairWiseDifferenceProver.computeEEA" | df$Method == "prover.PairWiseDifferenceProver.executePrecomputation" | df$Method == "orchestrator.VerifierOrchestrator.createQuery" | df$Method == "verifier.AbstractCommitmentVerifier.checkBasesLegal")
}

## create ordered mean barplots with standar deviation
createMeanSDBarplots <- function(df, dx, dy, dg, xlabel, ylabel, flabel) {
  
p <-  ggplot(df, aes(x = reorder(factor(dx), dy), y = dy)) +
    geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(dg)))  +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.25, position=position_dodge(0.9)) +
    facet_grid(dg, margins = FALSE,  scales = "free", space = "free") +
    labs( x = xlabel,  y = ylabel, fill = flabel) +
    coord_flip() +  theme_bw()
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
  return(filtered)
}
