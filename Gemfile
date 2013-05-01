source "http://rubygems.org"
gem 'dm-sqlite-adapter'
gem "datamapper", "~> 1.1.0"
gem "data_mapper", "~> 1.1.0"
gem 'dm-migrations'
gem "json"
gem "haml"
gem "sinatra", "~> 1.2.6"
gem "rufus-scheduler"
gem "orderedhash", "~> 0.0.6"
gem "sinatra-cache"

gem "thin"
 # eventmachine 0.12.10 crashes with:
 # undefined method `associate_callback_target' for #<Thin::Connection:0x7f9bcfa666a8>
 gem "eventmachine", "<= 0.12.8"

# charts
gem "fastercsv"

group :development, :test do
  gem 'rake'
  gem "rack-test", "~> 0.6.1"
  gem 'rspec'
  gem 'simplecov'
  gem 'ci_reporter'
end
