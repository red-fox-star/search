# Wordpress uses this schema.
# NYT uses this schema.
# <meta property="article:published_time" content="2019-06-10T03:33:04+00:00">
class MetaArticlePublishedMatcher < DateExtractorMethod
  include MetaTagExtractorMethod

  def self.meta_matcher(nodes) : Array
    nodes.select(&.attributes["property"]?.== "article:published_time")
         .to_a
  end
end
