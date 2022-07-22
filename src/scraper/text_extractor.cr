class Scraper::TextExtractor
  getter text : String
  getter word_count : Int32
  getter word_counts = Hash(String,Int32).new {|k| 0 }

  def initialize(@page : FetchedPage)
    # direct copy from https://github.com/kostya/lexbor/blob/master/examples/texts.cr
    @text = page.parsed_body
      .nodes(:_text)                         # iterate through all TEXT nodes
      .select(&.parents.all?(&.visible?))    # select only nodes which are visible
      .map(&.tag_text)                       # mapping node text
      .reject(&.blank?)                      # reject blanked texts
      .map(&.strip.gsub(/\s{2,}/, " "))      # remove extra spaces
      .join(" ")                             # join all texts into one string

    words = @text.downcase.split
    @word_count = words.size

    words.each do |word|
      @word_counts[word] += 1
    end
  end
end
