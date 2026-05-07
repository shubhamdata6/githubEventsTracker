require_relative 'github_events_service'

class Driver
  def self.run
    result = GithubEventsService.new(
      username: "geoffrey",
      days: 90
    ).call

    puts JSON.pretty_generate(result)
  end
end

Driver.run