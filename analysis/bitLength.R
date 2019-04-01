# bitlength computation analysis
setwd("~/DEV/lib-graph-sig-benchmarks/analysis")
source("packages.R")
source("functions.R")
source("configuration.R")

# create an analysis for computing the bitlength of group elements send over the wire for each stage of the protocol
folder_path <- paste0("../data/", "bitlength-csv")
issuing_msgs <- c("message_1", "message_2", "message_3")
proving_msgs <- c("message_1", "message_2", "message_3", "message_4", "message_5")
k_csv_file <- data.frame()

create_msg_df <- function(stage, messages) {
  key_length <- c("512", "1024", "2048", "3072")
  m_files <- list()

  for (k in 1:length(key_length)) {
    folder_name <- paste0(stage, "-", key_length[[k]])

    for (m in 1:length(messages)) {
      file_name <- paste0(messages[[m]], "-", key_length[[k]], ".csv")
      m_csv_file <- getCSVData(folder_name, folder_path, file_name)
      m_files[[m]] <- m_csv_file[[1]]
      m_csv_file <- bind_rows(m_csv_file, .id = "Stage")
      m_csv_file["Stage"] <- stage
      m_csv_file <- bind_rows(m_csv_file, .id = "KeyLength")
      m_csv_file["KeyLength"] <- key_length[[k]]
      m_csv_file <- bind_rows(m_csv_file, .id = "MessageNo")
      m_csv_file["MessageNo"] <- messages[m]
      k_csv_file <- rbind(k_csv_file, m_csv_file)
    }
  }

  return(k_csv_file)
}

issuing_bitlength <- create_msg_df("issuing", issuing_msgs)
proving_bitlength <- create_msg_df("proving", proving_msgs)

bitlength_df <- rbind(issuing_bitlength, proving_bitlength)

(issuing_count <- issuing_bitlength %>%
  group_by(Stage, MessageNo, ClassName) %>%
  tally())

(proving_count <- proving_bitlength %>%
  group_by(Stage, MessageNo, ClassName) %>%
  tally())

ggplot(elementsIssuing, aes(x = factor(elementsIssuing$MessageNo), y = elementsIssuing$freq, fill = elementsIssuing$ClassName)) +
  geom_bar(stat = "identity") + theme_bw() +
  labs(x = "Message No", y = "# of elements", fill = "Class Name")

savePlot("issuing-elements-no-per-message.pdf")

(proving_count_msg1 <- count(proving_msg1, "ClassName"))
p_msg1 <- bind_rows(proving_count_msg1, .id = "MessageNo")
p_msg1["MessageNo"] <- 1

(proving_count_msg2 <- count(proving_msg2, "ClassName"))
p_msg2 <- bind_rows(proving_count_msg2, .id = "MessageNo")
p_msg2["MessageNo"] <- 2
elementsProving <- rbind(p_msg1, p_msg2)

proving_count_msg3 <- count(proving_msg3, "ClassName")
p_msg3 <- bind_rows(proving_count_msg3, .id = "MessageNo")
p_msg3["MessageNo"] <- 3
elementsProving <- rbind(elementsProving, p_msg3)

proving_count_msg5 <- count(proving_msg5, "ClassName")
p_msg5 <- bind_rows(proving_count_msg5, .id = "MessageNo")
p_msg5["MessageNo"] <- 4
elementsProving <- rbind(elementsProving, p_msg5)

proving_count_msg7 <- count(proving_msg7, "ClassName")
p_msg7 <- bind_rows(proving_count_msg7, .id = "MessageNo")
p_msg7["MessageNo"] <- 5
elementsProving <- rbind(elementsProving, p_msg7)
summary(elementsProving)

ggplot(elementsProving, aes(x = factor(elementsProving$MessageNo), y = elementsProving$freq, fill = elementsProving$ClassName)) +
  geom_bar(stat = "identity") + theme_bw() +
  labs(x = "Message No", y = "# of elements", fill = "Class Name")
savePlot("proving-elements-no-per-message.pdf")

(total_QRElements_Proving <- proving_count_msg2[2, 2] + proving_count_msg3[2, 2] + proving_count_msg7[2, 2])
names <- c("Issuing", "Proving")
qrElements <- c(total_QRElements_Issuing, total_QRElements_Proving)

(totalQREl <- data.frame(names, qrElements))

ggplot(totalQREl, aes(x = totalQREl$names, y = totalQREl$qrElements, fill = totalQREl$names)) +
  geom_bar(stat = "identity") + theme_bw() +
  labs(x = "", y = "# of QRElements", fill = "")

savePlot("QRElements-per-stage.pdf")
