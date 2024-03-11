
--METE TABLOLAR

--1
CREATE TABLE Ogrenciler (
    OgrenciNo VARCHAR2(30) PRIMARY KEY,
    Ad VARCHAR2(50) not null,
    Soyad VARCHAR2(50) not null,
    DogumTarihi DATE not null,
    Cinsiyet VARCHAR2(10) not null,
    IletisimNumarasi VARCHAR2(20) not null,
    Eposta VARCHAR2(100) not null,
    Adres VARCHAR2(255) not null
);

--2
CREATE TABLE OgretimGorevlileri(
    OgretimGorevlisiID NUMBER PRIMARY KEY,
    Ad VARCHAR2(50) not null,
    Soyad VARCHAR2(50) not null,
    IletisimNumarasi VARCHAR2(20) not null,
    Eposta VARCHAR2(100) not null
);

--3
CREATE TABLE Dersler (												
    DersID NUMBER PRIMARY KEY,
    OgretimGorevlisiID NUMBER not null,
    DersAdi VARCHAR2(100) not null,
    DersAciklamasi VARCHAR2(255) not null,
    KrediSaatleri NUMBER not null,
    CONSTRAINT fk_key_ders_hoca FOREIGN KEY(OgretimGorevlisiID) REFERENCES OgretimGorevlileri(OgretimGorevlisiID)
);

--4
CREATE TABLE Kayitlar (
    KayitID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30) NOT NULL,
    DersID NUMBER not null,
    KayitTarihi DATE not null,
    Notu VARCHAR2(2) not null,
    CONSTRAINT fk_key1 FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo),
    CONSTRAINT fk_key2 FOREIGN KEY (DersID) REFERENCES Dersler(DersID)
);

--5
CREATE TABLE Siniflar (
    SinifID NUMBER PRIMARY KEY,
    OgretimGorevlisiID NUMBER NOT NULL,
    OgrenciNo varchar2(30) NOT NULL,
    OdaNumarasi VARCHAR2(20) NOT NULL ,
    Kapasite NUMBER,
    CONSTRAINT fk_key4 FOREIGN KEY(OgretimGorevlisiID) REFERENCES OgretimGorevlileri(OgretimGorevlisiID),
    CONSTRAINT fk_key5 FOREIGN KEY(OgrenciNo) REFERENCES Ogrenciler(OgrenciNo)
);


--Said Tablolar

--1
CREATE TABLE Projeler (
    ProjeID NUMBER PRIMARY KEY,
    ProjeAdi VARCHAR2(255),
    DersID NUMBER,
    SonTeslimTarihi DATE,
    MaksimumPuan NUMBER,
    CONSTRAINT fk_ders_proje FOREIGN KEY (DersID) REFERENCES Dersler(DersID)
);

--2
CREATE TABLE DersMateryalleri (
    MateryalID NUMBER PRIMARY KEY,
    DersID NUMBER REFERENCES Dersler(DersID),
    MateryalAdi VARCHAR2(255),
    MateryalTuru VARCHAR2(50),
    YuklemeTarihi DATE
);

--3
CREATE TABLE Notlar (
    NotID NUMBER PRIMARY KEY,
    KayitID NUMBER,
    ProjeID NUMBER,
    Puan NUMBER,
    CONSTRAINT fk_kayit_not FOREIGN KEY (KayitID) REFERENCES Kayitlar(KayitID),
    CONSTRAINT fk_proje_not FOREIGN KEY (ProjeID) REFERENCES Projeler(ProjeID)
);

--4
CREATE TABLE Devamsizlik (
    DevamsizlikID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30),
    SinifID NUMBER,
    DevamsizlikTarihi DATE,
    Durum VARCHAR2(20),
    CONSTRAINT fk_ogrenci_devamsizlik FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo),
    CONSTRAINT fk_sinif_devamsizlik FOREIGN KEY (SinifID) REFERENCES Siniflar(SinifID)
);

--5
CREATE TABLE Donemler (
    DonemID NUMBER PRIMARY KEY,
    DonemAdi VARCHAR2(50),
    BaslangicTarihi DATE,
    BitisTarihi DATE
);



--METE VERÝLER

