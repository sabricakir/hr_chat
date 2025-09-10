class CreateBenchmarkResults < ActiveRecord::Migration[7.1]
  def change
    create_table :benchmark_results do |t|
      t.string :query, null: false
      t.text :answer, null: false
      t.string :llm_model, null: false
      t.string :embedding_model, null: false
      t.integer :chunk_size
      t.integer :overlap
      t.integer :limit
      t.integer :top_chunks
      t.integer :response_time_ms

      t.timestamps
    end
  end
end
