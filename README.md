# People's Bot

This is a bot that has a hodgepodge of commands. This was originally a way to
prove out some simple functionalities.

## Commands

### COVID-19 Vaccine Finder

It's really easy to find a `COVID-19` vaccine using this bot. You can search for
a specific vaccine within your state (and zip codes) by using the guide below.
Currently, the `pfizer`, `moderna` and `jj` (Johnson & Johnson) vaccines are
searchable.

| Usage                                                                           | Description                                                                                                                   |
| -----                                                                           | ------                                                                                                                        |
| `!<vaccine-type> <state> [<city> (optional)] <zipcode> <zipcode> ... <zipcode>` | Example command.                                                                                                              |
| `!pfizer IL`                                                                    | Find all pfizer vaccine appointments in Illinois.                                                                             |
| `!pfizer IL Springfield`                                                        | Find all pfizer vaccines in Springfield, IL.                                                                                  |
| `!moderna CA`                                                                   | Find all moderna vaccine appointmens in California.                                                                           |
| `!jj NY 11201 11208 11204`                                                      | Find all johnson & johnson vaccines in the Brooklyn Heights, Cobble Hill, Cypress Hills and Parkville New York neighborhoods. |

### Beach Sand

An off-the-record-like command. When invoked, this command sends a message to
the channel, initiating the session and reacts to that message with an :ocean: reaction.

Any conversation that is had after that bot message will be eligible to be
deleted until someone reacts to the original bot message with the :ocean:
reaction.

This command lasts for about 10 minutes.

| Usage    | Description                                                                                                                                             |
| -----    | -------                                                                                                                                                 |
| `!beach` | Starts a beach session in the current channel. Only one can be active at once. If no one reacts to the bot message, the conversation will be **saved.** |

## Installing in your Discord server

TODO

## Development

This repo uses **Ruby 3** and leverages _**[discordrb](https://github.com/shardlab/discordrb)**_ to create a bot.

Every pull request must have a passing test suite.

To run the specs:

```bash
bundle exec rspec
```

### Deployment

This repo is set to automatically deploy to **[Heroku](https://heroku.com)** when a pull request is merged into `main`.

If you'd like to deploy this to your own personal **[Heroku](https://heroku.com)** instance, you will need the following environment variables:

- `DISCORD_BOT_CLIENT_TOKEN`
- `DISCORD_BOT_CLIENT_ID`

**NOTE:** `Discordrb::Commands::CommandBot` uses websockets to connect to Discord. When deploying to **[Heroku](https://heroku.com)**, make sure the application has worker dynos enabled so that the application does not shutdown.

#### Optional

When the bot is initializing, it uses the two following environment variables to
set it's own status:

- `HEROKU_SLUG_COMMIT` - the SHA of the deployed code
- `HEROKU_RELEASE_VERSION` - the release version of the code
