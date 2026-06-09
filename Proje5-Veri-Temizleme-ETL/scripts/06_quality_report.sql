-- Faz 5: Veri kalitesi raporu - "sonrasi" metrikleri ve oncesi/sonrasi karsilastirmasi

USE Proje5_ETL;
GO

-- Onceki "sonrasi" olcumlerini temizle (tekrar calistirilabilir olsun)
DELETE FROM dbo.VeriKalitesiMetrik WHERE Asama = 'sonrasi';
GO

-- Temizleme sonrasi metrikleri hedef tablodan hesapla
INSERT INTO dbo.VeriKalitesiMetrik (Asama, MetrikAdi, Deger)
SELECT 'sonrasi', 'Toplam kayit', COUNT(*) FROM hedef.Musteri
UNION ALL
SELECT 'sonrasi', 'Bos/NULL ad', COUNT(*) FROM hedef.Musteri
    WHERE AdSoyad IS NULL OR LTRIM(RTRIM(AdSoyad)) = ''
UNION ALL
SELECT 'sonrasi', 'NULL email', COUNT(*) FROM hedef.Musteri
    WHERE Email IS NULL
UNION ALL
SELECT 'sonrasi', 'Gecersiz email formati', COUNT(*) FROM hedef.Musteri
    WHERE Email IS NOT NULL AND Email NOT LIKE '%_@_%._%'
UNION ALL
SELECT 'sonrasi', 'NULL telefon', COUNT(*) FROM hedef.Musteri
    WHERE Telefon IS NULL
UNION ALL
SELECT 'sonrasi', 'Gecersiz telefon (rakam yok)', COUNT(*) FROM hedef.Musteri
    WHERE Telefon IS NOT NULL AND Telefon NOT LIKE '%[0-9]%'
UNION ALL
SELECT 'sonrasi', 'Bos/NULL ulke', COUNT(*) FROM hedef.Musteri
    WHERE Ulke IS NULL OR LTRIM(RTRIM(Ulke)) = ''
UNION ALL
SELECT 'sonrasi', 'Farkli ulke degeri sayisi', COUNT(DISTINCT Ulke) FROM hedef.Musteri
    WHERE Ulke IS NOT NULL
UNION ALL
SELECT 'sonrasi', 'Bos/NULL dogum tarihi', COUNT(*) FROM hedef.Musteri
    WHERE DogumTarihi IS NULL
UNION ALL
SELECT 'sonrasi', 'Gelecek tarihli dogum tarihi', COUNT(*) FROM hedef.Musteri
    WHERE DogumTarihi > CAST(GETDATE() AS date)
UNION ALL
SELECT 'sonrasi', 'Bastaki/sondaki bosluk iceren kayit', COUNT(*) FROM hedef.Musteri
    WHERE (AdSoyad IS NOT NULL AND AdSoyad <> LTRIM(RTRIM(AdSoyad)))
       OR (Email   IS NOT NULL AND Email   <> LTRIM(RTRIM(Email)))
       OR (Ulke    IS NOT NULL AND Ulke    <> LTRIM(RTRIM(Ulke)))
UNION ALL
SELECT 'sonrasi', 'Mukerrer kayit (email bazli, fazladan)',
       COUNT(*) - COUNT(DISTINCT Email)
    FROM hedef.Musteri WHERE Email IS NOT NULL;
GO

-- Oncesi / Sonrasi karsilastirma raporu
SELECT o.MetrikAdi,
       o.Deger AS Oncesi,
       s.Deger AS Sonrasi,
       s.Deger - o.Deger AS Fark
FROM (SELECT MetrikID, MetrikAdi, Deger FROM dbo.VeriKalitesiMetrik WHERE Asama = 'oncesi') o
JOIN (SELECT MetrikAdi, Deger FROM dbo.VeriKalitesiMetrik WHERE Asama = 'sonrasi') s
    ON o.MetrikAdi = s.MetrikAdi
ORDER BY o.MetrikID;
GO
