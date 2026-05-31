# Hackernews

A terminal-based UI for reading Hacker News, built with Charming.

Browse top, new, best, ask HN, show HN, and jobs feeds from your terminal. Open articles inline, navigate with a familiar Vim-inspired keyboard layout, and style it with any of the built-in Charming themes.

## Features

- **6 feed tabs** — Top, New, Best, Ask HN, Show HN, Jobs
- **Story cards** with rank, score, domain, author, and comment count
- **Inline article reading** — fetches full article text via trafilatura for CLI-based extraction
- **Async background loading** — feeds load in parallel threads without blocking the interface
- **Vim-inspired navigation** — j/k keys mapped to down/up, page up/down for big jumps
- **Theme support** — all Charming built-in themes are available out of the box, Phosphor by default

## Installation

```sh
gem install hackernews
```

Or use it locally:

```sh
git clone https://github.com/pando/hackernews.git
cd hackernews
bundle install
bundle exec hackernews
```

### System dependency

Article extraction requires [trafilatura](https://github.com/adverb-xyz/trafilatura) to be installed and on your PATH.

## Usage

```sh
hackernews
# or
bundle exec hackernews
```

### Keyboard shortcuts

| Key           | Action                  |
|-------------|-------------------------|
| j / Down     | Move cursor down        |
| k / Up       | Move cursor up          |
| Page up      | Jump 10 items up        |
| Page down    | Jump 10 items down      |
| n / Right    | Next page of stories    |
| Left         | Previous page           |
| Enter        | Open selected article   |
| Escape       | Close article, return to feed |
| r            | Refresh current feed    |

## Architecture

- **Models** — `HomeModel` manages local state: stories by page, feed index, article cache, loading indicators
- **Controllers** — `HomeController` coordinates data fetching from the Firebase API and article extraction
- **Views** — ERB templates with `.tui.erb` extension
- **Components** — reusable widgets like `StoryListComponent` that handle their own rendering

Key libraries: Charming (UI framework), HTTParty (HTTP client), Zeitwerk (auto-loading).

## Development

```sh
rspec         # run tests
rake          # all gem tasks
```

## License

TODO: Add license information.
