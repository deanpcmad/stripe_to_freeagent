# Stripe to FreeAgent

A Rails 4 app that uploads data from your Stripe account to FreeAgent.

- Ruby 2.1.3
- Rails 4.2.0
- MySQL

## Setup

- Clone this repo and `bundle install`
- Create the database, run migrations & create a test user `rake db:create db:migrate db:seed`
- Copy the Omniauth settings and change as required `cp config/initializers/omniauth.example.rb config/initializers/omniauth.rb`
- Run the Rails server `rails server`
- Login with `test@test.com` and `password`

### Things that need changing

+ Bank transfer dates are set by the stripe create date, not the date it will arrive
+ Better design


### Contribute

Feel like fixing or changing something? Just fork this repo and create a pull request :)