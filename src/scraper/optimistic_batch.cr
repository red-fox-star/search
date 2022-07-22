module Scraper::OptimisticBatch
  def self.fetch(urls : Array(String)) : Array(ScrapedSite)
    cache = Cache.instance

    scraped_sites = [] of ScrapedSite

    urls.each do |url|
      site = cache.scrape url
      scraped_sites << site if site.is_a? ScrapedSite
    end

    scraped_sites
  end
end
