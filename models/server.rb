class Server
        include DataMapper::Resource

        has n, :games
        has n, :accounts
        has n, :users, :through => :accounts

        property :id,                   Serial
        property :name,                 String
        property :url,                  String
        property :xlogurl,              String
        property :xloglastmodified,     String
        property :xlogcurrentoffset,    Integer
end

