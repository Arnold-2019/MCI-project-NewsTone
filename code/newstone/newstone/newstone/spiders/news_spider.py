import scrapy

class NewsSpider(scrapy.Spider):
    name = "crawltitle"
    n_pages = 0

    start_urls = [
        'https://web.archive.org/web/20200318040729/https://www.news.com.au/'
    ]

    def parse(self, response):
        yield {
            'date': response.xpath('//tbody/tr[@class="d"]/td[@class="c"]/@title').re('You are here: (.*)')
        }
        for post in response.css('h4'):
            yield {
                'title': post.css('a::text').get()
            }
        next_page = response.xpath('//tbody/tr[@class="d"]/td[@class="b"]/a/@href').get()
        next_page = response.urljoin(next_page)
        yield scrapy.Request(next_page, callback=self.parse)