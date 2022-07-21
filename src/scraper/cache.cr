class Scraper::Cache
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
