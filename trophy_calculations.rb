# Limits by 10 any collection
def limit_by_10(collection)
    return collection.take(10) if collection.instance_of?(Array)
    collection.all(:limit => 10)
end

# This one returns last games ordered by endtime, with the latest game
# first. Optionally give conditions.
def get_last_games(and_collection=nil)
    params = { :order => [ :endtime.asc ] }
    games = Game.all(params)
    games &= and_collection if !and_collection.nil?
    games
end

# This one returns users ordered by the number of ascensions they have
def most_ascensions_users(and_collection=nil)
    # Now, I couldn't find an effective way to do this in a single SQL
    # query, I'll just collect all ascensions and then work on that. 
    # Should be a manageable amount.
    ascensions = Game.all(:death => 'ascended')
    ascensions &= and_collection if !and_collection.nil?

    # Count the ascensions per user to this hash
    user_ascensions = { }
    accounts_c = { }
    ascensions.each do |game|
        if !accounts_c[game.name].nil? then
          account = accounts_c[game.name]
        else
          account = Account.first(:name => game.name)
          next if account.nil?
          accounts_c[game.name] = account
        end

        next if account.user.nil?

        user = account.user

        user_ascensions[user.login] = 0 if user_ascensions[user.login].nil?
        user_ascensions[user.login] += 1
    end

    user_ascensions.sort_by{|username, ascensions| -ascensions}
end
    
# Helper class for calculating ascension density
class AccountCalc
    attr_accessor :games, :score, :account
    def initialize
        @games = [ ]
        @score = 0
    end

    def sort_games
        @games = @games.sort_by{|game| game.endtime}
    end

    def num_ascensions
        ascensions = 0
        @games.each do |game|
            ascensions += 1 if game.death == 'ascended'
        end
        ascensions
    end

    def calculate_score_between(games, min_score = 0.0)
        return min_score if games.nil?

        index_start = games.index{|game| game.death == 'ascended'}
        index_end = games.rindex{|game| game.death == 'ascended'}
        return min_score if index_start.nil?

        ascensions = 0.0
        for game in (index_start..index_end) do
            ascensions += 1.0 if games[game].death == 'ascended'
        end

        return min_score if min_score >= ascensions

        # The initial minimum score that the account will at least have.
        min_score = (ascensions*ascensions)/(index_end-index_start+1.0)

        # All the next iterations will have at least one ascension less.
        # If we have score that is always greater than any sequence of games
        # where all games are ascensions, we don't need to go calculate them.
        return min_score if min_score >= (ascensions-1)

        sc1 = calculate_score_between(games[index_start+1,index_end], min_score)
        min_score = sc1 if min_score < sc1
        return min_score if min_score >= (ascensions-1)
        return min_score if index_end == 0

        sc1 = calculate_score_between(games[index_start,index_end-1], min_score)
        min_score = sc1 if min_score < sc1
        min_score
    end

    def calculate_score
        # Calculate the longest distance between ascensions
        # So first ascension and last ascension

        @score = calculate_score_between(@games)
        @score
    end
end


def best_sustained_ascension_rate(and_collection=nil)
    ascensions = Game.all
    ascensions &= and_collection if !and_collection.nil?

    # Okay, the formula is (ascensions**2 / games) for the best
    # consecutive sequence of games per _account_.

    # We collect the games in arrays per account and then
    # calculate the score for each account.

    # Then, we select the best score in account belonging to an user
    # and pick that as the final score for the user.

    # Finally, we can order the users according to their scores.


    # First step, collect the games.
    accounts_c = { }
    ascensions.each do |game|
        if !accounts_c[game.name].nil? then
          account = accounts_c[game.name].account
          account_class = accounts_c[game.name]
        else
          account = Account.first(:name => game.name)
          next if account.nil?
          accounts_c[game.name] = AccountCalc.new
          accounts_c[game.name].account = account
          account_class = accounts_c[game.name]
        end

        next if account.user.nil?
        account_class.games.push(game)
    end

    # Sort the games and calculate score
    accounts_c.each do |account, account_class|
        account_class.sort_games
        account_class.calculate_score
    end

    users = { }
    # Wrap the thing up to users.
    accounts_c.each do |account, account_class|
        users[account_class.account.user.login] = account_class.score if 
            (users[account_class.account.user.login].nil? or
             users[account_class.account.user.login] < account_class.score)
    end

    users.sort_by{|username, score| -score}
end

