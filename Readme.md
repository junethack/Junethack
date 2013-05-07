Junethack is a server for holding tournaments for the roguelike game NetHack
and its forks.

This server collects data from several external public servers and show
achievements and trophies for the participating players.

## Requirements

### Needed pre-installed software

 - ruby 1.9.3
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


TODO: more documentation, distinction prod/dev env, maintenance mode, manually fetching games, dummy users
