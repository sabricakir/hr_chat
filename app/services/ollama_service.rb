class OllamaService
  API_URL = "http://localhost:11434/v1/completions"

  class << self
    # Answers a user query with RAG parameters and optional document loading
    def answer_with_context(user_query, max_tokens: 1000, llm_model: "llama3:latest",
                            embedding_model: "nomic-embed-text:latest", load_documents: false,
                            limit: 20, top_chunks: 5, chunk_size: 500, overlap: 50)

      # Load all documents if needed
      if load_documents
        DocumentLoaderService.load_all(chunk_size: chunk_size, overlap: overlap)
      end

      # Retrieve nearest documents using embeddings
      retrieval = RetrievalService.retrieve(user_query, embedding_model: embedding_model, limit: limit)

      # Return a default message if no documents are found
      if retrieval.empty?
        return { answer: "Üzgünüm, bu konuda elimde bilgi yok.", sources: [] }
      end

      top = retrieval.first(top_chunks)
      context = top.map { |d| d[:content] }.join("\n\n")
      sources = top.map { |d| d[:filename] }.uniq

      prompt = <<~PROMPT
        Answer the following question based on the provided documents.
        Only respond in Turkish.

        Sources:
        #{context}

        Question: #{user_query}
        Answer:
      PROMPT

      answer_text = call_llm(prompt, max_tokens: max_tokens, llm_model: llm_model)

      { answer: answer_text.strip, sources: sources }
    end

    private

    # Calls the Ollama API to get LLM output for a given prompt
    def call_llm(prompt, max_tokens: 1000, llm_model: "llama3:latest")
      uri = URI(API_URL)
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      req.body = {
        model: llm_model,
        prompt: prompt,
        max_tokens: max_tokens
      }.to_json

      res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

      if res.is_a?(Net::HTTPSuccess)
        body = JSON.parse(res.body)
        body["choices"][0]["text"]
      else
        raise "Ollama API error: #{res.body}"
      end
    end
  end
end
