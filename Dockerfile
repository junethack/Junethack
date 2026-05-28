# Use a slim Ruby image as the base
FROM ruby:4.0.2-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libyaml-dev curl git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 9292

# Define the command to start the application, including migrations
# This CMD instruction now clearly separates migration and server startup.
CMD ["bash", "-c", "export RACK_ENV=production && echo \"Running database migrations...\" && bundle exec rake db:migrate && echo \"Database migrations complete. Starting server...\" && exec bundle exec rackup -p 9292 -s thin"]
