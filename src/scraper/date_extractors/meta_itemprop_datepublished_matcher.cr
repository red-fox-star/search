# Youtube uses this schema.
# <meta itemprop="datePublished" content="2020-03-11">
class MetaItemPropDatePublishedMatcher < DateExtractorMethod
  include MetaTagExtractorMethod

  def self.meta_matcher(nodes) : Array
    nodes.select(&.attributes["itemprop"]?.== "datePublished").to_a
  end
end
