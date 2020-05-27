import scrapy

class PageSpider(scrapy.Spider):
    name = "pagespider"

    start_urls = [
        'https://web.archive.org/web/20200101000000*/news.com.au'
    ]

    def parse(self, response):
        filename = '2020-posts'
        with open(filename, 'wb') as f:
            f.write(response.body)