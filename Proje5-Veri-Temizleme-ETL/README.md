# Proje 5 — Veri Temizleme ve ETL Süreçleri Tasarımı

BLM4522 Ağ Tabanlı Paralel Dağıtık Sistemler

AdventureWorks2022 verisinden uçtan uca ETL (Extract – Transform – Load) süreci.
Eksik/hatalı/tutarsız müşteri verisi temizlenir, standartlaştırılır ve hedef tabloya yüklenir.

## Ortam
- SQL Server (MSSQL) — AdventureWorks2022
- Windows VM (Parallels / macOS)
- Çalışma veritabanı: Proje5_ETL (şemalar: kaynak, temiz, hedef)

## Betikler
- `scripts/01_setup.sql` — veritabanı ve şemalar
- `scripts/02_source_data.sql` — kaynak (kirli) verinin hazırlanması
- `scripts/03_profiling.sql` — profilleme ve "öncesi" metrikler
- `scripts/04_transform.sql` — temizleme ve dönüştürme
- `scripts/05_load.sql` — hedef tabloya MERGE ile yükleme
- `scripts/06_quality_report.sql` — öncesi/sonrası kalite raporu

## Klasörler
- `scripts/` — SQL betikleri
- `screenshots/` — ekran görüntüleri
- `report/` — proje raporu
