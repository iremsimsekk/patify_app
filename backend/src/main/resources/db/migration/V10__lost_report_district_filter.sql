ALTER TABLE users
ADD COLUMN IF NOT EXISTS district TEXT;

ALTER TABLE lost_reports
ADD COLUMN IF NOT EXISTS district TEXT;

CREATE INDEX IF NOT EXISTS idx_users_district
ON users(district);

CREATE INDEX IF NOT EXISTS idx_lost_reports_district
ON lost_reports(district);
