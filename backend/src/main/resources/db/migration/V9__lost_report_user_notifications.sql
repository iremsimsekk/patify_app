CREATE TABLE IF NOT EXISTS lost_report_notifications (
    id BIGSERIAL PRIMARY KEY,
    lost_report_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_lost_report_notifications_report
        FOREIGN KEY (lost_report_id)
        REFERENCES lost_reports(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_lost_report_notifications_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_lost_report_notifications_report_user
        UNIQUE (lost_report_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_lost_report_notifications_user_id
ON lost_report_notifications(user_id);

CREATE INDEX IF NOT EXISTS idx_lost_report_notifications_created_at
ON lost_report_notifications(created_at DESC);
