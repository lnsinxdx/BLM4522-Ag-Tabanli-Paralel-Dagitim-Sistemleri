-- Faz 3: Veri temizleme ve donusturme
-- Ham veriyi temizleyip dogru tiplerle temiz.Musteri_Temiz tablosuna yazar

USE Proje5_ETL;
GO

-- Isim duzeltme yardimci fonksiyonu: trim + coklu bosluk sadelestir + Proper Case
-- (compatibility level'dan bagimsiz calissin diye dongu tabanli yazildi)
CREATE OR ALTER FUNCTION dbo.ProperCase (@metin NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @t NVARCHAR(200) = LTRIM(RTRIM(ISNULL(@metin, '')));
    WHILE CHARINDEX('  ', @t) > 0          -- coklu bosluklari teke indir
        SET @t = REPLACE(@t, '  ', ' ');
    IF @t = '' RETURN NULL;                -- tamamen bos isim -> NULL

    DECLARE @sonuc NVARCHAR(200) = '', @i INT = 1, @yeni BIT = 1, @c NCHAR(1);
    WHILE @i <= LEN(@t)
    BEGIN
        SET @c = SUBSTRING(@t, @i, 1);
        IF @c = ' '
            SELECT @sonuc += @c, @yeni = 1;
        ELSE
            SELECT @sonuc += CASE WHEN @yeni = 1 THEN UPPER(@c) ELSE LOWER(@c) END, @yeni = 0;
        SET @i += 1;
    END
    RETURN @sonuc;
END;
GO

-- Temiz tablo (dogru veri tipleriyle)
IF OBJECT_ID('temiz.Musteri_Temiz') IS NOT NULL DROP TABLE temiz.Musteri_Temiz;
GO

CREATE TABLE temiz.Musteri_Temiz
(
    TemizID      INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad      NVARCHAR(200),
    Email        NVARCHAR(200),
    Telefon      NVARCHAR(50),
    Ulke         NVARCHAR(100),
    DogumTarihi  DATE,
    KayitTarihi  DATE
);
GO

-- Temizleme + donusturme + mukerrer kayit eleme
;WITH Temizlenmis AS (
    SELECT
        m.HamID,
        dbo.ProperCase(m.AdSoyad) AS AdSoyad,

        -- email: kucuk harf + trim; gecersiz format ise NULL
        CASE WHEN LTRIM(RTRIM(LOWER(m.Email))) LIKE '%_@_%._%'
             THEN LTRIM(RTRIM(LOWER(m.Email))) ELSE NULL END AS Email,

        -- telefon: ayraclari at (sadece rakam); rakam disinda karakter varsa NULL
        CASE WHEN tel.Temiz LIKE '%[^0-9]%' OR tel.Temiz = '' THEN NULL
             ELSE tel.Temiz END AS Telefon,

        -- ulke: varyasyonlari standart degere esle
        CASE
            WHEN LTRIM(RTRIM(LOWER(m.Ulke))) IN ('turkey','türkiye','turkiye','tr') THEN N'Türkiye'
            WHEN LTRIM(RTRIM(LOWER(m.Ulke))) IN ('united states','united statez','usa','us') THEN N'United States'
            WHEN m.Ulke IS NULL OR LTRIM(RTRIM(m.Ulke)) = '' THEN NULL
            ELSE LTRIM(RTRIM(m.Ulke))
        END AS Ulke,

        -- dogum tarihi: farkli formatlari dene; gelecek tarih/cozulemeyen ise NULL
        CASE WHEN dt.Parsed > CAST(GETDATE() AS date) THEN NULL ELSE dt.Parsed END AS DogumTarihi,

        kt.Parsed AS KayitTarihi
    FROM kaynak.Musteri_Ham m
    CROSS APPLY (VALUES (
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(m.Telefon,''),' ',''),'(',''),')',''),'-',''),'+','')
    )) AS tel(Temiz)
    CROSS APPLY (VALUES (
        COALESCE(TRY_CONVERT(date,m.DogumTarihi,23), TRY_CONVERT(date,m.DogumTarihi,102),
                 TRY_CONVERT(date,m.DogumTarihi,103), TRY_CONVERT(date,m.DogumTarihi,104),
                 TRY_CONVERT(date,m.DogumTarihi,105), TRY_CONVERT(date,m.DogumTarihi))
    )) AS dt(Parsed)
    CROSS APPLY (VALUES (
        COALESCE(TRY_CONVERT(date,m.KayitTarihi,23), TRY_CONVERT(date,m.KayitTarihi,111),
                 TRY_CONVERT(date,m.KayitTarihi,103), TRY_CONVERT(date,m.KayitTarihi,105),
                 TRY_CONVERT(date,m.KayitTarihi))
    )) AS kt(Parsed)
),
SiraNo AS (
    SELECT *,
        -- ayni email icin tek kayit birak; email NULL ise her satir benzersiz kalsin
        ROW_NUMBER() OVER (
            PARTITION BY COALESCE(Email, 'h' + CAST(HamID AS NVARCHAR(20)))
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM Temizlenmis
)
INSERT INTO temiz.Musteri_Temiz (AdSoyad, Email, Telefon, Ulke, DogumTarihi, KayitTarihi)
SELECT AdSoyad, Email, Telefon, Ulke, DogumTarihi, KayitTarihi
FROM SiraNo
WHERE rn = 1
  AND AdSoyad IS NOT NULL;   -- adi tespit edilemeyen kayitlari alma
GO

-- Sonuc kontrolu
SELECT COUNT(*) AS TemizKayitSayisi FROM temiz.Musteri_Temiz;

-- Daha once kirli olan kayitlarin temizlenmis hali (rapor ekran goruntusu icin)
SELECT * FROM temiz.Musteri_Temiz
WHERE AdSoyad IN (N'Ahmet Yilmaz', N'Mehmet Demir', N'Zeynep Kaya', N'Ali Veli')
ORDER BY AdSoyad;
GO
