# news-tone
For macOS 

To use the crawler:

    Step 1: go to the project directory
        $ cd .../.../newstone
        
    Step 2: enter the virtrual environment
        $ source venv/bin/activate
        
    Step 3: crawl a web page and store crawled titles in a json file
        $ scrapy crawl posts -o *file name*.json
        
        e.g. $ scrapy crawl posts -o news-title.json

To open a scrapy shell:

    $ scrapy shell *urls*
    
    e.g. $ scrapy shell https://news.com.au

Note: please checkout yourself to play with winOS
