# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  uid        :string(255)
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
  class << self
    def find_or_create_with_auth_hash!(auth_hash)
      user = find_or_initialize_by(
        uid: auth_hash.uid
      )
      user.token = auth_hash.credentials.token
      user.save!
      user
    end
  end

  def access_token
    client = OAuth2::Client.new(
      ENV['TIMECROWD_APP_ID'],
      ENV['TIMECROWD_SECRET'],
      site: 'https://timecrowd.net',
    )
    OAuth2::AccessToken.new(client, token)
  end

  def time_entries(stopped_at, page)
    access_token.get("/api/v1/time_entries?per_page=100&stopped_at=#{stopped_at}&page=#{page}")
                .parsed
                .map { |item| item.with_indifferent_access }
  end

  def daily_entries
    Rails.cache.fetch("#{cache_key}/daily_entries", expires_in: 5.minutes) do
      daily = []
      page = 0
      stopped_at = Time.current.beginning_of_day.to_i
      loop do
        entries = time_entries(stopped_at, page)
        page += 1
        break if entries.blank?
        my_entries = entries.select { |entry| entry[:user][:id].to_s == uid }
        daily += my_entries
      end
      daily
    end
  end

  def daily_report
    grouped = {}
    daily_entries.each do |entry|
      team = entry[:team][:name]
      category = entry[:task][:category][:title]
      grouped[team] ||= {}
      grouped[team][category] ||= {}
      grouped[team][category][entry[:task][:id]] = {
        title: entry[:task][:title],
        url: entry[:task][:url],
      }
    end
    grouped
  end

  def to_md(link = false, with_category = true)
    md = []
    daily_report.each do |team, categories|
      md << "# #{team}"
      categories.each do |category, tasks|
        md << "## #{category}" if with_category
        tasks.each do |id, task|
          if link
            if task[:url].present?
              md << "- [#{task[:title]}](#{task[:url]})"
            else
              md << "- #{task[:title]}"
            end
          else
            md << "- #{task[:title]}"
          end
        end
      end
      md << ''
    end
    md.join("\n")
  end
end