--1
insert into ogrenciler values(
'213301032','Ali','Keskin',to_date('2002-12-12','yyyy-mm-dd'),'Erkek','05467896783','AlKesk@gmail.com','KaraKýþla Mah. ,Serçe Sok. ,Kat 1 Daire 10, Kocaeli/Derince');
insert into ogrenciler values(
'213301033','Ayþe','Duman',to_date('2002-7-10','yyyy-mm-dd'),'Kýz','05338900875','AyþeDum@gmail.com','Melek Mah. ,Karga Sok. ,Kat 3 Daire 5, Sakarya/Arifiye');
insert into ogrenciler values(
'203301054','Zillet','Kara',to_date('2001-3-22','yyyy-mm-dd'),'Kýz','05552903815','ZillKar@gmail.com','Mavi Mah. ,Papatya Sok. ,Kat 1 Daire 7, Sakarya/Serdivan');
-- Ekstralar
INSERT INTO ogrenciler VALUES (
    '213301901', 'Burak', 'Yýlmaz', TO_DATE('2003-05-18', 'YYYY-MM-DD'), 'Erkek', '05551234567', 'burak@example.com', 'Güneþ Mah., Ay Sok., Kat 2 Daire 3, Ýstanbul/Kadýköy');
INSERT INTO ogrenciler VALUES (
    '213301902', 'Deniz', 'Demir', TO_DATE('2002-10-29', 'YYYY-MM-DD'), 'Kýz', '05557654321', 'deniz@example.com', 'Deniz Mah., Dal Sok., Kat 4 Daire 9, Ýzmir/Konak');
INSERT INTO ogrenciler VALUES (
    '213301903', 'Emre', 'Güneþ', TO_DATE('2003-01-15', 'YYYY-MM-DD'), 'Erkek', '05558776655', 'emre@example.com', 'Yýldýz Mah., Gül Sok., Kat 5 Daire 12, Ankara/Çankaya');
INSERT INTO ogrenciler VALUES (
    '213301904', 'Fatma', 'Kara', TO_DATE('2002-08-05', 'YYYY-MM-DD'), 'Kýz', '05559998877', 'fatma@example.com', 'Akasya Mah., Zambak Sok., Kat 3 Daire 8, Bursa/Osmangazi');
INSERT INTO ogrenciler VALUES (
    '213301905', 'Gökhan', 'Kurt', TO_DATE('2003-11-20', 'YYYY-MM-DD'), 'Erkek', '05556667788', 'gokhan@example.com', 'Bahçe Mah., Menekþe Sok., Kat 1 Daire 6, Ýzmir/Buca');
INSERT INTO ogrenciler VALUES (
    '213301906', 'Hande', 'Yýldýz', TO_DATE('2002-04-25', 'YYYY-MM-DD'), 'Kýz', '05553332211', 'hande@example.com', 'Çiçek Mah., Zeytin Sok., Kat 7 Daire 15, Ýstanbul/Beyoðlu');
INSERT INTO ogrenciler VALUES (
    '213301907', 'Ýbrahim', 'Can', TO_DATE('2003-07-30', 'YYYY-MM-DD'), 'Erkek', '05554449999', 'ibrahim@example.com', 'Palmiye Mah., Papatya Sok., Kat 2 Daire 4, Ankara/Mamak');

--2
insert into ogretimgorevlileri values(1,'Kemal','Parlak','05898769080','ParlakKem@gmail.com');
insert into ogretimgorevlileri values(2,'Cemil','Razý','05795763041','CemRaz@gmail.com');

--3
insert into dersler values(1,1,'Veri Tabaný Programlama','Oracle üzerinden veri tabaný programlama iþlemleri',4);
insert into dersler values(2,2,'Veri Madenciliði','Makine öðrenimi algoritmalarýyla çekilen verinin yorumlanmasý','4');
insert into dersler values(3,2,'Programlama Dili','C# .Net eðitimi','3');

--4
insert into kayitlar values(1,'213301032',1,to_date('2021-9-12','yyyy-mm-dd'),'A');
insert into kayitlar values(2,'213301033',1,to_date('2021-9-12','yyyy-mm-dd'),'B');
insert into kayitlar values(3,'203301054',2,to_date('2021-9-12','yyyy-mm-dd'),'C');
insert into kayitlar values(5,'213301032',2,to_date('2021-9-12','yyyy-mm-dd'),'B');
insert into kayitlar values(7,'213301032',3,to_date('2021-9-12','yyyy-mm-dd'),'D');

