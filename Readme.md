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

Use httrack to make a static copy of the website:

```
# httrack http://127.0.0.1:4567 -O /tmp/junethack_mirror '+https://www.gravatar.com*' '-127.0.0.1:4567/archive/*' -%v

# mv /tmp/junethack_mirror/127.0.0.1_4567 public/archive/2022
# cp /tmp/junethack_mirror/www.gravatar.com/avatar/* public/archive/www.gravatar.com/

# sed -i "s/<a class='logo' href='index.html'>/<a class='logo' href='\/'>/" public/archive/2022/*.html

# find public/archive/2022/ -name \*.html -print0 | xargs -0 sed -i "s/href='http:\/\/127.0.0.1:4567\/archive\//href='\/archive\//"

# git add public; git commit public -m 'Archival of 2022 tournament'
```

Edit the archive links to the previous Junethack tournaments in public/archive/2022/index.html.
Also add a link to the the new Junethack archive in views/splash.haml.

Add and commit the repository.


TODO: more documentation, distinction prod/dev env, maintenance mode, manually fetching games, dummy users
