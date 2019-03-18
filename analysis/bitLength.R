# bitlength computation analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
source("packages.R")
source("functions.R")
source("configuration.R")

#create an analysis for computing the bitlength of group elements send over the wire for each stage of the protocol

# bitlengths for message elements during issuing
(issuing_msg1 <- getCSVData("issuing-512",  paste0("../data/", "bitlength-csv"), "message_1-2019-03-15_01-02-53.csv"))
issuing_msg1 <- issuing_msg1[[1]]

(issuing_msg2 <- getCSVData("issuing-512",  paste0("../data/", "bitlength-csv"), "message_2-2019-03-15_01-02-53.csv"))
issuing_msg2 <- issuing_msg2[[1]]

(issuing_msg3 <- getCSVData("issuing-512",  paste0("../data/", "bitlength-csv"), "message_3-2019-03-15_01-02-53.csv"))
issuing_msg3 <- issuing_msg3[[1]]

# bitlengths for messages during proving/verifying 
(proving_msg1 <- getCSVData("proving-512",  paste0("../data/", "bitlength-csv"), "message_1-2019-03-15_12-37-46.csv"))
proving_msg1 <- proving_msg1[[1]]

(proving_msg2 <- getCSVData("proving-512",  paste0("../data/", "bitlength-csv"), "message_2-2019-03-15_12-37-46.csv"))
proving_msg2 <- proving_msg2[[1]]

(proving_msg3 <- getCSVData("proving-512",  paste0("../data/", "bitlength-csv"), 
                    "message_3-2019-03-15_12-37-47.csv"))
proving_msg3 <- proving_msg3[[1]]

(proving_msg5 <- getCSVData("proving-512",  paste0("../data/", "bitlength-csv"), 
                    "message_5-2019-03-15_12-37-47.csv"))
proving_msg5 <- proving_msg5[[1]]

(proving_msg7 <- getCSVData("proving-512",  paste0("../data/", "bitlength-csv"), 
                    "message_7-2019-03-15_12-37-48.csv"))[[1]]
proving_msg7 <- proving_msg7[[1]]

# count number of QRElement and BigInteger elements communicated in each message for issuing and proving/verifying
issuing_count_msg1 <- count(issuing_msg1, "ClassName")

i_msg1 <- bind_rows(issuing_count_msg1, .id="MessageNo")
i_msg1['MessageNo'] = 1

(issuing_count_msg2 <- count(issuing_msg2, "ClassName"))
issuing_count_msg2[2,2]
issuing_count_msg2$freq
i_msg2 <- bind_rows(issuing_count_msg2, .id = "MessageNo")
i_msg2['MessageNo'] = 2
elementsIssuing <- rbind(i_msg1, i_msg2)

issuing_count_msg3 <- count(issuing_msg3, "ClassName")
i_msg3 <- bind_rows(issuing_count_msg3, .id = "MessageNo")
i_msg3['MessageNo'] = 3
elementsIssuing <- rbind(elementsIssuing, i_msg3)

# calculate total number of QRElements during issuing
(total_QRElements_Issuing <- issuing_count_msg2[2,2] + issuing_count_msg3[2,2])

summary(elementsIssuing)

ggplot(elementsIssuing, aes(x=factor(elementsIssuing$MessageNo), y=elementsIssuing$freq, fill=elementsIssuing$ClassName)) +
  geom_bar(stat="identity") + theme_bw() +
  labs( x="Message No",  y = "Number of elements", fill="Class Name") 

(proving_count_msg1 <- count(proving_msg1, "ClassName"))
p_msg1 <- bind_rows(proving_count_msg1, .id = "MessageNo")
p_msg1['MessageNo'] = 1

(proving_count_msg2 <- count(proving_msg2, "ClassName"))
p_msg2 <- bind_rows(proving_count_msg2, .id = "MessageNo")
p_msg2['MessageNo'] = 2
elementsProving <- rbind(p_msg1, p_msg2)

proving_count_msg3 <- count(proving_msg3, "ClassName")
p_msg3 <- bind_rows(proving_count_msg3, .id = "MessageNo")
p_msg3['MessageNo'] = 3
elementsProving <- rbind(elementsProving, p_msg3)

proving_count_msg5 <- count(proving_msg5, "ClassName")
p_msg5 <- bind_rows(proving_count_msg5, .id = "MessageNo")
p_msg5['MessageNo'] = 4
elementsProving <- rbind(elementsProving, p_msg5)

proving_count_msg7 <- count(proving_msg7, "ClassName")
p_msg7 <- bind_rows(proving_count_msg7, .id = "MessageNo")
p_msg7['MessageNo'] = 5
elementsProving <- rbind(elementsProving, p_msg7)
summary(elementsProving)

(total_QRElements_Proving <- proving_count_msg2[2,2] + proving_count_msg3[2,2] + proving_count_msg7[2,2])
names <- c("Issuing", "Proving")
qrElements <- c(total_QRElements_Issuing, total_QRElements_Proving)

(totalQREl <- data.frame(names, qrElements))

ggplot(totalQREl, aes(x=totalQREl$names, y=totalQREl$qrElements, fill= totalQREl$names)) +
  geom_bar(stat="identity") + theme_bw() +
  labs( x="",  y = "Number of QRElements", fill="") 
