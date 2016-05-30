require 'capybara/poltergeist'

# Web scraping with Capybara, Phantom.js and Poltergeist
class WebCrawler
  attr_reader :products

  def initialize
    @products = []
  end

  def crawl(url)
    config_capybara
    @browser = Capybara.current_session
    main_links = main_page_links(url)
    click_on_links_and_get_data(main_links)
  end

  private

  def config_capybara
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.default_driver = :poltergeist
    Capybara.default_selector = :xpath
  end

  def main_page_links(url)
    @browser.visit url
    @browser.all("//ul[@class='level_2']/li/a").map { |l| l['href'] }
  end

  def click_on_links_and_get_data(main_page_links)
    main_page_links.each do |link|
      @browser.visit link
      collect_data(@browser.all("//div[@class='shortDescription']"))
      sleep(3.0 + rand)
    end
  end

  def collect_data(data)
    data.each do |description|
      product = {}

      keys = description.all('.//strong').map { |k| k.text.strip.delete(':') }
      values = values(keys, description)

      keys.each_with_index { |key, num| product[key] = values[num + 1] }
      @products << product
    end
  end

  def values(keys, description)
    raw_text = description.text.sub(' Detailsightsubmit request', '')
    keys.each { |k| raw_text.sub!(k, '') }
    raw_text.split(':').map(&:strip)
  end
end

stuerzer = WebCrawler.new
stuerzer.crawl('http://stuerzer.de/index.php/home-en.html')
puts stuerzer.products
