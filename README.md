# vaccine-spotter Discord bot

Find a COVID-19 vaccine in the comfort of your Discord community.

## Usage

You can search for a specific vaccine within your state (and zip codes) by using the guide below. Currently, the `pfizer`, `moderna` and `jj` (Johnson & Johnson) vaccines are searchable.

```console
# The following is the format for a Discord command
# !<vaccine-type> <state> [<city> (optional)] <zipcode> <zipcode> ... <zipcode>

# finds all pfizer vaccines in Illinois
!pfizer IL

# find all pfizer vaccines in Springfield, IL
!pfizer IL Springfield

# finds all moderna vaccines in California
!moderna CA

# finds all moderna vaccines in Los Angeles, California
!moderna CA Los Angeles

# finds all johnson & johnson vaccines in the Brooklyn Heights, Cobble Hill,
# Cypress Hills and Parkville New York neighborhoods
!jj NY 11201 11208 11204
```

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
