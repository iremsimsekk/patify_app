CREATE TABLE IF NOT EXISTS lost_reports (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    pet_type TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    seen_at TIMESTAMPTZ NOT NULL,
    contact_info TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_lost_reports_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_lost_reports_user_id ON lost_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_lost_reports_status ON lost_reports(status);
CREATE INDEX IF NOT EXISTS idx_lost_reports_created_at ON lost_reports(created_at DESC);
