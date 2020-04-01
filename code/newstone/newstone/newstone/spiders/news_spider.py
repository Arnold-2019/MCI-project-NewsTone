import scrapy

class NewsSpider(scrapy.Spider):
    name = "posts"

    start_urls = [
        'https://news.com.au'
    ]

    def parse(self, response):
        yield {
            'date': response.css('.date::text').get()
        }
        for post in response.css('h4'):
            yield {
                'title': post.css('a::text').get()
            }