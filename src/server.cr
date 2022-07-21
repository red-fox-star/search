require "kemal"
require "json"

require "./scraper"

def format_nilable_date(date : Time?)
  if date.nil?
    "-"
  else
    date.to_s("%Y-%m-%d")
  end
end

SiteLog = ::Log.for("site")

get "/" do
  render "src/views/search.html.ecr", "src/views/layout.html.ecr"
end

get "/search" do |env|
  urls = env.params.query["urls"]
    .split("\n")
    .map(&.strip)
    .reject(&.blank?)

  start_time = Time.utc.to_unix_ms
  scraped_sites = [] of Scraper::ScrapedSite

  # Pull any relevant urls from cache, let the rest get scraped in background
  Scraper::OptimisticBatch.scrape(urls).each do |site|
    urls.delete site.url
    scraped_sites << site
  end

  render "src/views/results.html.ecr", "src/views/layout.html.ecr"
end

ws "/results" do |socket|
  socket.on_message do |message|
    parsed = JSON.parse(message).as_h

    next unless parsed["type"]? == "urls"
    urls = parsed["urls"].as_a.map(&.as_s)
    Log.info { "Search is waiting on: #{urls.size} responses" }
    index = 0

    loop do
      break if urls.empty?
      if index >= urls.size
        index = 0
        sleep 0.1
      end

      url = urls[index]

      case site = Scraper::Cache.scrape url
      when Scraper::PendingScrape
        index += 1
      when Scraper::ScrapedSite
        socket.send site.to_json
        urls.delete_at index
        index = 0 if index > urls.size - 1
      else
        Log.info { "got a #{url.inspect}" }
      end
    end

    socket.send(
      {"@type": "Finished", "time": Time.utc.to_unix_ms}.to_json
    )
  end

  socket.on_close do
  end
end

Kemal.run
