# News Spider
This repository stores the source code of NewsSpider. It crawls all news titles of news.com.au from 2010 to 2019 and stores them into JSON files.

How to start it ? - macOS 

To start the crawler:

    Step 1: go to the project directory
        $ cd .../code/newstone
        
    Step 2: enter the virtrual environment
        $ source venv/bin/activate
        
    Step 3: you may need to conduct a install operation to make sure every thing is set
        $ pip install scrapy

        
    Step 4: crawl a web page and store crawled titles in a json file
        $ cd newstone
        $ scrapy crawl titlespider -o filename.json
        
        e.g. $ scrapy crawl titlespider -o news-title.json

To open a scrapy shell:

    $ scrapy shell ***urls***
    
    e.g. $ scrapy shell https://news.com.au

Note: please checkout yourself to play with winOS

Reference: (YouTube video)
    https://www.youtube.com/watch?v=ALizgnSFTwQ&t=1523s
