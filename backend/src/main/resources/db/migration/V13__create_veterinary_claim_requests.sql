CREATE TABLE IF NOT EXISTS veterinary_claim_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    institution_id BIGINT NOT NULL,
    status TEXT NOT NULL,
    request_note TEXT NULL,
    approval_token TEXT NOT NULL UNIQUE,
    rejection_token TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    reviewed_at TIMESTAMPTZ NULL,
    CONSTRAINT fk_veterinary_claim_requests_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_veterinary_claim_requests_institution
        FOREIGN KEY (institution_id)
        REFERENCES institutions(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_veterinary_claim_requests_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

CREATE INDEX IF NOT EXISTS idx_veterinary_claim_requests_user_id
ON veterinary_claim_requests(user_id);

CREATE INDEX IF NOT EXISTS idx_veterinary_claim_requests_institution_id
ON veterinary_claim_requests(institution_id);

CREATE UNIQUE INDEX IF NOT EXISTS uk_veterinary_claim_requests_pending
ON veterinary_claim_requests(user_id, institution_id)
WHERE status = 'PENDING';
