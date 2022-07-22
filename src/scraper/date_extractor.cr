require "http/client"
require "lexbor"

require "./date_extractor_method"
require "./date_extractors/meta_tag_extractor_method"
require "./date_extractors/*"

class Scraper::DateExtractor
  Log = ::Log.for(self)

  EXTRACTION_METHODS = [
    CitationOnlineMatcher,
    MetaArticlePublishedMatcher,
    MetaItemPropDatePublishedMatcher,
    GithubDateExtractorMethod,
    LdJsonGraphSchemaMethod,
    RegexMatcher
  ]

  property url : String
  property date : Time

  def initialize(@url)
    @date = Time.utc
    fetch_and_parse
  end

  def fetch_and_parse
    start_time = Time.monotonic
    response_body = fetch
    response_time = Time.monotonic - start_time

    # puts response_body
    parsed_nodes = Lexbor::Parser.new response_body

    extractor = EXTRACTION_METHODS.find do |extractor|
      extractor.matches? parsed_nodes
    end

    raise "no matching extractor" unless extractor
    Log.debug { "#{extractor.name} matched for #{url}" }

    candidate_dates = extractor.extract parsed_nodes

    # pp candidate_dates

    @date = candidate_dates.first
  end

  # todo prevent infinite redirects from ending up in a stackoverflow
  def fetch
    response = if url.starts_with? "https"
      Log.info { "Using ssl fetch on #{url}" }
      HTTP::Client.get url, headers: headers, tls: tls_config
    else
      Log.info { "Using no-ssl fetch on #{url}" }
      HTTP::Client.get url, headers: headers
    end

    if response.status.redirection?
      if (new_url = response.headers["Location"]?) && new_url != url
        @url = new_url
        Log.info { "Successful redirect to #{@url}" }
        fetch
      else
        raise "Redirect but no new url"
      end
    else
      response.body
    end
  end

  def headers
    # cheap/low-quality cloudflare protection requires a user agent which
    # makes it seem like the scraper can parse javascript.
    HTTP::Headers{
      "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:102.0) Gecko/20100101 Firefox/102.0"
    }
  end

  def tls_config
    OpenSSL::SSL::Context::Client.new.tap do |config|
      config.verify_mode = OpenSSL::SSL::VerifyMode::NONE
    end
  end
end