--5
insert into siniflar values(1,1,'213301032','210',100);
insert into siniflar values(2,2,'213301033','210',200);
insert into siniflar values(3,1,'203301054','222',100);


--Girdiler

--1
INSERT INTO Projeler (ProjeID, ProjeAdi, DersID, SonTeslimTarihi, MaksimumPuan)
VALUES (1, 'Veritabaný Programlama', 1, TO_DATE('2024-01-04', 'YYYY-MM-DD'), 40);
INSERT INTO Projeler (ProjeID, ProjeAdi, DersID, SonTeslimTarihi, MaksimumPuan)
VALUES (2, 'Veri Madenciligi', 2, TO_DATE('2024-01-11', 'YYYY-MM-DD'), 100);
    
--2
INSERT INTO DersMateryalleri (MateryalID, DersID, MateryalAdi, MateryalTuru, YuklemeTarihi)
VALUES (1, 1, 'Ders Notlarý', 'PDF', TO_DATE('2023-08-10', 'YYYY-MM-DD'));
INSERT INTO DersMateryalleri (MateryalID, DersID, MateryalAdi, MateryalTuru, YuklemeTarihi)
VALUES (2, 2, 'Sunum Dosyasý', 'PPT', TO_DATE('2023-06-05', 'YYYY-MM-DD'));
   
--3
INSERT INTO Notlar (NotID, KayitID, ProjeID, Puan)
VALUES (1, 1, 1, 40);
INSERT INTO Notlar (NotID, KayitID, ProjeID, Puan)
VALUES (2, 2, 2, 100);

--4
INSERT INTO Devamsizlik (DevamsizlikID, OgrenciNo, SinifID, DevamsizlikTarihi, Durum)
VALUES (1, '213301032', 1, TO_DATE('2023-11-10', 'YYYY-MM-DD'), 'Gelmedi');
INSERT INTO Devamsizlik (DevamsizlikID, OgrenciNo, SinifID, DevamsizlikTarihi, Durum)
VALUES (2, '213301033', 2, TO_DATE('2023-10-05', 'YYYY-MM-DD'), 'Gelmedi');

--5
INSERT INTO Donemler (DonemID, DonemAdi, BaslangicTarihi, BitisTarihi)
VALUES (1, '2024 Bahar', TO_DATE('2023-10-02', 'YYYY-MM-DD'), TO_DATE('2024-01-12', 'YYYY-MM-DD'));
INSERT INTO Donemler (DonemID, DonemAdi, BaslangicTarihi, BitisTarihi)
VALUES (2, '2024 Guz', TO_DATE('2024-02-12', 'YYYY-MM-DD'), TO_DATE('2024-05-31', 'YYYY-MM-DD'));


--Prosedürler

--Prosedür 1
CREATE OR REPLACE PROCEDURE UpdateProjeler
AS
BEGIN
  UPDATE Projeler SET MaksimumPuan = 0 WHERE SonTeslimTarihi < SYSDATE;
END UpdateProjeler;


--Prosedür 1'i aktifleþtiren kod
exec UpdateProjeler;

--Prosedür 2
CREATE OR REPLACE PROCEDURE DersMatGoster
AS
  CURSOR curMateryaller IS
    SELECT materyalýd, materyaladý FROM dersmateryallerý;
BEGIN
  FOR mat IN curMateryaller
  LOOP
    DBMS_OUTPUT.PUT_LINE('Materyal ID: ' || mat.MateryalID || ', Materyal Adý: ' || mat.MateryalAdi);
  END LOOP;
END DersMatGoster;


--Prosedür 2'yi çalýþtýran kod
exec DersMatGoster;


--Fonskiyonlar

--Fonksiyon 1
CREATE OR REPLACE TYPE ProjeTut AS OBJECT
(
    ProjeID NUMBER,
    ProjeAdi VARCHAR2(255),
    SonTeslimTarihi DATE,
    MaksimumPuan NUMBER
);


CREATE OR REPLACE TYPE ProjeTutSatir AS TABLE OF ProjeTut;


CREATE OR REPLACE FUNCTION Projelerfunc(p_ProjeID IN NUMBER) RETURN ProjeTutSatir IS
    sonuc ProjeTutSatir := new ProjeTutSatir();
BEGIN
    FOR satir IN (SELECT * FROM projeler WHERE ProjeID = p_ProjeID) LOOP
        sonuc.extend;
        sonuc(sonuc.count) := new ProjeTut(satir.ProjeID, satir.ProjeAdi, satir.SonTeslimTarihi, satir.MaksimumPuan);
    END LOOP;
    RETURN sonuc;
