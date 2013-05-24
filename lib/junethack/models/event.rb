require 'dm-migrations'
require 'dm-migrations/migration_runner'

class Event
    include DataMapper::Resource

    property :id,         Serial
    property :text,       String
    property :url,        String
    property :created_at, DateTime
end

