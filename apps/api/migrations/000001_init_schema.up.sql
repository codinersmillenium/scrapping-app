-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. social_accounts
CREATE TABLE IF NOT EXISTS social_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform VARCHAR(50) NOT NULL DEFAULT 'instagram',
    username VARCHAR(100) NOT NULL UNIQUE,
    encrypted_credentials TEXT,
    encrypted_session TEXT,
    connection_status VARCHAR(50) NOT NULL DEFAULT 'disconnected',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. social_posts
CREATE TABLE IF NOT EXISTS social_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES social_accounts(id) ON DELETE SET NULL,
    platform_post_id VARCHAR(100) UNIQUE,
    post_url TEXT NOT NULL UNIQUE,
    caption TEXT,
    media_type VARCHAR(50) DEFAULT 'image',
    published_at TIMESTAMPTZ,
    scraped_at TIMESTAMPTZ,
    scraping_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_social_posts_scraping_status ON social_posts(scraping_status);
CREATE INDEX IF NOT EXISTS idx_social_posts_created_at ON social_posts(created_at DESC);

-- 3. post_images
CREATE TABLE IF NOT EXISTS post_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES social_posts(id) ON DELETE CASCADE,
    storage_key TEXT NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL DEFAULT 'image/jpeg',
    file_size BIGINT NOT NULL DEFAULT 0,
    checksum VARCHAR(64),
    width INT DEFAULT 0,
    height INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_post_images_post_id ON post_images(post_id);

-- 4. post_image_analyses
CREATE TABLE IF NOT EXISTS post_image_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_image_id UUID NOT NULL REFERENCES post_images(id) ON DELETE CASCADE,
    ocr_text TEXT,
    ocr_blocks JSONB DEFAULT '[]'::jsonb,
    image_description TEXT,
    image_category VARCHAR(100),
    detected_topics JSONB DEFAULT '[]'::jsonb,
    context_summary TEXT,
    ocr_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    vision_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_post_image_analyses_post_image_id ON post_image_analyses(post_image_id);

-- 5. ml_models (referenced by sentiment_results)
CREATE TABLE IF NOT EXISTS ml_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL UNIQUE,
    algorithm VARCHAR(100) NOT NULL,
    model_storage_key TEXT NOT NULL,
    dataset_version VARCHAR(50),
    metrics JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. social_comments
CREATE TABLE IF NOT EXISTS social_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES social_posts(id) ON DELETE CASCADE,
    platform_comment_id VARCHAR(100),
    parent_comment_id VARCHAR(100),
    username VARCHAR(100),
    original_text TEXT NOT NULL,
    normalized_text TEXT,
    published_at TIMESTAMPTZ,
    scraped_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_social_comments_post_id ON social_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_social_comments_published_at ON social_comments(published_at DESC);

-- 7. sentiment_results
CREATE TABLE IF NOT EXISTS sentiment_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL UNIQUE REFERENCES social_comments(id) ON DELETE CASCADE,
    sentiment VARCHAR(20) NOT NULL CHECK (sentiment IN ('positive', 'negative', 'neutral')),
    confidence_score DOUBLE PRECISION DEFAULT 0.0,
    model_id UUID REFERENCES ml_models(id) ON DELETE SET NULL,
    is_manually_corrected BOOLEAN NOT NULL DEFAULT FALSE,
    original_sentiment VARCHAR(20),
    corrected_sentiment VARCHAR(20),
    analyzed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sentiment_results_sentiment ON sentiment_results(sentiment);
CREATE INDEX IF NOT EXISTS idx_sentiment_results_comment_id ON sentiment_results(comment_id);

-- 8. scraping_jobs
CREATE TABLE IF NOT EXISTS scraping_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES social_posts(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    progress INT NOT NULL DEFAULT 0,
    total_items INT NOT NULL DEFAULT 0,
    processed_items INT NOT NULL DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scraping_jobs_status ON scraping_jobs(status);
CREATE INDEX IF NOT EXISTS idx_scraping_jobs_post_id ON scraping_jobs(post_id);

-- 9. analysis_jobs
CREATE TABLE IF NOT EXISTS analysis_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES social_posts(id) ON DELETE CASCADE,
    job_type VARCHAR(50) NOT NULL, -- 'ocr', 'vision', 'sentiment', 'all'
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    progress INT NOT NULL DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analysis_jobs_status ON analysis_jobs(status);
CREATE INDEX IF NOT EXISTS idx_analysis_jobs_post_id ON analysis_jobs(post_id);
