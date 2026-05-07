# Github Events Tracker
A Ruby service object to fetch and analyze GitHub public events for a user within a given timeframe.

## Features

- Fetch GitHub public events
- Filter events by number of days
- Optimized pagination with early stopping
- Group events repository-wise
- Detect repository ownership
- Get top 3 event types per repository

---

## Installation

Add gem:

```ruby
gem 'httparty'
```

Run:

```bash
bundle install
```

---

## Usage

```ruby
GithubEventsService.new(
  username: "geoffrey",
  days: 30
).call
```

---

## Example Response

```ruby
[
  {
    repo_name: "rails/rails",
    owned: false,
    total_events: 25,
    top_3_events: {
      "PushEvent" => 12,
      "PullRequestEvent" => 8,
      "IssueCommentEvent" => 5
    }
  }
]
```

---

## Notes

- Uses GitHub Public Events API
- Events are fetched page-by-page
- Stops API calls once events become older than requested timeframe
- Supports only public GitHub events