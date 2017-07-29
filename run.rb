require 'docx'
require 'mechanize'
require 'json'
require 'pry'
require 'watir'

# http://www.vcaa.vic.edu.au/Pages/foundation10/viccurriculum/english/englishcmt.aspx
# download docx matching year

class DocsRepo
  def initialize()
    @docs = JSON.parse(File.read("docs.json"))
  end

  def get_doc(filename)
    doc = @docs[filename] ||= load_doc(filename)
    save
    doc
  end

  def load_doc(filename)
    doc = Docx::Document.open(filename);
    {
      "filename"=>filename,
      "links"=> doc.links.map{ |l|
        {
          "url"=>l.url,
          "name"=>l.node.text
        }
      }
    }
  end

  def save()
    File.write("docs.json", @docs.to_json)
  end
end

class FuseLinkRepo
  def initialize(browser)
    @fuse_links = JSON.parse(File.read("fuse_links.json"))
    @browser = browser
    @a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
  end

  def save
    File.write("fuse_links.json", @fuse_links.to_json)
  end

  def get_fuse_links(fuse_link)
    url = fuse_link["url"]
    fuse_links = @fuse_links[url] ||= load_fuse_links(url)
    save
    fuse_links
  end

  def load_fuse_links(url)
    begin
      x = @a.get(url)
      fuse_link = x.links.find{|l| l.text == "FUSE"}
      @browser.goto fuse_link.href;
      sleep 2
      pages = @browser.links.select{|l| l.attribute_value("class") =~ /card-description-header-link/ };
      pages.map{|p| p.href};
    rescue
      []
    end
  end
end

class CodesRepo
  def initialize(browser)
    @codes = JSON.parse(File.read("codes.json"))
    @browser = browser
  end

  def save
    File.write("codes.json", @codes.to_json)
  end

  def get_codes(link)
    codes = @codes[link] ||= get_codes_and_title(link)
    save
    codes
  end

  def get_codes_and_title(ref)
    begin
      @browser.goto ref;
      #expand details

      @browser.element(:xpath=>"//*[@id=\"MoreDetailsHeading\"]/span" ).click
      sleep 1
      codes = @browser.tables[0].rows[2].cells[1].lis.to_a.map{|t| t.spans.last.text}
      title = @browser.element(:xpath =>"//*[@id=\"bodyContent\"]/div[1]/div[1]/div[1]/div[2]/h1").text
      {"title"=>title,"codes"=> codes}
    rescue
      {"title"=>'error', "codes"=> []}
    end
  end
end

@browser = Watir::Browser.new :chrome
@docs = DocsRepo.new
@fuse_links = FuseLinkRepo.new @browser
@codes = CodesRepo.new @browser


def render_html(filename)
  output = "<h2>#{filename}</h2>\n"
  links = @docs.get_doc(filename)["links"]
  links.each do |link|
    flinks = @fuse_links.get_fuse_links(link)
    output +=  "\t<a href=\"#{link["url"]}\">#{link["name"]}</a> #{flinks.count} <ul>\n"
    flinks.each do |fuse_link|
      page = @codes.get_codes(fuse_link)
      title = page["title"]
      codes = page["codes"]
      output += "\t\t<li><a href=\"#{fuse_link}\">#{title}</a> - #{codes.inspect} </li>\n"
    end
    output += "</ul>\n"
  end
  output
end

filename = ARGV[0]
doc = @docs.get_doc(filename)

links = doc["links"]
fuse_links = links.map{|link| @fuse_links.get_fuse_links(link) }.flatten.uniq
fuse_links.each{|link| @codes.get_codes(link)}



puts "<h1>Year 9</h1>"
puts render_html(filename)

#


@browser.quit


__END__

#links = doc.doc.xpath("//*[contains(text(),'VCEL')]/..")

# require 'upton'

# scraper = Upton::Scraper.new("http://www.propublica.org", "section#river h1 a")
# scraper.scrape_to_csv "output.csv" do |html|
#   Nokogiri::HTML(html).search("#comments h2.title-link").map &:text
# end

cells = doc.tables[0].rows[2].cells
doc.tables[1].rows[2].cells



n = doc.doc.xpath("//*[contains(text(),'VCEL')]/..").first;
cell = n.parent.parent.parent;
row = cell.parent;
headings_row = row.previous;
headings_row.children.map{|c| c.text}


p_element.xpath("//child::*")


first_table = doc.tables[0]
puts first_table.row_count
puts first_table.column_count
puts first_table.rows[0].cells[0].text
puts first_table.columns[0].cells[0].text

# Iterate through tables
doc.tables.each do |table|
  table.rows.each do |row| # Row-based iteration
    row.cells.each do |cell|
      puts cell.text
    end
  end

  table.columns.each do |column| # Column-based iteration
    column.cells.each do |cell|
      puts cell.text
    end
  end
end