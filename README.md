# README

* Ruby version

ruby 2.3.4

* System dependencies

`gem install bundler`

* Configuration

`bundle install`

* Database creation

`rake db:create`

* Database initialization

`rake db:migrate`

* How to run the test suite

`rake spec`

* Services (job queues, cache servers, search engines, etc.)

For simplicity, we fetch the station data during the user's request. 
This way we avoid installing sidekiq or some other background job engine.
We're calling perform_now in station.rb. In a real system, we would call perform_later.

This could also be performed using a recurring job, but that means we would update the 
db even when there's no user on our site. 

The absence of a background job engine result in a cheaper app deployment. 
Something Mr. Bertrand will surely appreciate. :)
