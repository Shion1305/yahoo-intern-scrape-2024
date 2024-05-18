require 'nokogiri'
require 'open-uri'
require 'httparty'
require 'dotenv/load'
require 'json'

# スクレイピング対象のURL
url = 'https://www.lycorp.co.jp/ja/recruit/newgrads/internship/engineer/'

html = URI.open(url)

doc = Nokogiri::HTML(html)

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

# 環境変数からNotion APIトークンとデータベースIDを取得
notion_api_token = ENV['NOTION_API_TOKEN']
database_id = ENV['NOTION_DATABASE_ID']

url = "https://api.notion.com/v1/pages"

headers = {
  "Authorization" => "Bearer #{notion_api_token}",
  "Content-Type" => "application/json",
  "Notion-Version" => "2022-06-28"
}

page_properties = {
  "parent" => { "database_id" => database_id },
  "properties" => {
    "Name" => {
      "title" => [
        {
          "text" => {
            "content" => "Tuscan Kale"
          }
        }
      ]
    },
  },
  "children" => [
    {
      "object" => "block",
      "type" => "heading_2",
      "heading_2" => {
        "rich_text" => [{ "type" => "text", "text" => { "content" => "Lacinato kale" } }]
      }
    },
    {
      "object" => "block",
      "type" => "paragraph",
      "paragraph" => {
        "rich_text" => [
          {
            "type" => "text",
            "text" => {
              "content" => "Lacinato kale is a variety of kale with a long tradition in Italian cuisine, especially that of Tuscany. It is also known as Tuscan kale, Italian kale, dinosaur kale, kale, flat back kale, palm tree kale, or black Tuscan palm.",
              "link" => { "url" => "https://en.wikipedia.org/wiki/Lacinato_kale" }
            }
          }
        ]
      }
    }
  ]
}

response = HTTParty.post(url, headers: headers, body: page_properties.to_json)

if response.code == 200
  puts "ページが正常に追加されました: #{response.body}"
else
  puts "エラーが発生しました: #{response.body}"
end
