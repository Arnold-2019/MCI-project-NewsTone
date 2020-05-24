library(readxl)
library(tidytext)
library(ggplot2)
library(dplyr)
library(wordcloud)
library(RColorBrewer)
library(reshape2)

# load raw data
my_data <- read_excel("/Users/wangying/Team23/code/sentiment_analysis/xlsx/10yr-titles.xlsx", 
                          col_types = c("skip", "text", "text", "text", "text", "text"))

stop_words

# pre-processing the raw data
tidy_text <- my_data %>%
  unnest_tokens(word,title) %>%
  anti_join(stop_words)

tidy_text

# generate monthly data object
m_text <- tidy_text[which(tidy_text$month==9 & tidy_text$year==2011),]
tidy_text
tidy_text <- tidy_text[-which(tidy_text$word=="top"),]
tidy_text <- tidy_text[-which(tidy_text$word=="trump"),]
tidy_text

# show the barchart of monthly word requency
m_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup() %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Word frequency",x = NULL) +
  coord_flip()

# show monthly wordcloud
m_text %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("red", "blue"),max.words = 150)
  