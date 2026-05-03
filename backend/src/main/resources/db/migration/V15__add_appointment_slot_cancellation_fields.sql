ALTER TABLE appointment_slots
    ADD COLUMN IF NOT EXISTS cancellation_reason TEXT NULL;

ALTER TABLE appointment_slots
    ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ NULL;

ALTER TABLE appointment_slots
    ADD COLUMN IF NOT EXISTS cancellation_source TEXT NULL;
