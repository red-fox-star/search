require "http/client"
require "lexbor"

require "./date_extractor_method"
require "./date_extractors/meta_tag_extractor_method"
require "./date_extractors/*"

class Scraper::DateExtractor
  Log = ::Log.for(self)

  EXTRACTION_METHODS = [
    # quick and easy methods
    CitationOnlineMatcher,
    MetaArticlePublishedMatcher,
    MetaItemPropDatePublishedMatcher,
    GithubDateExtractorMethod,

    # more difficult methods
    LdJsonGraphSchemaMethod,
    RegexMatcher
  ]

  property date : Time?
  private getter page : FetchedPage

  def initialize(@page)
    @date = look_for_date
  end

  def look_for_date : Time?
    extractor = EXTRACTION_METHODS.find do |extractor|
      extractor.matches? page.parsed_body
    end

    if extractor.nil?
      Log.warn { "no extractor found for #{page.url}" }
      return nil
    end

    Log.debug { "#{extractor.name} matched for #{page.url}" }

    candidate_dates = extractor.extract page.parsed_body

    if candidate_dates.empty?
      Log.warn { "no dates found for #{page.url}" }
    else
      candidate_dates.first
    end
  end
end
