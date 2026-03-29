Junethack is a server for holding tournaments for the roguelike game NetHack
and its forks.

This server collects data from several external public servers and show
achievements and trophies for the participating players.

## Requirements

### Needed pre-installed software

 - ruby 3.1.7
 - curl
 - sqlite3

### Installation

Clone the repository:

    git clone https://github.com/junethack/Junethack.git junethack


Install the Ruby interpreter. Example using RVM:

    \curl -#L https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm install `cat junethack/.ruby-version`

Install all required rubygems:

    cd junethack
    bundle install

Start the server

    rake

## Setting up the server for a new year

Update the year in the following files
 - lib/junethack/tournament_times.rb
 - public/graph/graph_ascensions.js
 - public/graph/graph_finished_games_per_day.js
 - public/graph/graph_new_users_per_day.js
 - views/footer.haml
 - views/layout.haml
 - views/splash.haml
 - views/user.haml

### Adding a new variant
 - add xlogfile location in Game.create_server
 - if possible add version detection to Game.version=
 - add Trophy.check_trophies_for_variant(new_variant) to :create_variant_trophies in trophy.rb
 - add version designator to $variants_mapping and $variant_order in helper.rb
 - regenerate cross variant trophies with icons/icons_cross_variant.rb
 - add dumplog links in server.rb


Go through the list of servers and variants and add new ones and remove old ones.

## Archival of a finished tournament

 - start the webserver with ARCHIVE_MODE=1
 - update the year in scripts/archive.sh
 - use the script scripts/archive.sh to make a static copy of the website.
 - edit the archive links to the previous Junethack tournaments in public/archive/2025/index.html
 - add a link to the the new Junethack archive in views/splash.haml
 - add and commit the repository

## Development

### Database & Migrations

Junethack uses ActiveRecord (via [sinatra-activerecord](https://github.com/sinatra-activerecord/sinatra-activerecord))
with SQLite as the database backend. The database configuration is in `config/database.yml`.

The schema format is SQL (`db/structure.sql`) rather than Ruby's `db/schema.rb`. This file is auto-generated after each
migration and should be committed to the repository.

#### Running migrations

    bundle exec rake db:migrate

#### Creating a new migration

    bundle exec rake db:create_migration NAME=add_foo_to_bar

This creates a timestamped file in `db/migrate/`. Edit it and run `db:migrate`.

#### Other useful commands

    bundle exec rake db:rollback          # undo last migration
    bundle exec rake db:migrate:status    # show status of all migrations

#### Fresh database setup

When no database exists, `rake db:migrate` will run all migrations starting with the baseline migration
(`db/migrate/20260101000000_baseline_schema.rb`), which loads `db/structure.sql` to create all tables.

### Running the server

By default, `rake` starts the server in development mode using `junethack_dev.db`:

    rake

For production (uses `junethack.db`):

    RACK_ENV=production rake

### Maintenance mode

Show a maintenance page to all visitors instead of the regular site:

    rake run:maintenance

### Fetching games

Manually fetch new xlogfile entries from all game servers:

    rake db:get_games

TODO: more documentation, dummy users
