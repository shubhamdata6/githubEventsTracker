require 'httparty'
require 'json'
require 'time'

class GithubEventsService
  BASE_URL = "https://api.github.com"

  def initialize(username:, days:)
    @username = username
    @days = days

    # Define the timeframe for filtering events
    @from_time = Time.now - (days * 24 * 60 * 60)
    @to_time = Time.now
  end

  # Main entry point of service
  def call
    events = fetch_events

    grouped_events = group_events_by_repo(events)

    build_response(grouped_events)
  end

  private

  attr_reader :username, :days, :from_time, :to_time

  # Fetching paginated GitHub public events
  def fetch_events
    page = 1
    all_events = []

    loop do
      response = HTTParty.get(
        "#{BASE_URL}/users/#{username}/events/public",
        headers: headers,
        query: {
          per_page: 100,
          page: page
        }
      )

      events = JSON.parse(response.body)

      # Stop if no more events available
      break if events.empty?

      should_stop_fetching = false

      events.each do |event|
        created_at = Time.parse(event["created_at"])

        # Since events are ordered latest -> oldest,
        # stop fetching once event exceeds timeframe
        if created_at < from_time
          should_stop_fetching = true
          break
        end

        all_events << event
      end

      break if should_stop_fetching

      page += 1
    end

    all_events
  end

  # Group events repository-wise
  def group_events_by_repo(events)
    events.group_by do |event|
      event["repo"]["name"]
    end
  end

  # Build final formatted response
  def build_response(grouped_events)
    grouped_events.map do |repo_name, repo_events|
      owner_name = repo_name.split("/").first

      {
        repo_name: repo_name,

        # Check whether repository belongs to given user
        owned: owner_name.downcase == username.downcase,

        total_events: repo_events.count,

        # Get top 3 most frequent event types
        top_3_events: top_event_types(repo_events)
      }
    end
  end

  # Count and sort event types by frequency
  def top_event_types(events)
    events
      .map { |event| event["type"] }
      .tally
      .sort_by { |_event_type, count| -count }
      .first(3)
      .to_h
  end

  # Common request headers
  def headers
    {
      "Accept" => "application/vnd.github+json"
    }
  end
end