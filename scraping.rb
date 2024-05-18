require 'nokogiri'
require 'open-uri'

# スクレイピング対象のURL
url = 'https://www.lycorp.co.jp/ja/recruit/newgrads/internship/engineer/'

html = URI.open(url)

doc = Nokogiri::HTML(html)

doc.css('.classname').each do |element|
  puts element.text
end

RecruitInfo = Data.define(:type, :title, :url, :salary, :application_deadline, :term)

recruit_info = {
  "Software Engineer" => [],
  "Security Engineer" => [],
  "Infra Engineer" => [],
  "Data Scientist" => []
}

def process_html(type, doc, selector, recruit_info)
  elements = doc.css(selector)
  # extract salary from the next dt after dd 時給
  elements.each { |e|
    new_info = RecruitInfo.new(
      "Software Engineer",
      e.css('div.title').text.strip,
      e.attr('href'),
      e.css('dl > dt:contains("時給") + dd').text.strip,
      e.css('dl > dt:contains("応募期間") + dd').text.strip,
      e.css('dl > dt:contains("開催期間") + dd').text.strip)
    recruit_info[type].append(new_info)
  }
end

process_html(
  "Software Engineer", doc, 'body > div.global-container > section.job-course.body-container > div > div:nth-child(3) > ul > li > a', recruit_info)
process_html(
  "Security Engineer", doc, 'body > div.global-container > section.job-course.body-container > div > div:nth-child(5) > ul > li > a', recruit_info)
process_html(
  "Infra Engineer", doc, 'body > div.global-container > section.job-course.body-container > div > div:nth-child(7) > ul > li > a', recruit_info)
process_html(
  "Data Scientist", doc, 'body > div.global-container > section.job-course.body-container > div > div:nth-child(9) > ul > li > a', recruit_info)

puts recruit_info