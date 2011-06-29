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

