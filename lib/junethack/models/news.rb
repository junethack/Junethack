require 'dm-migrations'
require 'dm-migrations/migration_runner'

class News
    include DataMapper::Resource

    property :id,         Serial
    property :html,       String, :required => true

    property :created_at, DateTime
    property :updated_at, DateTime
end
