# frozen_string_literal: true

class NotionDB
  def initialize
    Dotenv.load
    @notion_api_token = ENV['NOTION_API_TOKEN']
    @database_id = ENV['NOTION_DATABASE_ID']
    @url = 'https://api.notion.com/v1/pages'
    @headers = {
      "Authorization" => "Bearer #{@notion_api_token}",
      "Content-Type" => "application/json",
      "Notion-Version" => "2022-06-28"
    }
  end
end

# Position: MultiSelect from Software, Security, Infra, Data
# Position Name: Text
# Start Date: Date
# End Date: Date
# Weeks: number
class RecruitPageInfo
  def initialize(db_id)
    @db_id = db_id
  end

  def page_info(
    position,
    position_name,
    start_date,
    end_date,
    weeks
  )
    {
      "parent" => { "database_id" => @db_id },
      "properties" => {
        "Position" => {
          "multi_select" => [
            {
              "name" => position
            }
          ]
        },
        "Position Name" => {
          "title" => [
            {
              "type": "text",
              "text" => {
                "content" => position_name,
                "link" => nil
              }
            }
          ]
        },
        "Start Date" => {
          "date" => {
            "start" => start_date
          }
        },
        "End Date" => {
          "date" => {
            "start" => end_date
          }
        },
        "Weeks" => {
          "number" => weeks
        }
      },
      "children" => []
    }
  end
end