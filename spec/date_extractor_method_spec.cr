class ConcreteExtractor < DateExtractorMethod
  def initialize(@parsed_document)
  end

  def initialize()
    @parsed_document = Lexbor::Parser.new ""
  end

  def self.matches?(parsed_document : Lexbor::Parser) : Bool
    true
  end

  def extract : Array(Time)
    [Time.utc]
  end
end

def correct_time
  Time.utc(2012, 1, 1, 0, 0)
end

describe DateExtractorMethod do
  describe "date_regexes" do
    it "recognizes yyyy-mm-dd" do
      text = "2012-01-01"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes dd-mm-yyyy" do
      text = "01-01-2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes mon yyyy" do
      text = "jan 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes month yyyy" do
      text = "january 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time

      text = "January 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes year mon" do
      text = "2012 jan"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time

      text = "2012 Jan"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes year month" do
      text = "2012 january"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time

      text = "2012 January"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes mon dd, yyyy" do
      text = "jan 01, 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time

      text = "Jan 01, 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end

    it "recognizes month dd, yyyy" do
      text = "january 01, 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time

      text = "January 01, 2012"
      ConcreteExtractor.new.parse_date_regexes(text).should eq correct_time
    end
  end
end
