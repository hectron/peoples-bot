# People's Bot

This is a bot that has a hodgepodge of commands. This was originally a way to prove out some simple functionalities.

## Commands

Below is a list of all the commands supported. For more details on each one, read the section below.

**Note:** All of the commands are prefixed using `!`. 

| Command                     | Description                                                                                                                                                       |
| -----                       | ------                                                                                                                                                            |
| `!help`                     | Shows all the commands available                                                                                                                                  |
| `!help <command>`           | Shows the help option for that specific command.                                                                                                                  |
| `!<vaccine-type> <zipcode>` | Example vaccine command.                                                                                                                                          |
| `!pfizer 60601`             | Find all pfizer vaccine appointments within 5 miles of 60601 (Illinois).                                                                                          |
| `!moderna 90210`            | Find all moderna vaccine appointmens within 5 miles of 90210 (California).                                                                                        |
| `!jj 11201`                 | Find all johnson & johnson vaccines within 5 miles of 11201 (New York).                                                                                           |
| `!beach`                    | Starts a beach (OTR) session in the current channel. Only one can be active per channel. If no one reacts to the bot message, the conversation will be **saved.** |
| `!gh`                       | Returns a link to the commit that is currently deployed.                                                                                                          |

### COVID-19 Vaccine Finder

It's really easy to find a `COVID-19` vaccine using this bot. You can search for a specific vaccine near your zip code by using the guide below. Currently, the `pfizer`, `moderna` and `jj` (Johnson & Johnson) vaccines are searchable.

This mimics the backend of https://vaccines.gov to render appointments.

### Beach Sand

An off-the-record-like command. When invoked, this command sends a message to the channel, initiating the session and reacts to that message with an :ocean: reaction.

Any conversation that is had after that bot message will be eligible to be deleted until someone reacts to the original bot message with the :ocean: reaction.

This command lasts for about 10 minutes.

### Github

This command specifically returns a link to the latest deploy SHA.

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
- `MAPBOX_TOKEN`
- `VACCINE_API_URL`
- `PROVIDER_URL`

**NOTE:** `Discordrb::Commands::CommandBot` uses websockets to connect to Discord. When deploying to **[Heroku](https://heroku.com)**, make sure the application has worker dynos enabled so that the application does not shutdown.

#### Optional

When the bot is initializing, it uses the two following environment variables to
set it's own status:

- `HEROKU_SLUG_COMMIT` - the SHA of the deployed code
- `HEROKU_RELEASE_VERSION` - the release version of the code
