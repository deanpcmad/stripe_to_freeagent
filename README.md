# Stripe to FreeAgent

A Rails 4 app that uploads data from your Stripe account to FreeAgent.


## Setup

- Clone this repo and `bundle install`
- Create the database, run migrations & create a test user `rake db:create db:migrate db:seed`
- Copy the Omniauth settings and change as required `cp config/initializers/omniauth.example.rb config/initializers/omniauth.rb`
- Run the Rails server `rails server`
- Login with `test@test.com` and `password`

In Production, set the following environment variables:

- `USERNAME` - Delayed Job Web username
- `PASSWORD` - Delayed Job Web password
- `FREEAGENT_ID` - Your FreeAgent API ID
- `FREEAGENT_SECRET` - Your FreeAgent API Secret
- `STRIPE_CLIENT_ID` - Stripe Client ID
- `STRIPE_SECRET` - Stripe Secret API TOken
- `SECRET_KEY_BASE` - Run `rake secret` and copy the result to this


### Contribute

Feel like fixing or changing something? Just fork this repo and create a pull request :)