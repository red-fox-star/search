require "http/client"
require "lexbor"

require "./scraper/*"

module Scraper
  alias Site = ScrapedSite | PendingScrape
end
