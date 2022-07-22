class RegexMatcher < DateExtractorMethod
  def self.matches?(parsed_document : Lexbor::Parser) : Bool
    true # regex matcher can always try
  end

  def extract : Array(Time)
    # adapted from the lexbor examples
    text_nodes = parsed_document
      .nodes(:_text)                         # iterate through all TEXT nodes
      .select(&.parents.all?(&.visible?))    # select only which parents are visible good tag
      .map(&.tag_text)                       # mapping node text
      .to_a

    text_nodes.sort_by(&.size)
      # .tap { |dates| puts "RegexMatcher found: #{dates.inspect}" }
      # .sort_by(&.size)                       # select only which are less than 30 chars, to avoid dates
                                             # in the middle of paragraphs. Looking for something like:
                                             # "published on december 30, 2020"
      .select(&.matches?(/(19|20)\d{2}/))    # select only texts which can have a four digit year
      .map(&.strip.gsub(/\s{2,}/, " "))      # remove extra spaces
      # .tap { |dates| puts "RegexMatcher found: #{dates.inspect}" }
      .compact_map { |word| parse_date_regexes word }
      # .tap { |dates| puts "RegexMatcher parsed: #{dates.inspect}" }
      .to_a
  end
end
