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
    titlePanel("News Tone"),
    sidebarLayout(
      sidebarPanel(width = 3,
        h4("Object of Analysis"),
        h6("This project is based on research on the website news.com.au."),
        br(),
        img(src = "logo.png", heigt = 45, width = 120),
        h6("Austrilian news and entertainment website.")
        ),
      mainPanel(
        h4("Introduction"),
        p("- Using sentiment analysis technique to analyze the article titles on the front page of the website news.com.au."),
        p("- Identifying whether the overall sentiment for a given day is positive or negative"),
        p("- Identifying what types of news show up most often on which days."),
        br(),
        p("Visit the ", a("news.com.au.", href = "https://www.news.com.au"))
      )
    ),
    hr(),
    
    fluidRow(
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
              min = 1, max = 12, value = 6),
          hr(),
          h6("The graph on the right shows the overall sentiment of each day in the selected year.")
        ),
        
        mainPanel(width = 9,
                  plotOutput("year_tone"),
        )
      )
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
      sidebarLayout(
        sidebarPanel(width = 3,
                     numericInput("start_date", label = h4("Input start date"), value = 20100101),
                     numericInput("end_date", label = h4("Input end date"), value = 20191231),
                     hr(),
                     h6("The graph on the right shows the overall sentiment of each day in the selected range of date.")
        ),
        
        mainPanel(width = 9,
                  plotOutput("date_range_tone")
        )
      ),
    ),
    hr(),
    
    fluidRow(
      column(3,
        p("- The graph", 
          strong("DAY"),
          "shows what types of news show up most often on which days."
        ),
        p("- The graph",
          strong("Month"),
          "shows what types of news show up most often on which months."
        ),
        br(),
        p("Note: They are based on all 10-years data.")
      ),
      column(6, plotOutput("day_tone")),
      column(3, plotOutput("month_tone"))
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
    
    # plot word frequency barchart
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
    # plot word cloud
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
            mutate(tone = (3*positive - negative) / (positive + negative),
                   index = row_number())
        
        ggplot(range_tone, aes(index, tone, fill= year)) +
            geom_bar(stat = "identity", show.legend = FALSE) +
            facet_wrap(~year, ncol = 2, scales = "free_x")
    })
    
    output$day_tone <- renderPlot({
        day_tone <- tidy_text %>%
            inner_join(get_sentiments("bing"), by = "word") %>%
            count(day,sentiment) %>%
            spread(sentiment, n, fill = 0) %>%
            mutate(tone = (3*positive - negative) / (positive + negative),
                   index = as.numeric(day), wrap = "DAY")

        ggplot(day_tone, aes(index, tone, fill= 0)) +
            geom_bar(stat = "identity", show.legend = FALSE, fill = "steelblue") +
            facet_wrap(~wrap, ncol = 1, scales = "free_x")
    })
    
    output$month_tone <- renderPlot({
        month_tone <- tidy_text %>%
            inner_join(get_sentiments("bing"), by = "word") %>%
            count(month, sentiment) %>%
            spread(sentiment, n, fill = 0) %>%
            mutate(tone = (3*positive - negative) / (positive + negative),
                   index = as.numeric(month), wrap = "MONTH")

        ggplot(month_tone, aes(index, tone, fill= 0)) +
            geom_bar(stat = "identity", show.legend = FALSE, fill = "steelblue") +
            facet_wrap(~wrap, ncol = 1, scales = "free_x")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
