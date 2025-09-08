class OllamaService
  API_URL = "http://localhost:11434/v1/completions"
  MODEL = "llama3:latest"

  class << self
    def answer_with_context(user_query, limit: 20, top_chunks: 5, max_tokens: 1000)
      retrieval = RetrievalService.retrieve(user_query, limit: limit)

      if retrieval.empty?
        return { answer: "Üzgünüm, bu konuda elimde bilgi yok.", sources: [], snippets: [] }
      end

      top = retrieval.first(top_chunks)
      context = top.map { |d| d[:content] }.join("\n\n")
      sources = top.map { |d| d[:filename] }.uniq
      snippets = top.map { |d| { filename: d[:filename], snippet: d[:content][0..200] } }

      prompt = <<~PROMPT
        Aşağıdaki belgelerden verilen bilgilerle cevap verin.
        Eğer cevap belgelerde yoksa "Üzgünüm, bu konuda elimde bilgi yok." deyin.
        Sadece Türkçe cevap verin.

        Kaynaklar:
        #{context}

        Soru: #{user_query}
        Cevap:
      PROMPT

      answer_text = call_llm(prompt, max_tokens: max_tokens)

      { answer: answer_text.strip, sources: sources, snippets: snippets }
    end

    private

    def call_llm(prompt, max_tokens: 1000)
      uri = URI(API_URL)
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      req.body = {
        model: MODEL,
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
