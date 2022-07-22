# css matcher: div.Box-header relative-time
class GithubDateExtractorMethod < DateExtractorMethod
  def self.time_tag(parsed_document : Lexbor::Parser) : Lexbor::Node?
    matching_tags = parsed_document.css("div.Box-header relative-time")
    return nil unless matching_tags && matching_tags.size > 0
    matching_tags.first
  end

  def self.matches?(parsed_document : Lexbor::Parser) : Bool
    return false unless time_tag(parsed_document)
    true
  end

  def extract : Array(Time)
    return no_match unless tag = self.class.time_tag(parsed_document)
    return no_match unless candidate_date = tag.inner_text

    dates = [] of Time
    match = parse_date_regexes candidate_date
    dates << match if match
    dates
  end
end
