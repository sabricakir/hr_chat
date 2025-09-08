class RetrievalService
  def self.retrieve(query, limit: 5)
    query_embedding = EmbeddingService.embed(query)
    nearest_docs = DocumentLoaderService.nearest_documents(query_embedding, limit: limit)
    nearest_docs.map { |doc| { content: doc[:content], filename: doc[:filename] } }
  end
end
