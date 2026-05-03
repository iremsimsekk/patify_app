ALTER TABLE institutions
ADD COLUMN IF NOT EXISTS city TEXT NULL,
ADD COLUMN IF NOT EXISTS email TEXT NULL;

ALTER TABLE institutions
DROP CONSTRAINT IF EXISTS chk_institutions_type;

ALTER TABLE institutions
ADD CONSTRAINT chk_institutions_type
CHECK (lower(type) IN ('clinic', 'shelter', 'veterinary'));

INSERT INTO institutions (
    type,
    name,
    phone,
    address,
    district,
    city,
    description,
    external_source_id,
    email,
    created_at,
    updated_at
)
SELECT
    'veterinary',
    'Test Veteriner Kliniği',
    NULL,
    'TED Üniversitesi, Ziya Gökalp Caddesi No: 47 - 48, 06420 Kolej, Çankaya / Ankara',
    'Çankaya',
    'Ankara',
    'Bu kayıt veteriner paneli testleri için oluşturulmuş sahte kliniktir.',
    'manual:test-veterinary-clinic-ted',
    'nairmerve63@gmail.com',
    now(),
    now()
WHERE NOT EXISTS (
    SELECT 1
    FROM institutions
    WHERE external_source_id = 'manual:test-veterinary-clinic-ted'
);

INSERT INTO locations (institution_id, latitude, longitude)
SELECT i.id, 39.9208, 32.8541
FROM institutions i
WHERE i.external_source_id = 'manual:test-veterinary-clinic-ted'
  AND NOT EXISTS (
      SELECT 1
      FROM locations l
      WHERE l.institution_id = i.id
  );
