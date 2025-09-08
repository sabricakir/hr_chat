require "pg"
require "pgvector"

class PgConnectionService
  def self.conn
    @conn ||= begin
      conn = PG.connect(dbname: "hr_chatbot_development", user: ENV["DB_USER"])

      conn.exec("CREATE EXTENSION IF NOT EXISTS vector")

      registry = PG::BasicTypeRegistry.new.define_default_types
      Pgvector::PG.register_vector(registry)
      conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn, registry: registry)

      conn
    end
  end
end
