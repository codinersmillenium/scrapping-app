# 📊 Scrapping App & Indonesian Sentiment Analysis Platform (Pro Edition)

Sistem pemantauan reputasi, ekstraksi postingan & komentar Instagram, serta analisis sentimen opini publik berbasis **Natural Language Processing (NLP) Bahasa Indonesia** dan **Arsitektur Microservices Terdistribusi**.

---

## 🌟 Fitur Utama

- **Automated Profile Scraper**: Ekstraksi postingan publik feed akun Instagram (mendukung pengambilan batch besar 20+ postingan secara otomatis) tanpa perlu input link satu per satu.
- **Deep Indonesian NLP Pipeline**:
  - *Regex cleaning* (URL, mention, hashtag, karakter berulang).
  - *Slang & Shorthand Normalization* (kamus bahasa gaul & singkatan informal).
  - **Preservasi Kata Negasi** (*tidak, bukan, belum, jangan, kurang, tak*) agar polaritas sentimen tidak terbalik.
  - *Stemming* Sastrawi & selektif *Stopword Removal*.
- **Machine Learning Sentiment Engine**:
  - Representasi fitur: **TF-IDF (Unigram + Bigram)** dengan *Sublinear Scaling*.
  - Pemodelan: **Calibrated Linear Support Vector Machine (Linear SVM)** dengan *Platt Scaling* (akurasi > 89%, Macro F1 > 88%).
  - Model pembanding: **Multinomial Naive Bayes (MNB)**.
- **Enterprise Job Queue**: Pemrosesan asinkron berbasis antrean tugas Redis & Go Worker concurrency.
- **Interactive Modern Dashboard**: Antarmuka web Nuxt 3 & TailwindCSS untuk visualisasi sentimen, pemantauan real-time status scraping, dan verifikasi akun.

---

## 🛠️ Arsitektur & Spesifikasi Sistem

| Komponen | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Frontend Web** | Nuxt 3, Vue 3, TailwindCSS, Chart.js | Port `3002` |
| **Backend API** | Go 1.24, Chi Router, PostgreSQL Driver, Redis Client | Port `8084` (Stripped Binary) |
| **Scraper & NLP Worker** | Python 3.13, Scikit-Learn, Sastrawi, Instaloader, PyArmor | Protected C-Extension Engine |
| **Message Broker** | Redis 7 Alpine | Port `6380` (Internal `6379`) |
| **Database** | PostgreSQL 16 Alpine | Port `5435` (Internal `5432`) |

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

### 1. Prasyarat Sistem
- **Docker Engine** (versi >= 24.0)
- **Docker Compose** (v2)
- RAM minimal 4 GB

### 2. Kloning Repositori & Setup Environment
```bash
# 1. Masuk ke direktori proyek
cd scrapping-app

# 2. Konfigurasi file environment
cp .env.example .env
```

Isi file `.env`:
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=scrapping_db
INTERNAL_API_SECRET=scrapping-app-internal-secret-change-me
```

### 3. Menjalankan Seluruh Layanan (Docker Compose)
Jalankan perintah berikut di root direktori proyek:
```bash
docker compose -f infrastructure/docker-compose.yml up -d
```

Seluruh layanan (Postgres, Redis, Go API, Python Worker, dan Nuxt Web) akan otomatis dikompilasi dan dijalankan di latar belakang.

### 4. Mengakses Aplikasi
Buka web browser dan akses URL berikut:
- 🌐 **Dashboard Analisis Sentimen**: [http://localhost:3002](http://localhost:3002)
- 🔌 **REST API Backend**: [http://localhost:8084/api/v1](http://localhost:8084/api/v1)

---

## 🔑 Pengaturan Session ID

1. Buka menu **Settings** di web dashboard (`http://localhost:3002/settings`).
2. Masukkan **Session ID Instagram** milik Anda (diperoleh dari cookie browser `sessionid` saat login di web Instagram).
3. Klik tombol **"Tes & Verifikasi Session ID"** untuk memastikan sesi Instagram Anda aktif.
4. Simpan pengaturan. Anda kini dapat melakukan scraping profil publik (misal `@curhatan_uty`) hingga puluhan postingan secara otomatis.

---
