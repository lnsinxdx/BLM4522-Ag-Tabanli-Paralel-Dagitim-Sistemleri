-- Veri kalitesi profilleme: "oncesi" metriklerinin cikarilmasi
-- Bu metrikler Faz 5'te temizleme sonrasi degerlerle karsilastirilacak

USE Proje5_ETL;
GO

-- Metriklerin saklanacagi tablo (oncesi/sonrasi karsilastirmasi icin)
IF OBJECT_ID('dbo.VeriKalitesiMetrik') IS NOT NULL DROP TABLE dbo.VeriKalitesiMetrik;
GO

CREATE TABLE dbo.VeriKalitesiMetrik
(
    MetrikID    INT IDENTITY(1,1) PRIMARY KEY,
    Asama       NVARCHAR(20),       -- 'oncesi' veya 'sonrasi'
    MetrikAdi   NVARCHAR(100),
    Deger       INT,
    OlcumZamani DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- "Oncesi" metriklerini hesaplayip tabloya yaz
INSERT INTO dbo.VeriKalitesiMetrik (Asama, MetrikAdi, Deger)
SELECT 'oncesi', 'Toplam kayit', COUNT(*) FROM kaynak.Musteri_Ham
UNION ALL
SELECT 'oncesi', 'Bos/NULL ad', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE AdSoyad IS NULL OR LTRIM(RTRIM(AdSoyad)) = ''
UNION ALL
SELECT 'oncesi', 'NULL email', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE Email IS NULL
UNION ALL
SELECT 'oncesi', 'Gecersiz email formati', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE Email IS NOT NULL AND Email NOT LIKE '%_@_%._%'
UNION ALL
SELECT 'oncesi', 'NULL telefon', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE Telefon IS NULL
UNION ALL
SELECT 'oncesi', 'Gecersiz telefon (rakam yok)', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE Telefon IS NOT NULL AND Telefon NOT LIKE '%[0-9]%'
UNION ALL
SELECT 'oncesi', 'Bos/NULL ulke', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE Ulke IS NULL OR LTRIM(RTRIM(Ulke)) = ''
UNION ALL
SELECT 'oncesi', 'Farkli ulke degeri sayisi', COUNT(DISTINCT LTRIM(RTRIM(LOWER(Ulke)))) FROM kaynak.Musteri_Ham
    WHERE Ulke IS NOT NULL AND LTRIM(RTRIM(Ulke)) <> ''
UNION ALL
SELECT 'oncesi', 'Bos/NULL dogum tarihi', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE DogumTarihi IS NULL OR LTRIM(RTRIM(DogumTarihi)) = ''
UNION ALL
SELECT 'oncesi', 'Gelecek tarihli dogum tarihi', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE TRY_CONVERT(date, DogumTarihi) > CAST(GETDATE() AS date)
UNION ALL
SELECT 'oncesi', 'Bastaki/sondaki bosluk iceren kayit', COUNT(*) FROM kaynak.Musteri_Ham
    WHERE (AdSoyad IS NOT NULL AND AdSoyad <> LTRIM(RTRIM(AdSoyad)))
       OR (Email   IS NOT NULL AND Email   <> LTRIM(RTRIM(Email)))
       OR (Ulke    IS NOT NULL AND Ulke    <> LTRIM(RTRIM(Ulke)));
GO

-- Mukerrer kayitlar (normalize edilmis email bazli)
;WITH Normalize AS (
    SELECT LTRIM(RTRIM(LOWER(Email))) AS NormEmail
    FROM kaynak.Musteri_Ham
    WHERE Email IS NOT NULL AND LTRIM(RTRIM(Email)) <> ''
)
INSERT INTO dbo.VeriKalitesiMetrik (Asama, MetrikAdi, Deger)
SELECT 'oncesi', 'Mukerrer kayit (email bazli, fazladan)',
       COUNT(*) - COUNT(DISTINCT NormEmail)
FROM Normalize;
GO

-- Ozet: oncesi kalite metrikleri
SELECT MetrikAdi, Deger
FROM dbo.VeriKalitesiMetrik
WHERE Asama = 'oncesi'
ORDER BY MetrikID;
GO

-- Kanit: bilerek eklenen kirli kayitlari listele (rapor ekran goruntusu icin)
SELECT * FROM kaynak.Musteri_Ham WHERE HamID > 500 ORDER BY HamID;
GO
