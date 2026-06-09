-- Faz 4: Load - temiz veriyi hedef tabloya yukleme (MERGE / upsert)

USE Proje5_ETL;
GO

-- Hedef tablo
IF OBJECT_ID('hedef.Musteri') IS NOT NULL DROP TABLE hedef.Musteri;
GO

CREATE TABLE hedef.Musteri
(
    MusteriID     INT IDENTITY(1,1) PRIMARY KEY,
    IsAnahtari    NVARCHAR(250) NOT NULL UNIQUE,   -- is anahtari (email yoksa ad+telefon)
    AdSoyad       NVARCHAR(200),
    Email         NVARCHAR(200),
    Telefon       NVARCHAR(50),
    Ulke          NVARCHAR(100),
    DogumTarihi   DATE,
    KayitTarihi   DATE,
    YuklemeZamani DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- Kaynak: temiz veriden is anahtari uret, anahtara gore tekillestir, sonra MERGE
;WITH Kaynak AS (
    SELECT
        COALESCE(NULLIF(Email, ''), LOWER(AdSoyad) + '|' + ISNULL(Telefon, '')) AS IsAnahtari,
        AdSoyad, Email, Telefon, Ulke, DogumTarihi, KayitTarihi, TemizID,
        ROW_NUMBER() OVER (
            PARTITION BY COALESCE(NULLIF(Email, ''), LOWER(AdSoyad) + '|' + ISNULL(Telefon, ''))
            ORDER BY TemizID
        ) AS rn
    FROM temiz.Musteri_Temiz
)
MERGE hedef.Musteri AS h
USING (SELECT * FROM Kaynak WHERE rn = 1) AS k
    ON h.IsAnahtari = k.IsAnahtari
WHEN MATCHED THEN
    UPDATE SET
        h.AdSoyad = k.AdSoyad, h.Email = k.Email, h.Telefon = k.Telefon,
        h.Ulke = k.Ulke, h.DogumTarihi = k.DogumTarihi, h.KayitTarihi = k.KayitTarihi,
        h.YuklemeZamani = SYSDATETIME()
WHEN NOT MATCHED THEN
    INSERT (IsAnahtari, AdSoyad, Email, Telefon, Ulke, DogumTarihi, KayitTarihi)
    VALUES (k.IsAnahtari, k.AdSoyad, k.Email, k.Telefon, k.Ulke, k.DogumTarihi, k.KayitTarihi);
GO

-- Yukleme sonucu
SELECT COUNT(*) AS HedefKayitSayisi FROM hedef.Musteri;
SELECT TOP 10 MusteriID, AdSoyad, Email, Telefon, Ulke, DogumTarihi
FROM hedef.Musteri ORDER BY MusteriID;
GO
