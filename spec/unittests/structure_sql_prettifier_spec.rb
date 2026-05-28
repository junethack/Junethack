require 'rake'

Rake::Task.define_task('db:schema:dump') unless Rake::Task.task_defined?('db:schema:dump')
load File.expand_path('../../../lib/tasks/structure_sql_prettify.rake', __FILE__)

RSpec.describe('Tasks::StructureSqlPrettifier') do
  def prettify(sql)
    [].tap { |out| Tasks::StructureSqlPrettifier.new(sql).prettify(out) }.join
  end

  it 'strips noise comments but keeps real ones' do
    expect(prettify("--\n-- Name: removable\n-- kept")).to eq("-- kept\n")
  end

  it 'trims trailing blank lines' do
    expect(prettify("-- comment\n\n\n")).to eq("-- comment\n")
  end

  it 'sorts table columns by category (id, *_id, others, timestamps, lock_version)' do
    sql = <<~SQL
      CREATE TABLE my_table (
        lock_version integer,
        updated_at timestamp,
        col2 character,
        foreign_key_id integer,
        col1 character,
        created_at timestamp,
        id integer
      );
    SQL

    expect(prettify(sql)).to eq(<<~SQL)
      CREATE TABLE my_table (
        id integer,
        foreign_key_id integer,
        col1 character,
        col2 character,
        created_at timestamp,
        updated_at timestamp,
        lock_version integer
      );
    SQL
  end

  it 'handles CREATE TABLE ... PARTITION BY without breaking the partition clause' do
    sql = <<~SQL
      CREATE TABLE my_table (
        updated_at timestamp,
        id integer,
        archived boolean DEFAULT false NOT NULL
      )
      PARTITION BY LIST (archived);
    SQL

    expect(prettify(sql)).to eq(<<~SQL)
      CREATE TABLE my_table (
        id integer,
        archived boolean DEFAULT false NOT NULL,
        updated_at timestamp
      )
      PARTITION BY LIST (archived);
    SQL
  end

  it 'groups indexes immediately after their owning table, sorted' do
    sql = <<~SQL
      CREATE INDEX index_my_table_on_other_col ON public.my_table USING btree (other_col);

      CREATE TABLE public.my_table (
        id integer,
        other_col integer
      );

      CREATE UNIQUE INDEX index_my_table_on_other_col_and_id ON public.my_table USING btree (other_col, id);
      CREATE INDEX index_my_table_on_id ON public.my_table USING btree (id);
    SQL

    expect(prettify(sql)).to eq(<<~SQL)
      CREATE TABLE public.my_table (
        id integer,
        other_col integer
      );

      CREATE INDEX index_my_table_on_id ON public.my_table USING btree (id);
      CREATE INDEX index_my_table_on_other_col ON public.my_table USING btree (other_col);
      CREATE UNIQUE INDEX index_my_table_on_other_col_and_id ON public.my_table USING btree (other_col, id);
    SQL
  end
end
