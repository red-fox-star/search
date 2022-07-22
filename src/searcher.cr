class Searcher
  Log = ::Log.for self

  def self.document_frequency(word : String) : Float64
    matched_documents = 0

    Scraper::Cache.instance.each do |page|
      if page.word_counts[word] > 0
        matched_documents += 1
      end
    end

    Math.log10(
      Scraper::Cache.instance.size.to_f / matched_documents
    )
  end

  def self.query_words(query : String)
    query.split
      .map(&.strip.downcase)
      .reject(&.blank?)
  end

  getter terms : Array(String)
  getter delayed_pages : Array(Scraper::PendingScrape) = [] of Scraper::PendingScrape
  getter ready_results : Array(SearchResult) = [] of SearchResult

  def initialize(@query : String, @urls : Array(String))
    @terms = self.class.query_words @query

    # todo: this asssumes the pages are already in the cache
    pages = @urls.map { |url| Scraper::Cache.fetch url }
    pages.each do |page|
      case page
      when Scraper::PendingScrape
        delayed_pages << page
      when Scraper::ScrapedSite
        ready_results << SearchResult.new(@terms, page)
      end
    end
  end

  def ranked_results : Array(SearchResult)
    ready_results
      .select(&.rank.positive?)
      .sort_by { |result| result.rank }.reverse
  end
end

class SearchResult
  Log = ::Log.for(self)

  getter rank : Float64

  def initialize(terms : Array(String), @page : Scraper::ScrapedSite)
    document_frequencies = {} of String => Float64
    terms.each do |term|
      document_frequencies[term] = Searcher.document_frequency term
    end

    @rank = terms.map do |word|
      frequency = page.word_counts[word] / page.word_count
      tfidf = frequency / document_frequencies[word]
    end.sum
  end

  delegate date, url, to: @page

  def excerpt : String
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
  end
end
