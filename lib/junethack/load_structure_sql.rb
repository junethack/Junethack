# Load db/structure.sql into the current ActiveRecord connection.
# Skips sqlite_sequence and schema_migrations statements which are
# managed by SQLite and ActiveRecord respectively.
def load_structure_sql(connection)
  structure_file = File.expand_path('../../../db/structure.sql', __FILE__)
  File.read(structure_file).split(';').each do |stmt|
    next if stmt.strip.empty?
    next if stmt.include?('sqlite_sequence') || stmt.include?('schema_migrations')
    connection.execute(stmt)
  end
end
