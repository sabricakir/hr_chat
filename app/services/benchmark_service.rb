require "benchmark"
require "csv"

class BenchmarkService
  DEFAULT_QUERIES = [
    "Maaşlar hangi tarihte yatırılıyor?",
    "Fazla mesai ücretleri ne zaman ödenir?",
    "İstifamı nasıl bildirebilirim?"
  ].freeze

  LLM_MODELS       = Rails.application.credentials.dig(:chat, :llm_models) || []
  EMBEDDING_MODELS = Rails.application.credentials.dig(:chat, :embedding_models) || []

  PARAMS = {
    chunk_sizes: [500, 600],
    overlaps:    [50, 100],
    limits:      [5, 10],
    top_chunks:  [3, 5]
  }.freeze

  # Run benchmark for all combinations of queries, LLM models, embedding models,
  # chunk sizes, overlaps, limits, and top_chunks, and store results in the database.
  def self.run(
    queries: DEFAULT_QUERIES,
    llm_models: LLM_MODELS,
    embedding_models: EMBEDDING_MODELS,
    chunk_sizes: PARAMS[:chunk_sizes],
    overlaps: PARAMS[:overlaps],
    limits: PARAMS[:limits],
    top_chunks: PARAMS[:top_chunks]
  )

    completed = BenchmarkResult.pluck(:query, :llm_model, :embedding_model, :chunk_size, :overlap, :limit, :top_chunks)

    queries.each do |query|
      parameter_sets(llm_models, embedding_models, chunk_sizes, overlaps, limits, top_chunks).each do |params|
        llm_model, embedding_model, chunk_size, overlap, limit, top_chunk = params

        next if completed.include?([query, llm_model, embedding_model, chunk_size, overlap, limit, top_chunk])

        run_query(query, llm_model, embedding_model, chunk_size, overlap, limit, top_chunk)
      end
    end
  end

  # Export all benchmark results to a CSV file, including query, parameters,
  # response time, and truncated answer for review.
  def self.export(filepath = Rails.root.join("tmp/benchmark_results.csv"))
    headers = %w[
      id query llm_model embedding_model chunk_size
      overlap limit top_chunks response_time_ms answer
    ]

    results = BenchmarkResult.order(created_at: :asc).to_a

    CSV.open(filepath, "w") do |csv|
      csv << headers
      results.each do |r|
        csv << [
          r.id, r.query, r.llm_model, r.embedding_model,
          r.chunk_size, r.overlap, r.limit, r.top_chunks,
          r.response_time_ms, r.answer&.truncate(200)
        ]
      end
    end

    filepath
  end

  private

  def self.parameter_sets(*arrays)
    arrays.reduce(&:product).map(&:flatten)
  end

  def self.run_query(query, llm_model, embedding_model, chunk_size, overlap, limit, top_chunks)
    answer_text = nil
    response_time = Benchmark.realtime do
      result = OllamaService.answer_with_context(
        query,
        llm_model: llm_model,
        embedding_model: embedding_model,
        chunk_size: chunk_size,
        overlap: overlap,
        limit: limit,
        top_chunks: top_chunks,
        load_documents: true
      )
      answer_text = result[:answer]
    end

    BenchmarkResult.create!(
      query: query,
      llm_model: llm_model,
      embedding_model: embedding_model,
      chunk_size: chunk_size,
      overlap: overlap,
      limit: limit,
      top_chunks: top_chunks,
      response_time_ms: (response_time * 1000).to_i,
      answer: answer_text
    )
  end
end
