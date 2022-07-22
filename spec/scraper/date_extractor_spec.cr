require "../spec_helper"

describe Scraper::DateExtractor do
  working_links = {
    "https://www.caranddriver.com/reviews/a21786823/2019-audi-q8-first-drive-review/" => "2018/06/26",
    "https://www.cnn.com/2020/03/12/opinions/oval-office-coronavirus-speech-trumps-worst-bergen/index.html" => "2020/03/12",
    # nytimes article says 3/11/2020 but meta published says 3/12/2020, I'm not sure what to give priority to
    "https://www.nytimes.com/2020/03/11/us/politics/trump-coronavirus-speech.html" => "2020/03/12",
    "https://www.sciencedirect.com/science/article/pii/S1319157819301259" => "2019/12/07",
    "https://www.analyticsvidhya.com/blog/2019/06/comprehensive-guide-text-summarization-using-deep-learning-python/" => "2019/06/10",
    "https://www.topgear.com/car-reviews/audi/q8" => "2018/08/24",
    "https://www.youtube.com/watch?v=mii6NydPiqI" => "2020/03/11",

    # the expected date for this article is 2014/04/11, but both article date
    # on page and meta:published shows 2019/06/20
    "https://lifehacker.com/the-seven-easiest-vegetables-to-grow-for-beginner-garde-1562176780" => "2019/06/20",
    # date on page, meta:published May 6, 2021
    "https://gardenerspath.com/how-to/beginners/first-vegetable-garden/" => "2021/05/06",

    # the expected date for this article is "2019/08/03", but:
    # - the commit date for the most recent commit is "2020/02/02"
    # - the copyright year is 2018
    "https://github.com/mbadry1/DeepLearning.ai-Summary" => "2020/02/02",

    # the expected date for this article is "2017/11/29", but meta published say a day earlier
    "https://machinelearningmastery.com/gentle-introduction-text-summarization/" => "2017/11/28",
  }

  links = {
    # gardening know how is protected by cloudflare, needs user agent hack
    # expected date on this article is 2018/01/12
    # the json graph date is 2007-03-11, and no other date is on the page.
    "https://www.gardeningknowhow.com/edible/vegetables/vgen/vegetable-gardening-for-beginners.htm" => "2007/03/11",
  }

  links.merge! working_links

  links.each do |link, date|
    it "extracts date from #{link}" do
      extractor = Scraper::DateExtractor.new link
      extractor.date.should be_a Time
      extractor.date.to_s("%Y/%m/%d").should eq date
    end
  end
end
