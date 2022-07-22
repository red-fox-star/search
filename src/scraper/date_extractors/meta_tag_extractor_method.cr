module MetaTagExtractorMethod
  module ClassMethods
    abstract def meta_matcher(nodes) : Array

    def meta_tag(parsed_document : Lexbor::Parser) : Lexbor::Node?
      matching_tags = meta_matcher parsed_document.nodes(:meta)

      return nil unless matching_tags && matching_tags.size > 0
      matching_tags.first
    end

    def matches?(parsed_document : Lexbor::Parser) : Bool
      return false unless meta_tag(parsed_document)
      true
    end
  end

  macro included
    extend ClassMethods
  end

  def extract : Array(Time)
    return no_match unless tag = self.class.meta_tag(parsed_document)
    return no_match unless candidate_date = tag.attributes["content"]?

    dates = [] of Time
    match = parse_date_regexes candidate_date
    dates << match if match
    dates
  end
end

