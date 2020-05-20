import scrapy

class NewsSpider(scrapy.Spider):
    name = "titlespider"

    start_urls = [
        'https://web.archive.org/web/20100207225621/http://www.news.com.au/'
    ]

    def parse(self, response):
        date = response.xpath('//tbody/tr[@class="d"]/td[@class="c"]/@title').re('You are here: [0-9][0-9]:[0-9][0-9]:[0-9][0-9] (.*)')
        date = date[0]
        year = date[8:12]
        month = date[0:3]
        M = {'Jan':'01', 'Feb':'02', 'Mar':'03', 'Apr':'04', 'May':'05', 'Jun':'06',
             'Jul':'07', 'Aug':'08', 'Sep':'09', 'Oct':'10', 'Nov':'11', 'Dec':'12'
        }
        month = M[month]
        day = date[4:6]
        date = year + month + day
        for post in response.css('h4'):
            yield {
                'date': date,
                'year': year,
                'month': month,
                'day': day,
                'title': post.css('a::text').get()
            }
        next_page = response.xpath('//tbody/tr[@class="d"]/td[@class="b"]/a/@href').get()
        next_page = response.urljoin(next_page)
        yield scrapy.Request(next_page, callback=self.parse)