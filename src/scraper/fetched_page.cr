struct Scraper::FetchedPage
  getter http_fetch_time : Time::Span
  getter html_parse_time : Time::Span

  getter url : String
  getter body : String
  getter parsed_body : Lexbor::Parser

  def initialize(@url : String)
    @body = ""
    @parsed_body = Lexbor::Parser.new("")

    @http_fetch_time = Time.measure do
      @body = body = fetch
    end

    @html_parse_time = Time.measure do
      @parsed_body = Lexbor::Parser.new body
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

  # todo better prevent infinite redirects from ending up in a stackoverflow
  def fetch : String
    response = if url.starts_with? "https"
      HTTP::Client.get url, headers: headers, tls: tls_config
    else
      HTTP::Client.get url, headers: headers
    end

    if response.status.redirection?
      if (new_url = response.headers["Location"]?) && new_url != url
        @url = new_url
        Log.warn { "Successful redirect to #{@url}" }
        fetch
      else
        raise "Redirect without new url"
      end
    else
      response.body
    end
  end

end
