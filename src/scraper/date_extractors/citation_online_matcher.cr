# "The Google Scholar Schema."
# http://div.div1.com.au/div-thoughts/div-commentaries/66-div-commentary-metadata#_additional-comments-citation-namespace
# https://pkg.garrickadenbuie.com/metathis/reference/meta_google_scholar.html
# <meta name="citation_online_date" content="2019/12/07">
class CitationOnlineMatcher < DateExtractorMethod
  include MetaTagExtractorMethod

  def self.meta_matcher(nodes) : Array
    nodes.select(&.attributes["name"]?.== "citation_online_date").to_a
  end
end
