ALTER TABLE users
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ NULL,
ADD COLUMN IF NOT EXISTS first_name TEXT NULL,
ADD COLUMN IF NOT EXISTS last_name TEXT NULL;

CREATE TABLE IF NOT EXISTS institutions (
    id BIGSERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    district TEXT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT chk_institutions_type CHECK (type IN ('clinic', 'shelter'))
);

CREATE TABLE IF NOT EXISTS locations (
    id BIGSERIAL PRIMARY KEY,
    institution_id BIGINT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    CONSTRAINT fk_locations_institution
        FOREIGN KEY (institution_id)
        REFERENCES institutions(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS posts (
    id BIGSERIAL PRIMARY KEY,
    author_user_id BIGINT NOT NULL,
    content_text TEXT NOT NULL,
    media_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT fk_posts_author
        FOREIGN KEY (author_user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reports (
    id BIGSERIAL PRIMARY KEY,
    reported_post_id BIGINT NOT NULL,
    reporter_user_id BIGINT NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_reports_post
        FOREIGN KEY (reported_post_id)
        REFERENCES posts(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reports_reporter
        FOREIGN KEY (reporter_user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_reports_status
        CHECK (status IN ('pending', 'reviewed', 'action_taken'))
);

CREATE INDEX IF NOT EXISTS idx_institutions_type ON institutions(type);
CREATE INDEX IF NOT EXISTS idx_institutions_district ON institutions(district);
CREATE INDEX IF NOT EXISTS idx_locations_institution_id ON locations(institution_id);
CREATE INDEX IF NOT EXISTS idx_posts_author_user_id ON posts(author_user_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported_post_id ON reports(reported_post_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_user_id ON reports(reporter_user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);