

# year 9
# browse to "http://fuse.education.vic.gov.au/Search/Results?AssociatedPackageId=&QueryText=&SearchScope=All"
# visit all pages getting links to videos

require 'watir'
require 'pry'

class Session
    def initialize(browser)
        @browser = browser
    end

    def visit(url)
        @browser.goto url
    end

    def has_more_pages?
        count != total
    end

    def count
        @browser.element(xpath:'//*[@id="filter-sticky--disabled"]/div/div[2]/div[1]/div[1]/div/span[2]').text.to_i
    end

    def total
        @browser.element(xpath:'//*[@id="filter-sticky--disabled"]/div/div[2]/div[1]/div[1]/div/span[3]').text.to_i
    end

    def scrape_page
        #@browser.elements(xpath:'//*[@id="Search-results"]/div[2]/form/div[2]/ul/li[94]/div[2]/div[1]/a/span')
    end


    def load_more
        @browser.element(xpath:'//*[@id="Search-results"]/div[2]/form/div[2]/div/a').click
    end
end

@browser = Watir::Browser.new :chrome

binding.pry

s = Session.new @browser
s.visit("http://fuse.education.vic.gov.au/Search/Results?AssociatedPackageId=&QueryText=&SearchScope=All")
sleep 4
while s.has_more_pages?
    sleep 2
    s.load_more
end
s.scrape_page

