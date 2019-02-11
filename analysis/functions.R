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
  d <- df <- filter(df, df$Method == "orchestrator.SignerOrchestrator.round2" | df$Method == "orchestrator.SignerOrchestrator.encodeSignerGraph" |  df$Method == "orchestrator.SignerOrchestrator.createPartialSignature" | df$Method == "orchestrator.RecipientOrchestrator.round3" | df$Method == "orchestrator.RecipientOrchestrator.serializeFinalSignature" | df$Method == "orchestrator.SignerOrchestrator$SignatureData.computeRandomPrimeE" | df$Method == "util.GSUtils.isPrime" |  df$Method == "util.crypto.QRElement.modPow" | df$Method == "graph.GraphRepresentation.encodeGraph" | df$Method == "orchestrator.RecipientOrchestrator.round1" | df$Method == "orchestrator.RecipientOrchestrator.computeChallenge" | df$Method == "orchestrator.SignerOrchestrator.prepareProvingSigningQ" | df$Method == "orchestrator.SignerOrchestrator.verifyRecipientCommitment" |  df$Method == "orchestrator.SigningQVerifierOrchestrator.computeChallenge" | df$Method == "orchestrator.SigningQVerifierOrchestrator.executeVerification" | df$Method == "orchestrator.SigningQVerifierOrchestrator.populateChallengeList" | df$Method == "signature.GSSignature.verify" | df$Method == "signature.GSSignatureValidator.computeQ" | df$Method == "signature.GSSignatureValidator.verify"| df$Method == "util.GSUtils.computeHash" |  df$Method == "commitment.GSCommitment.createCommitment" | df$Method == "orchestrator.RecipientOrchestrator.createProofSignature" |  df$Method == "orchestrator.SignerOrchestrator.computeChallenge" | df$Method == "orchestrator.SignerOrchestrator.computeQ" | df$Method == "orchestrator.SigningQProverOrchestrator.computeChallenge" | df$Method == "orchestrator.SigningQProverOrchestrator.populateChallengeList" | df$Method == "signature.GSSignatureValidator.verifySignature" |  df$Method == "verifier.AbstractCommitmentVerifier.computeVerifierWitness" | df$Method == "verifier.AbstractCommitmentVerifier.executeVerification" | df$Method == "orchestrator.RecipientOrchestrator.generateRecipientMSK" | df$Method == "prover.AbstractCommitmentProver.computeWitness" | df$Method == "prover.AbstractCommitmentProver.executePreChallengePhase" | df$Method == "orchestrator.SignerOrchestrator.populateChallengeList" | df$Method == "prover.AbstractCommitmentProver.computeWitnessRandomness" | df$Method == "prover.AbstractCommitmentProver.computeResponses" | df$Method == "prover.AbstractCommitmentProver.executePostChallengePhase" | df$Method == "orchestrator.SignerOrchestrator.computeA" | df$Method == "signature.GSSignatureValidator.verifyAgainstHatQ" |  df$Method == "util.crypto.QRElement.modInverse" | df$Method == "util.crypto.QRElement.multiply" | df$Method == "orchestrator.SignerOrchestrator.round0" | df$Method == "orchestrator.SignerOrchestrator$SignatureData.computeVPrimePrimeRandomness" |  df$Method == "util.GSUtils.createRandomNumber" |  df$Method == "verifier.AbstractCommitmentVerifier.checkLengths" |  df$Method == "util.GSUtils.randomMinusPlusNumber" | df$Method == "verifier.SigningQCorrectnessVerifier.executeVerification" | df$Method == "recipient.GSRecipient.generatevPrime" |  df$Method == "orchestrator.SigningQProverOrchestrator.executePreChallengePhase" | df$Method == "prover.SigningQCorrectnessProver.executePreChallengePhase" | df$Method == "verifier.SigningQCorrectnessVerifier.checkLengths" | df$Method == "orchestrator.SigningQVerifierOrchestrator.checkLengths" | df$Method == "orchestrator.SigningQProverOrchestrator.executePostChallengePhase" | df$Method == "prover.SigningQCorrectnessProver.executePostChallengePhase" )
  return(d)
}

createMeanSDBarplots <- function(df, dx, dy, dg, xlabel, ylabel, flabel) {
  
p <-  ggplot(df, aes(x = reorder(factor(dx), dy), y = dy)) +
    geom_bar(stat = "summary", fun.y = "mean", position = "dodge", aes(fill = factor(dg)))  +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.25, position=position_dodge(0.9)) +
    facet_grid(dg, margins = FALSE,  scales = "free", space = "free") +
    labs( x = xlabel,  y = ylabel, fill = flabel) +
    coord_flip() +  theme_bw()
return(p) 
}
