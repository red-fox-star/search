abstract class DateExtractorMethod
  abstract def extract : Array(Time)

  module ClassMethods
    abstract def matches?(parsed_document : Lexbor::Parser) : Bool

    def extract(parsed_document : Lexbor::Parser) : Array(Time)
      new(parsed_document).extract
    end
  end

  macro inherited
    extend ClassMethods
  end

  @[AlwaysInline]
  def no_match : Array(Time)
    [] of Time
  end

  getter parsed_document : Lexbor::Parser
  def initialize(@parsed_document)
  end

  def debug(*args)
    # puts *args
  end

  def parse_date_regexes(text : String) : Time?
    debug "checking #{text} for match"

    year = "(19\\d{2}|20\\d{2})"
    month = "(0?[1-9]|1[012])"
    abbv_month = "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\.?"
    full_month = "(January|February|March|April|May|June|July|August|September|October|November|December)"
    day = "
      (
        0?[1-9]                  # match a single digit day, with or without a leading zero
        (?:                      #   non-capturing group
          (?!\\d)                #     ensure that the digit is not followed by another digit
          | $)                   #     or it's ok if the single digit is at the end of the string
        | [12][0-9]              # or match a two digit day in the tens or twenties
        | 3[01]                  # or match the 30/31
     )
    "

    sep = "[-\/\. ]"

    case text
    when /#{year}#{sep}#{month}#{sep}#{day}/x # yyyy-mm-dd
      debug "matched yyyy-mm-dd: #{$~}"
      year = $~[1].to_i
      month = $~[2].to_i
      day = $~[3].to_i
      Time.utc year, month, day, 0, 0, 0

    when /#{day}#{sep}#{month}#{sep}#{year}/x # dd-mm-yyyy
      debug "matched dd-mm-yyyy"
      day = $~[1].to_i
      month = $~[2].to_i
      year = $~[3].to_i
      Time.utc year, month, day, 0, 0, 0

    when /(#{abbv_month}#{sep}#{year})/ix           # mon yyyy
      debug "matched mon year"
      Time.parse $~[1], "%b %Y", Time::Location::UTC

    when /(#{full_month}#{sep}#{year})/ix           # month yyyy
      debug "matched month year"
      Time.parse $~[1], "%B %Y", Time::Location::UTC

    when /(#{year}#{sep}#{abbv_month})/ix           # year mon
      debug "matched year mon"
      Time.parse $~[1], "%Y %b", Time::Location::UTC

    when /(#{year}#{sep}#{full_month})/ix           # year month
      debug "matched year month"
      Time.parse $~[1], "%Y %B", Time::Location::UTC

    when /(#{abbv_month}#{sep}#{day},#{sep}#{year})/ix  # mon dd, yyyy
      debug "matched mon dd, yyyy"
      Time.parse $~[1], "%b %d, %Y", Time::Location::UTC

    when /(#{full_month}#{sep}#{day},#{sep}#{year})/ix  # month dd, yyyy
      debug "matched month dd, yyyy: #{$~[1]}"
      t = Time.parse $~[1], "%B %d, %Y", Time::Location::UTC
      debug t
      t
    else
      debug "no match"
      nil
    end
  rescue e
    pp e
    nil
  end
end