END;

--Fonksiyon 1'i çalýþtýran kod
select * from table(ProjelerFunc(1));

--Fonksiyon 2
create or replace FUNCTION HesaplaProjeYuzdesi (p_NotID NUMBER)
RETURN NUMBER
IS
    v_ProjeId NUMBER;
    v_Puan NUMBER;
    v_MaksimumPuan NUMBER;
    v_Yuzde NUMBER;
BEGIN

    SELECT Puan INTO v_Puan
    FROM Notlar
    WHERE notid = p_NotID;
    
    SELECT projeid into v_projeid from notlar where notid = p_notid; 


    SELECT MaksimumPuan INTO v_MaksimumPuan
    FROM Projeler WHERE projeid = v_projeid ;
   


    IF v_MaksimumPuan IS NOT NULL AND v_MaksimumPuan > 0 THEN
        v_Yuzde := (v_Puan / v_MaksimumPuan) * 100;
    ELSE
        v_Yuzde := NULL;
    END IF;


    RETURN v_Yuzde;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END HesaplaProjeYuzdesi;

--Fonksiyon 2'yi çaðýran kod
Begin
dbms_output.put_line(HesaplaProjeYuzdesi(2));
end;

--Triggerlar

--Trigger 1
CREATE TABLE ProjeEklemeLog (
    LogID NUMBER PRIMARY KEY,
    ProjeID NUMBER,
    EklemeZamani TIMESTAMP,
    Aciklama VARCHAR2(255)
);

CREATE SEQUENCE ProjeEklemeLogSeq
start with 1
increment by 1;

CREATE OR REPLACE TRIGGER ProjeEklemeTrigger
AFTER INSERT ON Projeler
FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO ProjeEklemeLog (LogID, ProjeID, EklemeZamani, Aciklama)
    VALUES (ProjeEklemeLogSeq.NEXTVAL, :NEW.ProjeID, SYSTIMESTAMP, 'Proje eklendi');

    DBMS_OUTPUT.PUT_LINE('Proje eklendi. ProjeID: ' || :NEW.ProjeID);
END;

--Trigger 1 çalýþtýrma kodu
insert into Projeler VALUES(3,'C#.NET Hastane Otomasyonu',3,TO_DATE('2024-12-12','yyyy,mm,dd'),100);


--Trigger 2 
CREATE OR REPLACE TRIGGER PuanKontrolTrigger
BEFORE INSERT ON Notlar
FOR EACH ROW
BEGIN
    IF :NEW.Puan < 0 THEN
        :NEW.Puan := 0;
    ELSIF :NEW.Puan > 100 THEN
        :NEW.Puan := 100;
    END IF;
END;

--Trigger 2 çalýþtýrma kodu
insert into Projeler VALUES(3,'C#.NET Hastane Otomasyonu',3,TO_DATE('2024-12-12','yyyy,mm,dd'),100);


--Job
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'CHECK_PROJELER_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN UpdateProjeler; END;',
    start_date      => SYSDATE,
    repeat_interval => 'FREQ=DAILY; INTERVAL=1',
    enabled         => TRUE
  );
END;

--Job'ýn aktif olup olmadýðýný görme
select *
from all_scheduler_job_run_details
where job_name = 'CHECK_PROJELER_JOB';

--Log tablosunu temizleme
exec dbms_scheduler.purge_log();


--Kullanýcý tanýmlý Exception'lý kod
DECLARE	
        baslangicTarihi DATE;
        bitisTarihi DATE; 
        gecersiz_tarih EXCEPTION;
BEGIN
    SELECT BaslangicTarihi INTO baslangicTarihi FROM Donemler where donemid = 1;
    SELECT BitisTarihi INTO bitisTarihi FROM Donemler where donemid = 1;
    IF BitisTarihi <= BaslangicTarihi THEN 
        RAISE gecersiz_tarih;
    ELSE
     DBMS_OUTPUT.PUT_LINE('Geçerli dönem');
    END IF;
    EXCEPTION
      WHEN gecersiz_tarih THEN
                DBMS_OUTPUT.PUT_LINE('Geçersiz dönem tarihleri. Bitiþ tarihi baþlangýç tarihinden sonra olmalýdýr.');
END;

