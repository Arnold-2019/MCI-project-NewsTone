import scrapy

class NewsSpider(scrapy.Spider):
    name = "crawlurls"
    n_pages = 0

    start_urls = [
        'https://web.archive.org/web/20200317015337/http://news.com.au/'
    ]

    def parse(self, response):
        global n_pages
        next_page = response.xpath('//tbody/tr[@class="d"]/td[@class="b"]/a/@href').get()
        yield {
            'url': next_page
        }
        next_page = response.urljoin(next_page)
        yield scrapy.Request(next_page, callback=self.parse)