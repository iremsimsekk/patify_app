ALTER TABLE institutions
ADD COLUMN IF NOT EXISTS external_source_id TEXT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uk_institutions_external_source_id
ON institutions(external_source_id)
WHERE external_source_id IS NOT NULL;
