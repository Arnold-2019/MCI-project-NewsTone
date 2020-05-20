library(readxl)
library(tidytext)
library(ggplot2)
library(dplyr)
library(wordcloud)
library(RColorBrewer)
library(reshape2)
X1yr_titles <- read_excel("WeChat Files/onecrazyguy/FileStorage/File/2020-05/1yr-titles.xls", 
                          col_types = c("skip", "text", "text"))
View(X1yr_titles)

my_data <- X1yr_titles

tidy_text <- my_data %>%
  unnest_tokens(word,title)

View(tidy_text)

data("stop_words")

tidy_text <- tidy_text %>%
  anti_join(stop_words)

tidy_text %>%
  count(word, sort= TRUE)

tidy_text %>%
  count(word,sort=TRUE) %>%
  filter(n,600) %>%
  mutate(word=reorder(word,n))%>%
  ggplot(aes(word,n)) +
  geom_col()+
  xlab(NULL)+
  coord_flip()

get_sentiments("bing")

get_sentiments("bing") %>% 
  count(sentiment)

bing_word_counts <- tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

View(bing_word_counts)

bing_word_counts %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Contribution to sentiment",x = NULL) +
  coord_flip()

custom_stop_words <- bind_rows(tibble(word = c("miss"), 
                                      lexicon = c("custom")), 
                               stop_words)

View(custom_stop_words)


tidy_text %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))

tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("blue", "red"),
                   max.words = 100)
