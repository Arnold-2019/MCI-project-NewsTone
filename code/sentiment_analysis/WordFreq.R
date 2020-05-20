library(readxl)
library(tidytext)
library(ggplot2)
library(dplyr)
library(wordcloud)
library(RColorBrewer)
library(reshape2)
X1yr_titles <- read_excel("/Users/wangying/Team23/code/tone_analysis/xlsx/10yr-titles.xlsx", 
                          col_types = c("skip", "text", "text", "text", "text", "text"))
X1yr_titles

my_data <- X1yr_titles

tidy_text <- my_data %>%
  unnest_tokens(word,title) %>%
  anti_join(stop_words)
tidy_text

month <- 10
repeat {
  m_text <- tidy_text[which(tidy_text$month==5
                            & tidy_text$year==2019),]
  m_text
  bing_word_counts <- m_text %>%
    inner_join(get_sentiments("bing")) %>%
    count(word, sentiment, sort = TRUE) %>%
    ungroup()
  
  bing_word_counts %>%
    group_by(sentiment) %>%
    top_n(10) %>%
    ungroup() %>%
    mutate(word = reorder(word, n)) %>%
    ggplot(aes(word, n, fill = sentiment)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~sentiment, scales = "free_y") +
    labs(y = "Word frequency",x = NULL) +
    coord_flip()
  
  m_text %>%
    anti_join(stop_words) %>%
    inner_join(get_sentiments("bing")) %>%
    count(word, sentiment, sort = TRUE) %>%
    acast(word ~ sentiment, value.var = "n", fill = 0) %>%
    comparison.cloud(colors = c("red", "blue"),max.words = 150)
  
  month <- month + 1
  if(month > 12) break
}

tidy_text['day']  # get 'day' column
head(tidy_text[c('month', 'day')])  # get 'month' and 'day' columns

bing_word_counts <- tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()
bing_word_counts

bing_word_counts %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Word frequency",x = NULL) +
  coord_flip()

tidy_text %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("red", "blue"),max.words = 150)








rownames(tidy_text) = tidy_text$day
head(tidy_text)
tidy_text['20181231',]
tidy_text[1:5,]   # get first 5 rows
tidy_text[1:3]    # get first 3 columns
tidy_text[1:5,3:5]

