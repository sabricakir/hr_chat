class EmbeddingService
  API_URL = "http://localhost:11434/v1/embeddings"
  MODEL = "nomic-embed-text:latest"

  def self.embed(text)
    uri = URI(API_URL)
    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    req.body = { model: MODEL, input: text }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    if res.is_a?(Net::HTTPSuccess)
      body = JSON.parse(res.body)
      body["data"][0]["embedding"]
    else
      raise "Embedding API error: #{res.body}"
    end
  end
end
