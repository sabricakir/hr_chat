namespace :pgvector do
  desc "Create documents table with vector"
  task create_documents_table: :environment do
    conn = PgConnectionService.conn
    conn.exec(<<-SQL)
      CREATE TABLE IF NOT EXISTS documents (
        id bigserial PRIMARY KEY,
        filename text,
        content text,
        embedding vector(768),
        created_at timestamp default now(),
        updated_at timestamp default now()
      )
    SQL
    puts "Table documents created (if it didn't exist)."
  end
end

