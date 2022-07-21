struct Scraper::ScrapedSite
  Log = ::Log.for(self)

  def self.scrape(url) : ScrapedSite
    Log.info { "Scraping #{url}" }

    start = Time.monotonic
    page = FetchedPage.new url
    date_scraper = Scraper::DateExtractor.new page
    duration = Time.monotonic - start

    Log.info { "Scraped #{url} in #{duration.total_milliseconds}" }

    new url, date_scraper, duration
  end

  getter url : String
  getter date_scraper : DateExtractor
  getter scrape_duration : Time::Span

  delegate date, to: date_scraper

  def initialize(
      @url,
      @date_scraper,
      @scrape_duration)
  end

  def to_json
    {
      "@type": "ScrapedSite",
      url: url,
      date: format_nilable_date(date),
      duration: "#{scrape_duration.total_milliseconds.format(decimal_places: 3)}ms"
    }.to_json
  end
end
