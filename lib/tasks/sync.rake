namespace :sync do
  task feeds: [:environment] do
    Feed.all.each do |feed|
      content = Feedjira::Feed.fetch_and_parse feed.url
      content.entries.each do |entry|
        local_entry = feed.entries.where(title: entry.title).first_or_initialize

          if local_entry.content.nil?
            response = HTTParty.get("http://api.smmry.com/?&SM_API_KEY=33988A28D7&SM_LENGTH=4&SM_WITH_BREAK&SM_URL=" + entry.url)
            entry.content = response["sm_api_content"]
            local_entry.update_attributes(author: entry.author, url: entry.url, published: entry.published, summary: entry.summary, content: entry.content)
            p "Synced Entry - #{entry.title}"
            p "API Call - #{response["sm_api_content"]}"
            p "Entry Content - #{entry.content}"

            p "API Message - #{response["sm_api_message"]}"
            p "API Error - #{response["sm_api_error"]}"
          else
            p "Synced Title - #{entry.title}"
            p "Synced Content - #{entry.content}"
            p "Synced URL - #{entry.url}"
          end
        end
      p "Synced Feed - #{feed.name}"
    end
  end
end



