class RetrievalService
  # Retrieves the nearest documents based on the query embedding
  def self.retrieve(query, embedding_model: "nomic-embed-text:latest", limit: 5)
    query_embedding = EmbeddingService.embed(query, embedding_model)
    nearest_docs = DocumentLoaderService.nearest_documents(query_embedding, limit: limit)
    nearest_docs.map { |doc| { content: doc[:content], filename: doc[:filename] } }
  end
end
