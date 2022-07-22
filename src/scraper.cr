require "./scraper/*"

module Scraper
  alias Site = ScrapedSite | PendingScrape

  struct PendingScrape
  end

  struct ScrapedSite
    Log = ::Log.for(self)

    def self.scrape(url) : ScrapedSite
      Log.info { "Scraping #{url}" }

      start = Time.monotonic
      date_scraper = Scraper::DateExtractor.new url
      duration = Time.monotonic - start
      date = date_scraper.date
      Log.info { "Scraped #{url} in #{duration.total_milliseconds}" }

      new url, date, duration
    end

    getter url : String
    getter! date : Time
    getter! duration : Time::Span

    def initialize(@url, @date, @duration)
    end

    def to_json
      {
        "@type": "ScrapedSite",
        url: url,
        date: date.to_s("%Y-%m-%d"),
        duration: "#{duration.total_milliseconds.format(decimal_places: 3)}ms"
      }.to_json
    end
  end

  class Cache
    Log = ::Log.for(self)
    getter data = {} of String => Site

    def self.instance
      @@instance ||= new
    end

    def self.scrape(url)
      instance.scrape(url)
    end

    def store(url : String, site : Site) : Site
      data[url] = site
    end

    def scrape(url : String) : Site
      case site = data[url]?
      when ScrapedSite
        Log.info { "Cache hit for #{url}" }
        site
      when PendingScrape
        Log.info { "Site pending fetch for #{url}" }
        site
      else
        Log.info { "Cache miss for #{url}" }
        site = store url, PendingScrape.new

        spawn do
          store url, ScrapedSite.scrape(url)
          Log.info { "Finished scraping #{url}" }
        end

        site
      end
    end
  end

  class OptimisticBatch
    def self.scrape(urls : Array(String)) : Array(ScrapedSite)
      cache = Cache.instance

      scraped_sites = [] of ScrapedSite

      urls.each do |url|
        site = cache.scrape url
        scraped_sites << site if site.is_a? ScrapedSite
      end

      scraped_sites
    end
  end
end
