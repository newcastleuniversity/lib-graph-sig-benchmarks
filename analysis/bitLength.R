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
  tally(name = "count"))

(proving_count <- proving_bitlength %>%
  group_by(Stage, MessageNo, ClassName) %>%
  tally(name = "count"))

(bitlength_count <- bitlength_df %>%
  group_by(Stage, MessageNo, ClassName, KeyLength) %>%
  tally(name = "count"))

ggplot(issuing_count, aes(x = factor(issuing_count$MessageNo), y = issuing_count$count, fill = issuing_count$ClassName)) +
  geom_bar(stat = "identity") +
  labs(x = "Message No", y = "# of elements", fill = "")

savePlot("issuing-elements-no-per-message.pdf")

ggplot(proving_count, aes(x = factor(proving_count$MessageNo), y = proving_count$count, fill = proving_count$ClassName)) +
  geom_bar(stat = "identity") +
  labs(x = "Message No", y = "# of elements", fill = "")
savePlot("proving-elements-no-per-message.pdf")

(bitlength_count_512 <- bitlength_count %>%
  filter(KeyLength == "512"))

ggplot(bitlength_count_512, aes(x = bitlength_count_512$Stage, y = bitlength_count_512$count, fill = bitlength_count_512$ClassName)) +
  geom_bar(stat = "identity") +
  labs(x = "", y = "# of QRElements", fill = "")

savePlot("QRElements-per-stage.pdf")

(issuing_sum <- bitlength_df %>%
  group_by(Stage, KeyLength) %>%
  summarise(sum = sum(Bitlength)))

ggplot(issuing_sum, aes(x = reorder(factor(issuing_sum$Stage)), y = issuing_sum$sum, group = issuing_sum$KeyLength)) +
  geom_line(aes(linetype = factor(issuing_sum$KeyLength), color = factor(issuing_sum$KeyLength)), size = 1) +
  geom_point(aes(shape = factor(issuing_sum$KeyLength), colour = factor(issuing_sum$KeyLength)), size = 2) +
  # facet_wrap(issuing_sum$Stage ~ ., scales = "free_y",  ncol = 5) +
  labs(x = "", y = "Total bitlength", colour = "Key Length", shape = "") +
  # background_grid(major = "xy", minor = "none") +
  guides(shape = FALSE, linetype = FALSE) +
  theme(
    strip.text.x = element_text(colour = "black", size = 10),
    strip.background = element_blank(),
    strip.placement = "outside", aspect.ratio = 1.4
  )

savePlot("bitlength-sum-keylength-lineplot.pdf")
