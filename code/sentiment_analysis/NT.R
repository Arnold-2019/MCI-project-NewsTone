library(readxl)
library(dplyr)
library(tidytext)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(reshape2)
library(textdata)
library(tidyr)

# import news titles (one-row-per-title)
my_data <- read_excel("/Users/wangying/Team23/code/sentiment_analysis/xlsx/10yr-titles.xlsx", 
                          col_types = c("skip", "text", "text","text", "text", "text"))

# remove NA titles
my_data <- my_data[complete.cases(my_data[,5]),]
my_data

# remove error titles
# row_index <- which(my_data$title == 'News.com.au Top stories')
# my_data <- my_data[-row_index,]

# restructure my_data as one-token-per-row
# remove stop_words
tidy_text <- my_data %>%
  unnest_tokens(word,title) %>%
  anti_join(stop_words)
# display tidy_text
tidy_text %>%
  count(date, word, sort = T)

tidy_text <- tidy_text[-which(tidy_text$word=="top"),]
tidy_text <- tidy_text[-which(tidy_text$word=="trump"),]
tidy_text <- tidy_text[-which(tidy_text$word=="bonus"),]

tidy_text %>%
  count(word, sort= TRUE)

tidy_text

wordsentiments <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word")
wordsentiments

yeartone <- wordsentiments %>%
  count(year, sentiment)
yeartone

# analyse the sentiment of each word
# count rows according to 'date' & 'sentiment' colums
# display
tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(date, year, sentiment)


# analyze tone by month
month_tone <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(month, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(tone = (2.9*positive - negative) / (positive + negative),
         index = as.numeric(month), wrap = "MONTH")
# plot month analysis results
ggplot(month_tone, aes(index, tone, fill= 0)) +
  geom_bar(stat = "identity", show.legend = FALSE, fill = "steelblue") +
  facet_wrap(~wrap, ncol = 1, scales = "free_x")


# analyze tone by day
day_tone <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(day,sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(tone = (2.9*positive - negative) / (positive + negative),
         index = as.numeric(day), wrap = "DAY")
# plot daily analysis reults 
ggplot(day_tone, aes(index, tone, fill= 0)) +
  geom_bar(stat = "identity", show.legend = FALSE, fill = "steelblue") +
  facet_wrap(~wrap, ncol = 1, scales = "free_x")


# analyse the sentiment of each word in 'tidy_text'
# count rows according to 'date' & 'sentiment' colums
# spread 'sentiment' to 'positive' & 'negative' colums
# add 3 colums: 'tone', 'year', 'index'
year_tone <- tidy_text %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(date, year, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(tone = (2.9*positive - negative) / (positive + negative),
         index = row_number())
# plot anual analysis results
ggplot(year_tone, aes(index, tone, fill= year)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~year, ncol = 2, scales = "free_x")




