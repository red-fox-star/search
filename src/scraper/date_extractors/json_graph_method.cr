# <script type="application/ld+json" class="yoast-schema-graph">{"@context":"https://schema.org","@graph":[]}</script>
# {
#  "@context": "https://schema.org",
#  "@graph": [
#    {
#      "@type": "WebPage",
#      "@id": "https://www.gardeningknowhow.com/edible/vegetables/vgen/vegetable-gardening-for-beginners.htm",
#      "url": "https://www.gardeningknowhow.com/edible/vegetables/vgen/vegetable-gardening-for-beginners.htm",
#      "datePublished": "2007-03-11T23:34:27+00:00",
#      "dateModified": "2021-07-01T17:15:12+00:00",
#    },
#  ]
#}

require "json"

class LdJsonGraphSchemaMethod < DateExtractorMethod
  def self.ld_json_tags(parsed_document : Lexbor::Parser) : Array
    matching_tags = parsed_document.nodes(:script)
    matching_tags
      .select(&.attributes["type"]?.==("application/ld+json"))
      .to_a
  end

  def self.schema_graph_tag(parsed_document : Lexbor::Parser)
    ld_json_tags = ld_json_tags parsed_document
    graph_tag = ld_json_tags.compact_map do |tag|
      begin
        parsed = JSON.parse tag.inner_text
      # rescue JSON::ParserError
      #   nil
      end
    end
      .select { |json| json["@context"]? == "https://schema.org" && json["@graph"]? }
      .first["@graph"].as_a
  end

  def self.matches?(parsed_document : Lexbor::Parser) : Bool
    return false unless ld_json_tags(parsed_document).any?
    true
  end

  def extract : Array(Time)
    graph_tag = self.class.schema_graph_tag parsed_document
    return no_match unless graph_tag

    webpage_item = graph_tag.find { |item| item["@type"] == "WebPage" }
    return no_match unless webpage_item

    date = webpage_item["datePublished"].as_s
    if parsed_date = parse_date_regexes date
      [parsed_date]
    else
      no_match
    end
  end
end
