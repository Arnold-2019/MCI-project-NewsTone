# Dependencies
library(shiny)
library(dplyr)
library(ggplot2)
library(readxl)
library(reshape2)
library(RColorBrewer)
library(tidyr)
library(tidytext)
library(textdata)
library(wordcloud)

# Define UI to display info.
ui <- fluidPage(
    # Application title
    titlePanel("News Tone - news.com.au"),
    
    hr(),
    fluidRow(
        column(12,
            sidebarLayout(
                sidebarPanel(width = 3,
                    # select the year to view
                    selectInput("year", label = h4("Select year"),
                        choices = list("2010"=2010, "2011"=2011, "2012"=2012, 
                                       "2013"=2013, "2014"=2014, "2015"=2015,
                                       "2016"=2016, "2017"=2017, "2018"=2018,
                                       "2019"=2019), 
                        selected = 2014),
                    hr(),
                    # select the month to view
                    sliderInput("month", label = h4("Select month"),
                        min = 1, max = 12, value = 6)
                ),
                mainPanel(width = 9,
                    plotOutput("year_tone"),
                )
            )
        ),
    ),
    
    fluidRow(
        column(4,
               plotOutput("word_freq") 
        ),
        column(8,
               plotOutput("wordcloud")
        )
    ),
    hr(),
    
    fluidRow(
        column(3,
               numericInput("start_date", label = h4("Input start date"), value = 20100101),
               numericInput("end_date", label = h4("Input end date"), value = 20191231)
        ),
        column(9,
               plotOutput("date_range_tone")
        )
    )
)

# Define server logic required to display Sentiment Analysis ouputs
server <- function(input, output) {
    # load raw data
    my_data <- read_excel("10yr-titles.xlsx", 
                          col_types = c("skip", "text", "text", "text", "text", "text"))
    
    # data pre-processing
    my_data <- my_data[complete.cases(my_data[,5]),]
    
    tidy_text <- my_data %>%
        unnest_tokens(word,title) %>%
        anti_join(stop_words)
    tidy_text <- tidy_text[-which(tidy_text$word=="top"),]
    tidy_text <- tidy_text[-which(tidy_text$word=="trump"),]
    tidy_text <- tidy_text[-which(tidy_text$word=="bonus"),]
    
    # plot word frequency barchart (within one month)
    output$word_freq <- renderPlot({
        m_text <- tidy_text[which(tidy_text$month==input$month & tidy_text$year==input$year),]
        
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
            labs(y = paste("Word Frequency (", input$month, "-", input$year, ")"),x = "Top10 Words") +
            coord_flip()
    })
    # plot word cloud (within one month)
    output$wordcloud <- renderPlot({
        m_text <- tidy_text[which(tidy_text$month==input$month & tidy_text$year==input$year),]
        
        m_text %>%
            anti_join(stop_words) %>%
            inner_join(get_sentiments("bing")) %>%
            count(word, sentiment, sort = TRUE) %>%
            acast(word ~ sentiment, value.var = "n", fill = 0) %>%
            comparison.cloud(colors = c("red", "turquoise4"),max.words = 120)
    })
    # plot the tone distributiion of one year
    output$year_tone <- renderPlot({
        y_text <- tidy_text[which(tidy_text$year==input$year),]
        
        y_tone <- y_text %>%
            inner_join(get_sentiments("bing"), by = "word") %>%
            count(date, year, sentiment) %>%
            spread(sentiment, n, fill = 0) %>%
            mutate(tone = (2*positive - negative) / (positive + negative),
                   index = row_number())
        
        ggplot(y_tone, aes(index, tone, fill= year)) +
            geom_bar(stat = "identity", show.legend = FALSE) +
            facet_wrap(~year, ncol = 2, scales = "free_x")
    })
    
    output$date_range_tone <- renderPlot({
        range_text <- tidy_text[which(tidy_text$date>=input$start_date
                                      & tidy_text$date<=input$end_date),]
        
        range_tone <- range_text %>%
            inner_join(get_sentiments("bing"), by = "word") %>%
            count(date, year, sentiment) %>%
            spread(sentiment, n, fill = 0) %>%
            mutate(tone = (2*positive - negative) / (positive + negative),
                   index = row_number())
        
        ggplot(range_tone, aes(index, tone, fill= year)) +
            geom_bar(stat = "identity", show.legend = FALSE) +
            facet_wrap(~year, ncol = 2, scales = "free_x")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
