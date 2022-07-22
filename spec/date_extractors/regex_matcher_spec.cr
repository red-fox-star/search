require "lexbor"
require "../spec_helper"

describe RegexMatcher do
  it "always matches" do
    RegexMatcher.matches?(Lexbor::Parser.new("")).should be_true
  end

  it "parses out a date" do
    metadata_html = Lexbor::Parser.new(<<-HTML)
    <html>
      <head>
      </head>
      <body>
        <p>Not a date 2021</p>
        <p>2021, Not the right date</p>
        <p>1021-02-02 Not the right date</p>
        <!-- the right date -->
        <p>2022-02-02</p>
      </body>
    </html>
    HTML

    RegexMatcher.extract(metadata_html).should eq [Time.utc(2022, 2, 2, 0, 0, 0)]
  end
end

