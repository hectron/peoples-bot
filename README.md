# vaccine-spotter Discord bot

Find a COVID-19 vaccine in the comfort of your Discord community.

## Usage

Currently, the `pfizer`, `moderna` and `jj` (Johnson & Johnson) vaccines are supported.

To search for a specific vaccine in your state:

```discord
!<vaccine-type> <state> <zipcode> <zipcode> ... <zipcode>

# finds all pfizer vaccines in Illinois
!pfizer IL

# finds all moderna vaccines in California
!moderna CA

# finds all johnson & johnson vaccines in the Brooklyn Heights, Cobble Hill, Cypress Hills and Parkville neighborhoods
!jj NY 11201 11208 11204
```

## Development

This repo uses _**Ruby 3**_ and leverages the [discordrb](https://github.com/shardlab/discordrb) library.

Every pull request must have a passing test suite.

To run the specs:

```bash
bundle exec rspec
```

### Deployment

This repo is set to automatically deploy to **[Heroku](https://heroku.com)**. When a pull request is merged into `main`, CI/CD will auto deploy it out to Heroku.

If you'd like to deploy this to your own personal Heroku instance, be aware that you will need the following environment variables:

- `DISCORD_BOT_CLIENT_TOKEN` -- the bot token
- `DISCORD_BOT_CLIENT_ID` -- the client ID of the application

**NOTE:** `Discordrb::Commands::CommandBot` uses websockets to connect to Discord, and listen to messaging. This means that the application needs to be running constantly. When deploying to Heroku, make sure the application has worker dynos enabled so that the application does not shutdown.
