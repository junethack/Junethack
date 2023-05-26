Junethack is a server for holding tournaments for the roguelike game NetHack
and its forks.

This server collects data from several external public servers and show
achievements and trophies for the participating players.

## Requirements

### Needed pre-installed software

 - ruby 3.1.4
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

### Setting up the server for a new year

Update the year in the following files
 - lib/junethack/tournament_times.rb
 - public/graph/graph_ascensions.js
 - public/graph/graph_finished_games_per_day.js
 - public/graph/graph_new_users_per_day.js
 - views/footer.haml
 - views/layout.haml
 - views/splash.haml
 - views/user.haml

Go through the list of servers and variants and add new ones and remove old ones.

### Archival of a finished tournament

Use the script scripts/archive.sh to make a static copy of the website.

Edit the archive links to the previous Junethack tournaments in public/archive/2023/index.html.
Also add a link to the the new Junethack archive in views/splash.haml.

Add and commit the repository.


TODO: more documentation, distinction prod/dev env, maintenance mode, manually fetching games, dummy users
