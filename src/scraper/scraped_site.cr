struct Scraper::ScrapedSite
  Log = ::Log.for(self)

  def self.scrape(url) : ScrapedSite
    Log.info { "Scraping #{url}" }

    start = Time.monotonic
    page = FetchedPage.new url
    date_scraper = Scraper::DateExtractor.new page
    text_scraper = Scraper::TextExtractor.new page
    duration = Time.monotonic - start

    Log.info { "Scraped #{url} in #{duration.total_milliseconds}" }

    new url, page, date_scraper, text_scraper, duration
  end

  getter url : String
  getter page : FetchedPage
  getter date_scraper : DateExtractor
  getter text_scraper : TextExtractor
  getter scrape_duration : Time::Span

  delegate date, to: date_scraper
  delegate text, word_count, word_counts, to: text_scraper

  def initialize(
      @url,
      @page,
      @date_scraper,
      @text_scraper,
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

  def to_cache : String
    {
      url: url,
      html: page.body,
      # duration: scrape_duration
    }.to_json
  end

  def self.from_cache(json_string : String) : self
    parsed = JSON.parse(json_string).as_h
    url = parsed["url"].as_s

    Log.info { "Hydrating #{url} from cache" }

    page = FetchedPage.new url, parsed["html"].as_s
    date_scraper = DateExtractor.new page
    text_scraper = TextExtractor.new page

    new url, page, date_scraper, text_scraper, Time::Span.zero
  end
end
