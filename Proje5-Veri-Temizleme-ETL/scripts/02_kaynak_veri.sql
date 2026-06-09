-- Ham (kirli) musteri verisinin staging tablosuna yuklenmesi

USE Proje5_ETL;
GO

IF OBJECT_ID('kaynak.Musteri_Ham') IS NOT NULL DROP TABLE kaynak.Musteri_Ham;
GO

CREATE TABLE kaynak.Musteri_Ham
(
    HamID        INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad      NVARCHAR(200),
    Email        NVARCHAR(200),
    Telefon      NVARCHAR(50),
    Ulke         NVARCHAR(100),
    DogumTarihi  NVARCHAR(50),   -- bilerek metin: tarih formati tutarsizligini gostermek icin
    KayitTarihi  NVARCHAR(50)
);
GO

-- Gercekci hacim icin AdventureWorks'ten bir alt kume cekiyoruz
INSERT INTO kaynak.Musteri_Ham (AdSoyad, Email, Telefon, Ulke, DogumTarihi, KayitTarihi)
SELECT TOP (500)
    p.FirstName + ' ' + p.LastName,
    ea.EmailAddress,
    pp.PhoneNumber,
    'United States',
    NULL,
    CONVERT(varchar(10), GETDATE(), 120)
FROM AdventureWorks2022.Person.Person p
LEFT JOIN AdventureWorks2022.Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN AdventureWorks2022.Person.PersonPhone  pp ON p.BusinessEntityID = pp.BusinessEntityID
WHERE p.PersonType = 'IN';
GO

-- Temizleme kurallarini gostermek icin bilerek eklenmis kirli kayitlar
INSERT INTO kaynak.Musteri_Ham (AdSoyad, Email, Telefon, Ulke, DogumTarihi, KayitTarihi) VALUES
(N'  ahmet   yILMAZ ', N'AHMET.yilmaz@MAIL.COM ', N'0532 111 22 33',     N'turkey',        N'1990-05-12', N'2024-01-10'),
(N'ahmet yilmaz',      N'ahmet.yilmaz@mail.com',  N'05321112233',        N'Türkiye',       N'12/05/1990', N'2024-01-10'), -- ayni kisi, farkli format (duplicate)
(N'Mehmet Demir',      NULL,                      N'+90 (533) 444-5566', N'TR',            N'1985.08.30', N'10-01-2024'),  -- email NULL
(N'zeynep KAYA',       N'zeynep[at]mail.com',     N'533-555-6677',       N'Turkiye',       N'2031-02-15', N'2024-02-01'),  -- bozuk email + gelecek dogum tarihi
(N'',                  N'bos.isim@mail.com',      NULL,                  N'',              N'1992-11-03', NULL),           -- bos isim/ulke, NULL telefon
(N'Ali Veli',          N'ali.veli@mail',          N'abc',                N'United Statez', N'',           N'2024/03/12');  -- gecersiz email/telefon, yazim hatali ulke
GO

-- Yuklemeyi dogrula
SELECT COUNT(*) AS ToplamKayit FROM kaynak.Musteri_Ham;
SELECT TOP 10 * FROM kaynak.Musteri_Ham ORDER BY HamID DESC;
GO
