# Proje 4 — Veritabanı Yük Dengeleme ve Dağıtık Veritabanı Yapıları

AdventureWorks2022 üzerinde çoğaltma (replication), yük dengeleme ve failover senaryoları.

## Mimari
- İki SQL Server örneği (Instance A: birincil, Instance B: ikincil)
- Transactional Replication (Yayıncı → Dağıtıcı → Abone)
- Always On read-scale (clusterless) Availability Group
- Veritabanı: AdventureWorks2022

## Aşamalar
1. Kurulum ve mimari
2. Replikasyon
3. Yük dengeleme (read-scale AG)
4. Failover senaryoları
5. İzleme ve doğrulama
6. Rapor

## Klasörler
- `scripts/` — SQL ve yapılandırma betikleri
- `screenshots/` — ekran görüntüleri
- `report/` — proje raporu
