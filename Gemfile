source "https://rubygems.org"

gem 'dm-sqlite-adapter'

gem 'dm-types',
  git: 'https://github.com/julienma/dm-types.git',
  branch: 'gem-v1.2.2-with-frozen-nilclass-fix'
gem "data_mapper", "~> 1.2.0"
gem 'dm-migrations'

gem "json"
gem "haml"

gem "sinatra", "~> 1.4.0"
gem "nokogiri", "~> 1.10"

gem "rufus-scheduler"
gem 'sinatra-cache', git: 'https://github.com/kematzy/sinatra-cache.git'
gem 'sanitize'

gem "rack-mobile-detect"

gem "thin"

# charts
gem "fastercsv"

group :development, :test do
  gem 'rake', '< 13.0'
  gem "rack-test", "~> 0.6.1"
  gem 'rspec'
  gem 'simplecov'
  gem 'ci_reporter'
  gem 'pry'
  #gem 'pry-stack_explorer'
end
