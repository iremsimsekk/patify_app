CREATE TABLE IF NOT EXISTS appointment_slots (
    id BIGSERIAL PRIMARY KEY,
    veterinarian_user_id BIGINT NOT NULL,
    institution_id BIGINT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'AVAILABLE',
    booked_by_user_id BIGINT NULL,
    booked_by_first_name TEXT NULL,
    booked_by_last_name TEXT NULL,
    booked_by_email TEXT NULL,
    note TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_appointment_slots_veterinarian
        FOREIGN KEY (veterinarian_user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_appointment_slots_institution
        FOREIGN KEY (institution_id)
        REFERENCES institutions(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_appointment_slots_booked_by_user
        FOREIGN KEY (booked_by_user_id)
        REFERENCES users(id)
        ON DELETE SET NULL,
    CONSTRAINT chk_appointment_slots_status
        CHECK (status IN ('AVAILABLE', 'BOOKED', 'CANCELLED')),
    CONSTRAINT chk_appointment_slots_time_range
        CHECK (end_time > start_time)
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_appointment_slots_veterinarian_start
ON appointment_slots(veterinarian_user_id, start_time);

CREATE INDEX IF NOT EXISTS idx_appointment_slots_institution_start
ON appointment_slots(institution_id, start_time);

CREATE INDEX IF NOT EXISTS idx_appointment_slots_status_start
ON appointment_slots(status, start_time);
