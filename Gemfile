source 'https://rubygems.org'

ruby "2.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

gem 'nokogiri', '1.6.2.1'

# Use debugger
# gem 'debugger', group: [:development, :test]
gem 'devise'
gem 'paper_trail', '~> 3.0.5'
gem 'rails_admin', '~> 1.1.1'
gem 'friendly_id', '~> 5.0.0'
gem 'barby'
gem 'chunky_png'
gem 'cancan'
gem 'wicked_pdf'
gem 'kaminari' # pagination library

gem 'twilio-ruby', '5.0.0.rc7'

gem 'jquery-ui-rails'

gem 'aasm'

# API gems
gem 'doorkeeper'
gem 'grape'
gem 'grape-rabl'
gem 'hashie-forbidden_attributes' # https://github.com/ruby-grape/grape#rails
gem 'grape_on_rails_routes' # https://github.com/syedmusamah/grape_on_rails_routes

gem 'actionpack-page_caching'

gem 'redcarpet'

gem 'slim-rails'
gem 'semantic-ui-sass', github: 'doabit/semantic-ui-sass'

# FCM (for push notifications in mobile applications)
gem 'fcm'

gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
gem 'paperclip'

gem 'stripe'

gem 'comma', '~> 3.2.4'

gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra' # for Sidekiq::Web

group :test do
  gem 'database_cleaner'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec'
  gem 'capybara'
  gem 'launchy'
  gem 'factory_girl_rails'
end

gem 'colorize'
gem 'global_phone' # still needed?
gem 'global_phone_dbgen' #?

group :development do
  gem 'quiet_assets'
  gem 'active_record-annotate'

  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm', github: "ydkn/rvm" # because https://github.com/capistrano/rvm/pull/56
  gem 'capistrano-rails'
  gem "capistrano-db-tasks", require: false
  gem "capistrano-sidekiq"

  gem 'foreman'
end
