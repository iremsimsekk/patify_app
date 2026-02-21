# patify_app

Docker Desktop açık olmalı (motor).

Container’lar da çalışıyor olmalı.

Ama her seferinde rebuild gerekmez.

Günlük kullanım

Çalıştır:

docker compose up -d

Durdur:

docker compose down

DB verisi silinmesin istiyorsanız down -v kullanmayın.

Kod değiştiyse (backend güncellendiyse)

Yeni kod image’a girmeli:

docker compose up -d --build