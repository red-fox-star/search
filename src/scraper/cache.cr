class Scraper::Cache
  Log = ::Log.for(self)
  getter data = {} of String => Site

  def self.instance
    @@instance ||= new
  end

  def self.fetch(url)
    instance.scrape(url)
  end

  def store(url : String, site : Site) : Site
    data[url] = site

    {% if flag?(:persistent_cache) %}
      spawn do
        if site.is_a? ScrapedSite
          PersistentCache.i.set url, site.to_cache
        end
      end
    {% end %}

    site
  end

  def each
    data.each do |url, entry|
      if entry.is_a? ScrapedSite
        yield entry
      else
        Log.warn { "Cache entry #{entry.class} is not a ScrapedSite" }
      end
    end
  end

  def size
    data.select { |_, entry| entry.is_a? ScrapedSite }.size
  end

  def scrape(url : String) : Site
    case site = data[url]?
    when PendingScrape
      Log.info { "Site pending fetch for #{url}" }
      site
    when ScrapedSite
      Log.info { "Cache hit for #{url}" }
      site
    else
      persistent_lookup url
    end
  end

  private def persistent_lookup(url : String) : Site
    Log.info { "Hard miss for #{url}" }

    site = store url, PendingScrape.new

    spawn do
      store url, ScrapedSite.scrape(url)
      Log.info { "Finished scraping #{url}" }
    end

    site
  end


  {% if flag?(:persistent_cache) %}

    private def persistent_lookup(url : String) : Site
      if cached_page = PersistentCache.i.get url
        Log.info { "Soft miss for #{url}" }
        store url, ScrapedSite.from_cache(cached_page)
      else
        previous_def
      end
    end

  {% end %}
end
