class DocumentLoaderService
  DOCUMENTS_PATH = Rails.root.join("storage/documents")

  class << self
    def load_all(chunk_size: 500, overlap: 50)
      Dir.glob("#{DOCUMENTS_PATH}/*.pdf").each do |file_path|
        filename = File.basename(file_path)
        content = read_pdf(file_path)
        chunks = chunk_text(content, chunk_size: chunk_size, overlap: overlap)

        chunks.each do |chunk|
          embedding = EmbeddingService.embed(chunk)

          conn = ActiveRecord::Base.connection.raw_connection
          conn.exec_params(
            "INSERT INTO documents (filename, content, embedding, created_at, updated_at) VALUES ($1, $2, $3, now(), now())",
            [filename, chunk, embedding]
          )
        end
      end
    end

    def nearest_documents(query_embedding, limit: 5)
      conn = ActiveRecord::Base.connection.raw_connection
      results = conn.exec_params(
        "SELECT content, filename FROM documents ORDER BY embedding <-> $1 LIMIT $2",
        [query_embedding, limit]
      )
      results.map { |r| { filename: r["filename"], content: r["content"] } }
    end

    private

    def read_pdf(path)
      reader = PDF::Reader.new(path)
      reader.pages.map(&:text).join("\n")
    end

    def chunk_text(text, chunk_size: 500, overlap: 50)
      chunks = []
      start = 0
      while start < text.length
        chunks << text[start, chunk_size]
        start += chunk_size - overlap
      end
      chunks
    end
  end
end
