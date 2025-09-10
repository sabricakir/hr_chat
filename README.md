# HR Chat (RAG System)

Bu proje, **Ruby on Rails 7.1** tabanlı bir chat uygulamasıdır ve **RAG (Retrieval-Augmented Generation)** yaklaşımını kullanır. Belgelerden bilgi alıp cevap oluşturabilir, kullanıcı geri bildirimlerini toplayabilir ve parametreleri dinamik olarak yönetebilirsiniz.

---

## 🛠️ Özellikler / Features

- **Chat Sistemi**: Kullanıcı ve bot mesajlarını gerçek zamanlı olarak görüntüler.
- **Dinamik RAG Ayarları**:
  - LLM modeli
  - Embedding modeli
  - Chunk size
  - Overlap
  - Limit
  - Top chunks
  Bu parametreleri anlık olarak değiştirebilirsiniz.
- **Feedback Loglama**: Kullanıcıların beğeni/tepki durumlarını kaydederek hangi ayarların daha etkili olduğunu analiz edebilirsiniz.
- **Benchmark / Performans Analizi**:
  - Farklı LLM ve embedding kombinasyonlarının doğruluk ve yanıt sürelerini karşılaştırabilirsiniz.
  - Chunk size, overlap, limit, top chunks gibi parametreleri değiştirerek performansı test edebilirsiniz.
  - Gerçek zamanlı feedback ile hangi ayarların daha etkili olduğunu görebilirsiniz.
- **pgvector Desteği**:
  Belgelerin embedding’leri PostgreSQL üzerinde `vector(768)` tipiyle saklanır. Bu sayede embedding tabanlı arama ve RAG işlemleri verimli çalışır.
- **Belge Yönetimi**: PDF formatındaki belgeler `storage/documents` klasöründen okunur, parçalara bölünür ve embedding’leri oluşturulur.
- **LLM Entegrasyonu (Ollama)**:
  - Ollama server ile local olarak iletişim kurulur (`http://localhost:11434`)
  - Model ve embeddinglerin önceden local olarak indirilmiş olması gerekir.
  - Completions ve embeddings endpoint’leri kullanılır.
- **Turbo & Stimulus**: Gerçek zamanlı chat deneyimi ve modern UI etkileşimleri için kullanılır.

---

## ⚙️ Gereksinimler / Requirements

- Ruby `3.3.1`
- Rails `~> 7.1.5`
- PostgreSQL + `pgvector` extension
- Ollama server (local) ve modellerin önceden indirilmiş olması

---

## 🔑 Credentials Yapılandırması

Rails credentials içine aşağıdaki şekilde modelleri ekleyin (`EDITOR=vim rails credentials:edit` komutuyla açabilirsiniz):


```yaml
chat:
  llm_models:
    - llama3:latest
    - gemma3:4b
  embedding_models:
    - nomic-embed-text:latest
    - snowflake-arctic-embed2
```

Controller tarafında bu modeller:

```ruby
@llm_models       = Rails.application.credentials.dig(:chat, :llm_models)
@embedding_models = Rails.application.credentials.dig(:chat, :embedding_models)
```

şeklinde alınır ve RAG ayarlarında kullanılabilir.

> ⚠️ Önemli: Buraya eklenen modellerin Ollama ile local olarak indirilmiş ve hazır olması gerekir. Aksi takdirde LLM veya embedding isteği başarısız olur.

---

## 🚀 Kurulum / Setup

### 1. Repo’yu klonlayın:

```bash
git clone <repo-url>
cd <repo-name>
```

### 2. Ruby ortamını kurun (rbenv veya rvm önerilir):

```bash
rbenv install 3.3.1
rbenv local 3.3.1
```

### 3. Gemleri yükleyin:

```bash
bundle install
```

### 4. Veritabanını oluşturun ve migrate edin:

```bash
rails db:create
rails db:migrate
```

### 5. pgvector extension’ını kurun:

```bash
brew install pgvector
```

### 6. Documents tablosunu oluşturun:

```bash
rails pgvector:create_documents_table
```

### 7. Ollama server'ı başlatın ve modellerin local olarak yüklü olduğundan emin olun.

### 8. Sunucuyu başlatın:

```bash
./bin/dev
```

---

## 📁 Belgelerin Hazırlanması

- Belgeleri **storage/documents** klasörüne PDF formatında ekleyin.
- **DocumentLoaderService.load_all** ile PDF’ler parçalara ayrılır ve embedding’leri veritabanına kaydedilir.

---

## ⚡ Kullanım / Usage

- **Chat Parametreleri:** LLM Model, Embedding Model, Chunk Size, Overlap, Limit, Top Chunks gibi ayarlar chat arayüzünden değiştirilebilir.
- **Feedback:** Her bot mesajının sonunda kullanıcı “👍 Beğendim / 👎 Beğenmedim” seçenekleri ile geri bildirim verebilir.
- **RAG Query:** Kullanıcı mesajı gönderildiğinde OllamaService üzerinden context ile cevap üretilir.
- **Embedding Search:** RetrievalService, embedding tabanlı en yakın belgeleri getirir.