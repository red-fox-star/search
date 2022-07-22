require "lexbor"
require "../spec_helper"

describe CitationOnlineMatcher do
  it "matches when the metadata tag is present" do
    metadata_html = Lexbor::Parser.new(<<-HTML)
    <meta name="citation_online_date" content="2022-02-02" />
    HTML

    CitationOnlineMatcher.matches?(metadata_html).should be_true
  end

  it "parses out the date correctly" do
    metadata_html = Lexbor::Parser.new(<<-HTML)
    <meta name="citation_online_date" content="2022-02-02" />
    HTML

    CitationOnlineMatcher.extract(metadata_html).should eq [Time.utc(2022, 2, 2, 0, 0, 0)]
  end
end
