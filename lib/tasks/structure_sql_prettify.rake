module Tasks
  class StructureSqlPrettifier
    COLUMN_SORT_ORDER = %i[primary_key foreign_key regular timestamp lock_version].freeze

    def initialize(sql)
      @sql = sql
    end

    def prettify(output)
      sql = @sql.dup

      # remove unnecessary comments
      sql.gsub!(/^--$/, "\n")
      sql.gsub!(/^-- Name: .*/, "\n")

      # collapse consecutive empty lines
      sql.gsub!(/\n{3,}/, "\n\n")

      # sort columns
      sql.gsub!(/^CREATE TABLE .*?(?:\);$)/m) do |table|
        lines = table.split("\n")
        header_line = lines[0]
        body_lines = lines[1..-2]
        partitioned = body_lines.include?(')')
        body_lines = body_lines.reject { |e| e == ')' } if partitioned

        columns = body_lines.map { |c| c.gsub(/,$/, '') }
          .sort_by { |c| [column_category(c), c] }
        columns[0..-2] = columns[0..-2].map { |c| "#{c}," }

        ([header_line] + columns + (partitioned ? [')'] : []) + [lines[-1]]).join("\n")
      end

      # place indexes directly after their table
      indexes = sql.scan(/^CREATE.+INDEX.+ON.+\n/)
        .sort
        .group_by { |line| line.scan(/\b\w+\.\w+\b/).first }
        .transform_values(&:join)

      sql.gsub!(/^CREATE( UNIQUE)? INDEX \w+ ON .+\n+/, '')
      indexes.each do |table, indexes_for_table|
        sql.gsub!(/^(CREATE TABLE #{table}\b(:?[^;\n]*\n)+.*\);\n)/) { "#{Regexp.last_match(1)}\n#{indexes_for_table}" }
      end

      # reformat schema_migrations INSERT to use leading commas
      i = sql.lines.index { |l| l.include?('INSERT INTO "schema_migrations"') }
      if i
        lines = sql.lines
        versions = lines[(i + 1)..].grep(/\('[^']*'\)/).map { |v| v.strip.delete_suffix(',').delete_suffix(';') }
        lines[i..] = [
          "INSERT INTO \"schema_migrations\" (version) VALUES\n",
          " #{versions[0]}\n",
          *versions[1..].map { |v| ",#{v}\n" },
          ";\n"
        ]
        sql = lines.join
      end

      output << sql.strip
      output << "\n"
    end

    private

    def column_category(column)
      category = case column
                 when / id /                       then :primary_key
                 when /_id /                       then :foreign_key
                 when /created_at /, /updated_at / then :timestamp
                 when /lock_version /              then :lock_version
                 else                                   :regular
                 end
      COLUMN_SORT_ORDER.index(category)
    end
  end
end

desc 'Cleans up and reformats db/structure.sql - runs after db:schema:dump'
task 'db:prettify_structure_sql' do |task_name|
  structure_file = File.expand_path('../../../db/structure.sql', __FILE__)
  schema = File.read(structure_file)

  File.open(structure_file, 'wb+') do |file|
    Tasks::StructureSqlPrettifier.new(schema).prettify(file)
  end

  # Allow this task to be called multiple times, as happens when running db:migrate:redo
  Rake::Task[task_name].reenable
end

Rake::Task['db:schema:dump'].enhance do
  Rake::Task['db:prettify_structure_sql'].execute
  # https://github.com/rails/rails/issues/55509
  structure_file = File.expand_path('../../../db/structure.sql', __FILE__)
  schema = File.read(structure_file)
  schema.gsub!(/^-- Dumped from database version.*$\n/, '')
  schema.gsub!(/^-- Dumped by pg_dump version.*$\n\n?/, '')
  schema.gsub!(/^\\restrict .*$\n\n?/, '')
  schema.gsub!(/^\\unrestrict .*$\n\n?/, '')
  File.write(structure_file, schema)
end
