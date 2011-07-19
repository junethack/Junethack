#Junethack

##Prerequisites

###Software needed

 - ruby 1.8.7
 - rubygems (latest build)
 - curl
 - sqlite3

###Gems needed

 - sinatra
 - haml
 - ruby-sqlite3
 - datamapper
 - dm-serializer
 - bundler

##Usage
Run the sinatra server with 
> ruby sinatra_server.rb

Initialize some test servers, accounts, users and write bogus games in xlogfiles.
> rake bogus:init

- The test users created are "r4wrmage", "ad3on", "k3rio", "bh44k", "c4smith789", and "st3nno".
- The passwords and account names are the same as the user names.
- Two servers with xlogfiles are created.
- Some games are written in the xlogfiles (but are not parsed into the database).


Parse the games into the database
> rake fetch:get_games

- Checks all servers on changed xlogfiles. If a xlogfile has been changed, the new games are fetched and written in the database


Create some new bogus games
> rake bogus:add_game[10]

- Adds 10 games of random players to random xlogfiles.

