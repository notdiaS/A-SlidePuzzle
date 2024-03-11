
--Tablolar

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


insert into ogrenciler values(
'213301032','Ali','Keskin',to_date('2002-12-12','yyyy-mm-dd'),'Erkek','05467896783','AlKesk@gmail.com','KaraKýþla Mah. ,Serçe Sok. ,Kat 1 Daire 10, Kocaeli/Derince');
commit;

insert into ogrenciler values(
'213301033','Ayþe','Duman',to_date('2002-7-10','yyyy-mm-dd'),'Kýz','05338900875','AyþeDum@gmail.com','Melek Mah. ,Karga Sok. ,Kat 3 Daire 5, Sakarya/Arifiye');
commit;

insert into ogrenciler values(
'203301054','Zillet','Kara',to_date('2001-3-22','yyyy-mm-dd'),'Kýz','05552903815','ZillKar@gmail.com','Mavi Mah. ,Papatya Sok. ,Kat 1 Daire 7, Sakarya/Serdivan');
commit;


--2
CREATE TABLE Dersler (												
    DersID NUMBER PRIMARY KEY,
    OgretimGorevlisiID NUMBER not null,
    DersAdi VARCHAR2(100) not null,
    DersAciklamasi VARCHAR2(255) not null,
    KrediSaatleri NUMBER not null,
    CONSTRAINT fk_key_ders_hoca FOREIGN KEY(OgretimGorevlisiID) REFERENCES OgretimGorevlileri(OgretimGorevlisiID)
);


insert into dersler values(1,2,'Veri Tabaný Programlama','Oracle üzerinden veri tabaný programlama iþlemleri',4);
commit;
insert into dersler values(2,2,'Veri Madenciliði','Makine öðrenimi algoritmalarýyla çekilen verinin yorumlanmasý','4');
commit;
insert into dersler values(3,1,'Programlama Dili','C# .Net eðitimi','3');

--3
CREATE TABLE Kayitlar (
    KayitID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30) NOT NULL,
    DersID NUMBER not null,
    KayitTarihi DATE not null,
    Notu VARCHAR2(2) not null,
    CONSTRAINT fk_key1 FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo),
    CONSTRAINT fk_key2 FOREIGN KEY (DersID) REFERENCES Dersler(DersID)
);

insert into kayitlar values(1,'213301032',1,to_date('2021-9-12','yyyy-mm-dd'),'A');
commit;

insert into kayitlar values(2,'213301033',1,to_date('2021-9-12','yyyy-mm-dd'),'B');
commit;

insert into kayitlar values(3,'203301054',2,to_date('2021-9-12','yyyy-mm-dd'),'C');
commit;

insert into kayitlar values(5,'213301032',2,to_date('2022-09-07','yyyy-mm-dd'),'A');
commit;

insert into kayitlar values(5,'213301032',2,to_date('2021-9-12','yyyy-mm-dd'),'B');
commit;

insert into kayitlar values(7,'213301032',3,to_date('2021-9-12','yyyy-mm-dd'),'D');
commit;

--4
CREATE TABLE OgretimGorevlileri(
    OgretimGorevlisiID NUMBER PRIMARY KEY,
    Ad VARCHAR2(50) not null,
    Soyad VARCHAR2(50) not null,
    IletisimNumarasi VARCHAR2(20) not null,
    Eposta VARCHAR2(100) not null
);


insert into ogretimgorevlileri values(1,'Kemal','Parlak','05898769080','ParlakKem@gmail.com');
commit;
insert into ogretimgorevlileri values(2,'Cemil','Razý','05795763041','CemRaz@gmail.com');
commit;


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

insert into siniflar values(1,1,'213301032','210',100);
insert into siniflar values(2,2,'213301033','210',200);
insert into siniflar values(3,1,'203301054','222',100);



--Sorgular

--Sorgu 1
SELECT o.ad as OgrenciAdi,d.dersadi as DersAdi,k.kayittarihi as KayitTarihi,d.kredisaatleri as k_saatleri FROM ogrenciler o 
    JOIN kayýtlar k 
        ON o.ogrencino = k.ogrencino
            JOIN dersler d ON k.dersid = d.dersid
                WHERE o.OgrenciNo = '213301032';
                

--Sorgu 2
SELECT og.ad, k.ogrencino,k.notu,s.sinifid FROM siniflar s
    JOIN ogretimgorevlileri og
        ON og.ogretimgorevlisiid = s.ogretimgorevlisiid
            JOIN kayitlar k ON k.ogrencino = s.ogrencino 
                WHERE k.dersid = 
                    (SELECT dersid FROM Dersler WHERE dersadi = 'Veri Madenciliði');
                    
                    
--Triggerlar

--Trigger 1
CREATE OR REPLACE TRIGGER ogretimgorevlisi_silme_engelleme
BEFORE DELETE ON OgretimGorevlileri
FOR EACH ROW
DECLARE
    engelle EXCEPTION;
    PRAGMA EXCEPTION_INIT(engelle, -20002);
    sayac NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO sayac
    FROM Siniflar
    WHERE OgretimGorevlisiID = :OLD.OgretimGorevlisiID;

    IF sayac <> 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bu öðretmen alt sýnýflarda eðitim verdiði için silinememektedir.');
    ELSE
        dbms_output.put_line('Ogretmen silme iþlemi baþarýlý!!');
    END IF;
END;

--Trigger 1 çalýþtýrma kodu
delete ogretimgorevlileri where ogretimgorevlisiid = 1;

--Trigger 2
CREATE OR REPLACE TRIGGER Ogrenci_Harf_Notu_Kontrol
BEFORE INSERT OR UPDATE ON Kayitlar
FOR EACH ROW
DECLARE
    yanlis_not EXCEPTION;
    PRAGMA EXCEPTION_INIT(yanlis_not, -20001);
BEGIN
    IF NOT (:NEW.Notu IN ('A', 'B', 'C', 'D', 'F')) THEN
        raise_application_error(-20001, 'Geçersiz not girdiniz!'); 
    ELSE
        dbms_output.put_line('Not baþarýyla girildi!');
    END IF;
END;

--Trigger 2 çalýþtýrma kodu
update kayitlar
set notu = 'G' where ogrencino = '213301032'; 


--Prosedürler

--Prosedür 1
CREATE SEQUENCE SEQ_KAYIT_ID
    INCREMENT BY 1
    START WITH 4
    MINVALUE 4
    MAXVALUE 100
    CYCLE
    CACHE 2;


CREATE OR REPLACE PROCEDURE pr_ogrenci_ve_kayit_yerlestirme(
    p_OgrenciNo IN VARCHAR2,
    p_Ad IN VARCHAR2,
    p_Soyad IN VARCHAR2,
    p_DogumTarihi IN DATE,
    p_Cinsiyet IN VARCHAR2,
    p_IletisimNumarasi IN VARCHAR2,
    p_Eposta IN VARCHAR2,
    p_Adres IN VARCHAR2,
    p_DersID IN NUMBER,
    p_Notu IN VARCHAR2,
    p_KayitTarihi IN DATE
)
AS
BEGIN
   
    INSERT INTO Ogrenciler(OgrenciNo, Ad, Soyad, DogumTarihi, Cinsiyet, IletisimNumarasi, Eposta, Adres)
    VALUES (p_OgrenciNo, p_Ad, p_Soyad, p_DogumTarihi, p_Cinsiyet, p_IletisimNumarasi, p_Eposta, p_Adres);

    INSERT INTO Kayitlar(KayitID, OgrenciNo, DersID, Notu, KayitTarihi)
    VALUES (SEQ_KAYIT_ID.NEXTVAL, p_OgrenciNo, p_DersID, p_Notu, p_KayitTarihi);
    
    COMMIT;
END pr_ogrenci_ve_kayit_yerlestirme;

--Prosedür 1'i aktifleþtiren kod
BEGIN
pr_ogrenci_ve_kayit_yerlestirme('213301045','Zeliha','Büyük',to_date('2002-12-12','yyyy-mm-dd'),'Kýz','05678908875','Zel@gmail.com','Adres Yok',2,'C',to_date('2022-03-05','yyyy-mm-dd'));
END;


--Prosedür 2
CREATE OR REPLACE PROCEDURE pr_dersi_gecip_gecmeme_durumu(
   pr_ogr_no IN VARCHAR2, pr_ogr_ders_id IN NUMBER)
AS
CURSOR crs is SELECT notu
    FROM kayitlar 
        WHERE ogrencino = pr_ogr_no and dersid = pr_ogr_ders_id;
ogr_notu VARCHAR2(2);
BEGIN
    OPEN crs;
    FETCH crs into ogr_notu;
        CASE
            WHEN ogr_notu <> 'F' THEN 
                dbms_output.put_line(pr_ogr_no||' Numaralý öðrenci dersten geçmiþtir.');
            WHEN crs%notfound THEN
                dbms_output.put_line(pr_ogr_no||' Böyle bir öðrenci bulunamamýþtýr.');
            ELSE
                dbms_output.put_line(pr_ogr_no||' Numaralý öðrenci dersten kalmýþtýr.');
         END CASE;
    CLOSE crs;
END;

--Prosedür 2'yi aktifleþtiren kod
update kayitlar 
set notu = 'A' WHERE kayitlar.ogrencino = '213301032' and dersid = 1;

BEGIN

pr_dersi_gecip_gecmeme_durumu('213301032',1);

END;


--Fonksiyonlar
    
--Fonksiyon 1
create or replace Type OgrenciBilgiTut as object
(
    OgrenciNo VARCHAR2(30),
    Ad VARCHAR2(50),
    Soyad VARCHAR2(50) ,
    DogumTarihi DATE ,
    Cinsiyet VARCHAR2(10) ,
    IletisimNumarasi VARCHAR2(20) ,
    Eposta VARCHAR2(100) ,
    Adres VARCHAR2(255) 
);

CREATE OR REPLACE Type BilgiTut as table of OgrenciBilgiTut;


CREATE OR REPLACE FUNCTION f_ogrenci_bilgisi_getir(
    p_OgrenciNo IN VARCHAR2
)
RETURN BilgiTut
IS
sonuc BilgiTut := new BilgiTut();
BEGIN
    FOR s IN (SELECT * FROM OGRENCILER WHERE ogrencino = p_OgrenciNo) LOOP
        sonuc.extend;
        sonuc(sonuc.COUNT) := new OgrenciBilgiTut(s.ogrencino,s.ad,s.soyad,s.dogumtarihi,s.cinsiyet,s.iletisimnumarasi,s.eposta,s.adres);
    END LOOP;
    RETURN sonuc;
END f_ogrenci_bilgisi_getir;

--Fonksiyon 1 çaðýrma
select * from table(f_ogrenci_bilgisi_getir('213301032'));


--Fonksiyon 2
CREATE OR REPLACE FUNCTION f_ogrencinin_aldigi_total_kredi(
    p_OgrenciNo IN VARCHAR2
)
RETURN NUMBER
AS
    CURSOR c IS SELECT * FROM Kayitlar K
    JOIN Dersler D ON K.DersID = D.DersID
    WHERE K.OgrenciNo = p_OgrenciNo;
    
    TYPE COUNTER IS TABLE OF c%ROWTYPE INDEX BY BINARY_INTEGER;
    row_list COUNTER;
    ogrenci_satiri c%ROWTYPE;
    
    TYPE kredi_saatleri IS TABLE OF NUMBER;
    saatler kredi_saatleri := kredi_saatleri();
    total_kredi_saati NUMBER := 0;
    sayac NUMBER := 0;
BEGIN
    OPEN c;
    FETCH c BULK COLLECT INTO row_list;
    saatler.extend(row_list.COUNT);
    FOR i IN row_list.first..row_list.last LOOP
        sayac := sayac + 1;
        saatler(sayac) := row_list(i).KrediSaatleri;
    END LOOP;
    CLOSE c;
    
    FOR i IN saatler.first..saatler.last LOOP
        total_kredi_saati := total_kredi_saati + saatler(i);
    END LOOP;  
    
    RETURN total_kredi_saati;
END f_ogrencinin_aldigi_total_kredi;

SELECT * FROM Kayitlar K
    JOIN Dersler D ON K.DersID = D.DersID
    WHERE K.OgrenciNo = '213301032';

--insert into  dersler values(4,'Teknik Ýngilizce','Teknik terimlerin Ýngilizce iþlenmesi','4');

--insert into kayitlar values(5,'213301032',2,to_date('2022-09-07','yyyy-mm-dd'),'A');


--Fonksiyon 2'yi çaðýrma
DECLARE
a number;
BEGIN
a:= f_ogrencinin_aldigi_total_kredi('213301032');
DBMS_OUTPUT.PUT_LINE('Girilen numaralý öðrencinin kredi toplamý: ' || a);
END;


--Exception
DECLARE
    maks_ogrenci NUMBER := 100;
    ogrenci_sayisi NUMBER;
    mevcut_asildi EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO ogrenci_sayisi FROM ogrenciler; 
    IF ogrenci_sayisi > maks_ogrenci THEN
        RAISE mevcut_asildi;
    ELSE
        dbms_output.put_line('Öðrenci sayýsý:' || ogrenci_sayisi);
    END IF;
    EXCEPTION
        WHEN mevcut_asildi THEN
            dbms_output.put_line('Sýnýf mevcudu aþýldý!!');
END;
                                              
                                      
--Job
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'Ogrenci_Dersler_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          FOR r IN (SELECT o.OgrenciNo,k.notu, o.Ad, o.Soyad, d.DersAdi
                                      FROM Ogrenciler o
                                      JOIN Kayitlar k ON o.OgrenciNo = k.OgrenciNo
                                      JOIN Dersler d ON k.DersID = d.DersID)
                          LOOP
                            DBMS_OUTPUT.PUT_LINE(''OgrenciNo: '' || r.OgrenciNo || '', Ad: '' || r.Ad ||
                                               '', Soyad: '' || r.Soyad || '', Notu:'' || r.notu || '', Ders: '' || r.DersAdi);
                          END LOOP;
                       END;',
    start_date      => SYSTIMESTAMP,                        
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',       
    enabled         => TRUE                               
  );

  DBMS_OUTPUT.PUT_LINE('Job baþarýyla yaratýldý.');
END;

--Job'ýn aktif olup olmadýðýný görme
select *
from all_scheduler_job_run_details
where job_name = 'OGRENCI_DERSLER_JOB';

--Log tablosunu temizleme
exec dbms_scheduler.purge_log();



--Tablolar

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

--Tablolar

--1
CREATE TABLE OkulaGirisKayitlari (
    GirisID NUMBER PRIMARY KEY,
    OgrenciID VARCHAR2(30),
    Tarih DATE NOT NULL,
    CONSTRAINT fk_ogrenci_giris FOREIGN KEY (OgrenciID) REFERENCES Ogrenciler(OgrenciNo)
);

--2
CREATE TABLE DersProgrami (
    DersProgramiID NUMBER PRIMARY KEY,
    DersID NUMBER,
    DonemID NUMBER,
    SinifID NUMBER,
    Gun VARCHAR2(10) NOT NULL,
    BaslamaSaati CHAR(5) NOT NULL,
    DersSayisi NUMBER NOT NULL,
    CONSTRAINT fk_ders_programi_ders FOREIGN KEY (DersID) REFERENCES Dersler(DersID),
    CONSTRAINT fk_ders_programi_donem FOREIGN KEY (DonemID) REFERENCES Donemler(DonemID),
    CONSTRAINT fk_ders_programi_sinif FOREIGN KEY (SinifID) REFERENCES Siniflar(SinifID)
);


--3
CREATE TABLE DisiplinCezasiDurumu (
    CezaID NUMBER PRIMARY KEY,
    OgrenciID VARCHAR2(30),
    Turu VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_ogrenci_ceza FOREIGN KEY (OgrenciID) REFERENCES Ogrenciler(OgrenciNo)
);


--4
CREATE TABLE Burslar (
    YardimID NUMBER PRIMARY KEY,
    OgrenciID VARCHAR2(30),
    YardimTuru VARCHAR2(50) NOT NULL,
    Miktar NUMBER,
    CONSTRAINT fk_ogrenci_burs FOREIGN KEY (OgrenciID) REFERENCES Ogrenciler(OgrenciNo)
);


--5
CREATE TABLE Etkinlikler (
    EtkinlikID INT PRIMARY KEY,
    EtkinlikAdi VARCHAR2(100),
    EtkinlikTarihi DATE,
    Konum VARCHAR2(255),
    Aciklama VARCHAR2(4000)
);

--Girdiler
INSERT INTO OkulaGirisKayitlari (GirisID, OgrenciID, Tarih)
VALUES (1, '203301054', TO_DATE('2023-12-20 09:45', 'YYYY-MM-DD HH24:MI'));
INSERT INTO OkulaGirisKayitlari (GirisID, OgrenciID, Tarih)
VALUES (2, '213301032', TO_DATE('2023-11-05 10:20', 'YYYY-MM-DD HH24:MI'));
INSERT INTO OkulaGirisKayitlari (GirisID, OgrenciID, Tarih)
VALUES (3, '213301033', TO_DATE('2023-12-10 08:30', 'YYYY-MM-DD HH24:MI'));
INSERT INTO OkulaGirisKayitlari (GirisID, OgrenciID, Tarih)
VALUES (4, '203301054', TO_DATE('2023-12-12 09:15', 'YYYY-MM-DD HH24:MI'));


--2
INSERT INTO DersProgrami (DersProgramiID, DersID, DonemID, SinifID, Gun, BaslamaSaati, DersSayisi)
VALUES (1, 3, 2, 1, 'Cuma', '09:00', 3);
INSERT INTO DersProgrami (DersProgramiID, DersID, DonemID, SinifID, Gun, BaslamaSaati, DersSayisi)
VALUES (2, 2, 1, 3, 'Pazartesi', '13:30', 4);
INSERT INTO DersProgrami (DersProgramiID, DersID, DonemID, SinifID, Gun, BaslamaSaati, DersSayisi)
VALUES (3, 1, 2, 2, 'Çarþamba', '11:00', 3);
INSERT INTO DersProgrami (DersProgramiID, DersID, DonemID, SinifID, Gun, BaslamaSaati, DersSayisi)
VALUES (4, 3, 1, 3, 'Perþembe', '09:30', 4);


--3
INSERT INTO DisiplinCezasiDurumu (CezaID, OgrenciID, Turu)
VALUES (1, '213301032', 'uzaklastirma');
INSERT INTO DisiplinCezasiDurumu (CezaID, OgrenciID, Turu)
VALUES (2, '203301054', 'kinama');
INSERT INTO DisiplinCezasiDurumu (CezaID, OgrenciID, Turu)
VALUES (3, '213301032', 'uyari');
INSERT INTO DisiplinCezasiDurumu (CezaID, OgrenciID, Turu)
VALUES (4, '213301033', 'uyari');


--4
INSERT INTO Burslar (YardimID, OgrenciID, YardimTuru, Miktar)
VALUES (1, '213301033', 'egitim', 500);
INSERT INTO Burslar (YardimID, OgrenciID, YardimTuru, Miktar)
VALUES (2, '213301032', 'sosyal', 300);
INSERT INTO Burslar (YardimID, OgrenciID, YardimTuru, Miktar)
VALUES (3, '203301054', 'egitim', 700);
INSERT INTO Burslar (YardimID, OgrenciID, YardimTuru, Miktar)
VALUES (4, '203301054', 'sosyal', 200);


--5
INSERT INTO Etkinlikler (EtkinlikID, EtkinlikAdi, EtkinlikTarihi, Konum, Aciklama)
VALUES (1, 'Kütüphane Konferansý', TO_DATE('2023-12-15', 'YYYY-MM-DD'), 'Kütüphane', 'Yazar buluþmasý ve kitap tanýtýmý.');
INSERT INTO Etkinlikler (EtkinlikID, EtkinlikAdi, EtkinlikTarihi, Konum, Aciklama)
VALUES (2, 'Müzik Festivali', TO_DATE('2024-02-05', 'YYYY-MM-DD'), 'Þehir Stadyumu', 'Yerel sanatçýlarýn katýlýmýyla müzik etkinliði.');
INSERT INTO Etkinlikler (EtkinlikID, EtkinlikAdi, EtkinlikTarihi, Konum, Aciklama)
VALUES (3, 'Kültür Etkinliði', TO_DATE('2023-12-20', 'YYYY-MM-DD'), 'Þehir Merkezi', 'Yerel halk dans ve müzik gösterileri.');
INSERT INTO Etkinlikler (EtkinlikID, EtkinlikAdi, EtkinlikTarihi, Konum, Aciklama)
VALUES (4, 'Bilim Sempozyumu', TO_DATE('2023-12-31', 'YYYY-MM-DD'), 'Bilim Merkezi', 'Bilim insanlarý tarafýndan sunumlar ve paneller.');

--Sorgular

-- join 1
SELECT DISTINCT o.OgrenciNo, o.Ad, o.Soyad, n.NotID, n.Puan, d.Turu
FROM Ogrenciler o
JOIN Kayitlar k ON o.OgrenciNo = k.OgrenciNo
JOIN Notlar n ON k.KayitID = n.KayitID
JOIN DisiplinCezasiDurumu d ON o.OgrenciNo = d.OgrenciID;

-- join 2
SELECT o.OgrenciNo, o.Ad, o.Soyad, COUNT(og.GirisID) AS OkulaGelisSayisi, COUNT(dcd.CezaID) AS DisiplinCezasiSayisi
FROM Ogrenciler o
LEFT JOIN OkulaGirisKayitlari og ON o.OgrenciNo = og.OgrenciID
LEFT JOIN DisiplinCezasiDurumu dcd ON o.OgrenciNo = dcd.OgrenciID
GROUP BY o.OgrenciNo, o.Ad, o.Soyad;

--Triggerlar

--Trigger 1
CREATE SEQUENCE burslar_seq
START WITH 1
INCREMENT BY 1;

--Burs pk arttýrýcý trigger
CREATE OR REPLACE TRIGGER burslar_trigger
BEFORE INSERT ON Burslar
FOR EACH ROW
BEGIN
    :NEW.YardimID := burslar_seq.NEXTVAL;
END;
/

--Trigger 2
-- Burs alan biri ceza alýrsa otomatik burslarýný sil.
CREATE OR REPLACE TRIGGER ceza_burs_trigger
AFTER INSERT OR DELETE ON DisiplinCezasiDurumu
FOR EACH ROW
DECLARE
    v_ceza_count NUMBER;
BEGIN
    
        SELECT COUNT(*) INTO v_ceza_count
        FROM Burslar
        WHERE OgrenciID = :NEW.OgrenciID;
        
        IF v_ceza_count > 0 THEN
            DELETE FROM Burslar
            WHERE OgrenciID = :NEW.OgrenciID;
        END IF;
    
END;


--Fonksiyonlar

--Fonksiyon 1
--Bu fonksiyon seçilen kiþinin cezalarýný döndürüyor
CREATE OR REPLACE FUNCTION CezaListeByID(OgrenciID_ IN VARCHAR2)
  RETURN VARCHAR2 IS
  v_cezalar VARCHAR2(1000);

BEGIN
  SELECT LISTAGG(ogr.ogrencino || ', ' || ogr.ad || ', ' || ogr.soyad || ', ' ||
                 ceza.turu,
                 '; ') WITHIN GROUP(ORDER BY ogr.ogrencino, ceza.cezaid)
    INTO v_cezalar
    FROM OGRENCILER ogr
    JOIN DISIPLINCEZASIDURUMU ceza
      ON ogr.ogrencino = ceza.ogrenciid
   WHERE ogr.ogrencino = OgrenciID_;

  RETURN v_cezalar;
END;

-- Ceza listeleme fonksiyonunu çalýþtýr
DECLARE
  cezaListesi VARCHAR2(1000);
BEGIN
  cezaListesi := CezaListeByID('213301032');
  DBMS_OUTPUT.PUT_LINE('Ceza Listesi: ' || cezaListesi);
END;


--Fonksiyon 2
CREATE TYPE DersProgramiTabloType AS OBJECT (
    dersid NUMBER,
    dersadi VARCHAR2(100),
    ogretmenadi VARCHAR2(50),
    ogretmensoyadi VARCHAR2(50),
    sinif VARCHAR2(20),
    gun VARCHAR2(10),
    baslamasaati VARCHAR2(5)
);

CREATE TYPE DersProgramiTabloArrayType AS TABLE OF DersProgramiTabloType;


CREATE OR REPLACE FUNCTION DersProgramiTablo(DersID_ NUMBER)
  RETURN DersProgramiTabloArrayType
  PIPELINED IS
  v_row DersProgramiTabloType;
BEGIN
  FOR rec IN (SELECT dp.DersID       AS dersid,
                     d.DersAdi       AS dersadi,
                     og.Ad           AS ogretmenadi,
                     og.Soyad        AS ogretmensoyadi,
                     s.OdaNumarasi   AS sinif,
                     dp.Gun          AS gun,
                     dp.BaslamaSaati AS baslamasaati
                FROM DersProgrami dp
                JOIN Dersler d
                  ON dp.DersID = d.DersID
                JOIN OgretimGorevlileri og
                  ON d.OgretimGorevlisiID = og.OgretimGorevlisiID
                JOIN Siniflar s
                  ON dp.SinifID = s.SinifID
               WHERE dp.DersID = DersID_) LOOP
    v_row := DersProgramiTabloType(rec.dersid,
                                   rec.dersadi,
                                   rec.ogretmenadi,
                                   rec.ogretmensoyadi,
                                   rec.sinif,
                                   rec.gun,
                                   rec.baslamasaati);
    PIPE ROW(v_row);
  END LOOP;

  RETURN;
END;

-- Seçilen dersin dersprogramý tablosunu sorgula
SELECT * FROM TABLE(DersProgramiTablo(3));UT_LINE('Ceza Listesi: ' || cezaListesi);
END;

--Prosedürler

--Prosedür 1
CREATE OR REPLACE PROCEDURE OgrenciVeDetaylariListele IS
    CURSOR OgrenciCursor IS
        SELECT OgrenciNo, Ad, Soyad FROM Ogrenciler; 

    v_OgrenciID OkulaGirisKayitlari.OgrenciID%TYPE;
    v_OgrenciAdi Ogrenciler.Ad%TYPE;
    v_OgrenciSoyadi Ogrenciler.Soyad%TYPE;
    v_CezaSayisi NUMBER;
    v_BursMiktari NUMBER;
BEGIN
    OPEN OgrenciCursor;
    LOOP
        FETCH OgrenciCursor INTO v_OgrenciID, v_OgrenciAdi, v_OgrenciSoyadi;
        EXIT WHEN OgrenciCursor%NOTFOUND;

        SELECT COUNT(*) INTO v_CezaSayisi FROM DisiplinCezasiDurumu WHERE OgrenciID = v_OgrenciID;
        
        SELECT NVL(SUM(Miktar), 0) INTO v_BursMiktari FROM Burslar WHERE OgrenciID = v_OgrenciID;

        DBMS_OUTPUT.PUT_LINE('Öðrenci ID: ' || v_OgrenciID || ', Ad: ' || v_OgrenciAdi || ', Soyad: ' || v_OgrenciSoyadi || 
                            ', Ceza Sayýsý: ' || v_CezaSayisi || ', Toplam Burs: ' || v_BursMiktari);
    END LOOP;
    CLOSE OgrenciCursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hata: Öðrenci bilgileri listelenemedi.');
END;


-- üstteki proceduru çalýþtýrma kodu.
BEGIN
    OgrenciVeDetaylariListele;
END;

--Prosedür 2
-- veri tabanýna kayýtlý tüm etkinlikleri veren procedure
CREATE OR REPLACE PROCEDURE TumEtkinlikleriListele IS
BEGIN
    FOR etk IN (SELECT * FROM Etkinlikler) LOOP
        DBMS_OUTPUT.PUT_LINE('Etkinlik ID: ' || etk.EtkinlikID ||
                             ', Adý: ' || etk.EtkinlikAdi ||
                             ', Tarih: ' || TO_CHAR(etk.EtkinlikTarihi, 'DD.MM.YYYY') ||
                             ', Konum: ' || etk.Konum ||
                             ', Açýklama: ' || etk.Aciklama);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hata: Etkinlikler listelenemedi.');
END;


-- üstteki prosedürü çalýþtýran kod
BEGIN
    TumEtkinlikleriListele;
END;

--Kullanýcý tanýmlý exception için Exception'lý trigger
CREATE OR REPLACE TRIGGER burslar_burs_turu_check
BEFORE INSERT ON Burslar
FOR EACH ROW
BEGIN
    IF :NEW.YardimTuru IS NULL THEN
        RAISE_APPLICATION_ERROR(-20895, 'Dur! Burs türünü de eklemen gerek.');
    END IF;
END;


--Job
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'HAFTALIK_YEDEK_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                                DECLARE
                                    d DATE := SYSTIMESTAMP AT TIME ZONE ''UTC'';
                                    d_str VARCHAR2(100);
                                BEGIN
                                    SELECT TO_CHAR(d, ''YYYYMMDDHH24MISS'') INTO d_str FROM DUAL;
                                    EXECUTE IMMEDIATE ''ALTER SYSTEM ARCHIVE LOG CURRENT'';
                                    DBMS_BACKUP_RESTORE.BACKUP_DATABASE (
                                        options => DBMS_BACKUP_RESTORE.FULL,
                                        backup_tag => ''WEEKLY_BACKUP_'' || d_str,
                                        compress => 1
                                    );
                                END;
                            END;',
        start_date      => SYSTIMESTAMP AT TIME ZONE 'UTC',
        repeat_interval => 'FREQ=WEEKLY;BYDAY=SUN;BYHOUR=2;',
        enabled         => TRUE
    );
END;


--Job'ýn aktif olup olmadýðýný görme
select *
from all_scheduler_job_run_details
where job_name = 'HAFTALIK_YEDEK_JOB';

--Log tablosunu temizleme
exec dbms_scheduler.purge_log();


--Tablolar

-- Tablo 16: Kulüpler
CREATE TABLE Kulupler (
    KulupID NUMBER PRIMARY KEY,
    KulupAdi VARCHAR2(100),
    Aciklama VARCHAR2(4000)
);

-- Tablo 17: Staj
CREATE TABLE Stajlar (
    StajID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30),
    SirketAdi VARCHAR2(100),
    BaslangicTarihi DATE,
    BitisTarihi DATE,
    CONSTRAINT fk_key_ogrenci_staj FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo)
);


-- Tablo 18: mezuniyet
CREATE TABLE Mezuniyet (
    MezuniyetID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30), 
    MezuniyetTarihi DATE,
    Derece VARCHAR2(50),
    CONSTRAINT fk_ogrenci_mezuniyet FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo)
);

-- Tablo 19: Öðrenci Geri Bildirimleri
CREATE TABLE OgrenciGeribildirimleri (
    GeribildirimID NUMBER PRIMARY KEY,
    OgrenciNo VARCHAR2(30),
    DersID NUMBER,
    Geribildirim VARCHAR2(4000),
    Tarih DATE,
    CONSTRAINT fk_ogrenci_OgrenciGeribildirimleri FOREIGN KEY (OgrenciNo) REFERENCES Ogrenciler(OgrenciNo)

);

-- Tablo 20: Seminerler
CREATE TABLE Seminerler (
    SeminerID NUMBER PRIMARY KEY,
    Konu VARCHAR2(100),
    Tarih DATE,
    Konusmaci VARCHAR2(100),
    Yer VARCHAR2(255),
    Aciklama VARCHAR2(4000)
);

--Girdiler
INSERT INTO Kulupler (KulupID, KulupAdi, Aciklama)
VALUES (1, 'Futbol Kulübü', 'Futbol ile ilgilenen öðrencilerin bir araya geldiði kulüp.');
INSERT INTO Kulupler (KulupID, KulupAdi, Aciklama)
VALUES (2, 'siber güvenlik Kulübü', 'Siber güvenlik ile ilgilenen öðrencilerin bir araya geldiði kulüp.');
INSERT INTO Kulupler (KulupID, KulupAdi, Aciklama)
VALUES (3, 'santranç Kulübü', 'Santranç ile ilgilenen öðrencilerin bir araya geldiði kulüp.');


-- Tablo 17: Stajlar
INSERT INTO Stajlar (StajID, OgrenciNo, SirketAdi, BaslangicTarihi, BitisTarihi)
VALUES (1, '213301032', 'AKINSOFT Yazýlým', TO_DATE('2020-07-01', 'YYYY-MM-DD'), TO_DATE('2020-12-31', 'YYYY-MM-DD'));
INSERT INTO Stajlar (StajID, OgrenciNo, SirketAdi, BaslangicTarihi, BitisTarihi)
VALUES (2, '213301033', 'GENERAL MOTORS Ltd.', TO_DATE('2022-08-15', 'YYYY-MM-DD'), TO_DATE('2023-02-28', 'YYYY-MM-DD'));
INSERT INTO Stajlar (StajID, OgrenciNo, SirketAdi, BaslangicTarihi, BitisTarihi)
VALUES (3, '203301054', 'BOX BÝLÝÞÝM', TO_DATE('2021-10-01', 'YYYY-MM-DD'), TO_DATE('2022-04-01', 'YYYY-MM-DD'));

-- Tablo 18: Mezuniyet
INSERT INTO Mezuniyet (MezuniyetID, OgrenciNo, MezuniyetTarihi, Derece)
VALUES (1, '213301032', TO_DATE('2023-06-30', 'YYYY-MM-DD'), 'Yüksek Onur');
INSERT INTO Mezuniyet (MezuniyetID, OgrenciNo, MezuniyetTarihi, Derece)
VALUES (2, '213301033', TO_DATE('2023-06-30', 'YYYY-MM-DD'), 'Onur');
INSERT INTO Mezuniyet (MezuniyetID, OgrenciNo, MezuniyetTarihi, Derece)
VALUES (3, '203301054', TO_DATE('2023-06-30', 'YYYY-MM-DD'), 'Onur');


-- Tablo 19: Öðrenci Geri Bildirimleri
INSERT INTO OgrenciGeribildirimleri (GeribildirimID, OgrenciNo, DersID, Geribildirim, Tarih)
VALUES (1, '213301032', 101, 'Ders içeriði çok ilginçti.', TO_DATE('2021-12-15', 'YYYY-MM-DD'));
INSERT INTO OgrenciGeribildirimleri (GeribildirimID, OgrenciNo, DersID, Geribildirim, Tarih)
VALUES (2, '213301033', 102, 'Hocalar çok yardýmsever.', TO_DATE('2022-12-20', 'YYYY-MM-DD'));
INSERT INTO OgrenciGeribildirimleri (GeribildirimID, OgrenciNo, DersID, Geribildirim, Tarih)
VALUES (3, '203301054', 103, 'Laboratuvar sayýsýnýn artýrýlmasýný istiyoruz.', TO_DATE('2023-01-15', 'YYYY-MM-DD'));


-- Tablo 20: Seminerler
INSERT INTO Seminerler (SeminerID, Konu, Tarih, Konusmaci, Yer, Aciklama)
VALUES (1, 'Yapay Zeka ve Geleceði', TO_DATE('2022-07-20', 'YYYY-MM-DD'), 'Prof. Ahmet Çakýr', 'Üniversite Konferans Salonu', 'Yapay zeka teknolojilerinin geleceði hakkýnda seminer içeriði.');
INSERT INTO Seminerler (SeminerID, Konu, Tarih, Konusmaci, Yer, Aciklama)
VALUES (2, 'Robotik Uygulamalarý', TO_DATE('2022-08-10', 'YYYY-MM-DD'), 'Dr. Ayþe Demir', 'Robotik Laboratuvarý', 'Güncel robotik kodlama ve uygulamalara dair bilgilerin paylaþýldýðý seminer içeriði.');
INSERT INTO Seminerler (SeminerID, Konu, Tarih, Konusmaci, Yer, Aciklama)
VALUES (3, 'Veri Madenciliði', TO_DATE('2022-09-15', 'YYYY-MM-DD'), 'Prof. Zeyep Yýldýrým', 'Konferans Salonu 102', 'Veri madenciliði teknikleri hakkýnda bir seminer içeriði.');


--Fonksiyonlar

-- fonksiyon 1 
CREATE OR REPLACE FUNCTION Mezuniyeti(p_OgrenciNo VARCHAR2) RETURN VARCHAR2 IS
    v_MezuniyetYili NUMBER;
    v_KayitYili NUMBER;
BEGIN
    -- Mezuniyet yýlý
    SELECT EXTRACT(YEAR FROM MezuniyetTarihi) INTO v_MezuniyetYili
    FROM Mezuniyet
    WHERE OgrenciNo = p_OgrenciNo;

    -- Kayýt yýlý
    SELECT EXTRACT(YEAR FROM MIN(BaslangicTarihi)) INTO v_KayitYili
    FROM Stajlar
    WHERE OgrenciNo = p_OgrenciNo;

    -- Sonuç
    RETURN 'OgrenciNo: ' || p_OgrenciNo || ', Mezuniyet Yili: ' || TO_CHAR(v_MezuniyetYili) || ', Kayit Yili: ' || TO_CHAR(v_KayitYili);
END;

--Fonksiyon 1'i çalýþtýrmak için kod
SELECT Mezuniyeti('213301032') FROM dual;


-- fonksiyon 2
CREATE OR REPLACE FUNCTION ToplamStajSuresi(p_OgrenciNo VARCHAR2) RETURN NUMBER IS
    v_ToplamSure NUMBER;
BEGIN
    SELECT SUM(BitisTarihi - BaslangicTarihi)
    INTO v_ToplamSure
    FROM Stajlar
    WHERE OgrenciNo = p_OgrenciNo;

    RETURN v_ToplamSure;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL; 
END ToplamStajSuresi;

--Fonksiyon 2'yi çalýþtýrmak için kod
DECLARE
    v_OgrenciNo VARCHAR2(30) := '213301032';
    v_ToplamSure NUMBER;
BEGIN
    v_ToplamSure := ToplamStajSuresi(v_OgrenciNo);

    DBMS_OUTPUT.PUT_LINE(v_OgrenciNo || ' Numaralý Öðrencinin Toplam Staj Süresi: ' || v_ToplamSure || ' gün');
END;


--Prosedürler

-- prosedür 1
CREATE OR REPLACE PROCEDURE MezunOlanlariListele (p_BaslangicTarihi DATE, p_BitisTarihi DATE) AS
BEGIN
    FOR dene IN (SELECT * FROM Mezuniyet WHERE MezuniyetTarihi BETWEEN p_BaslangicTarihi AND p_BitisTarihi) LOOP
        DBMS_OUTPUT.PUT_LINE('Mezun olmuþ : ' || dene.OgrenciNo || ', Tarihi: ' || dene.MezuniyetTarihi || ', Derecesi: ' || dene.Derece);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hata: ' || SQLERRM);
END MezunOlanlariListele;


    -- prosedür 1 çaðýrmak için
BEGIN
    MezunOlanlariListele(TO_DATE('2020-01-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'));
END;


--prosedür 2 
CREATE OR REPLACE PROCEDURE StajlariGoster AS
BEGIN
    FOR staj_rec IN (SELECT * FROM Stajlar) LOOP
        DBMS_OUTPUT.PUT_LINE(staj_rec.StajID || ', ' || staj_rec.OgrenciNo || ', ' || staj_rec.SirketAdi || ', ' ||
                             TO_CHAR(staj_rec.BaslangicTarihi, 'YYYY-MM-DD') || ', ' || TO_CHAR(staj_rec.BitisTarihi, 'YYYY-MM-DD'));
    END LOOP;
END StajlariGoster;

    --prosedür 2 çaðýrmak için
BEGIN
    StajlariGoster;
END;


-- Kontrol iþlemini içeren prosedür
CREATE OR REPLACE PROCEDURE MezuniyetKontrolProseduru IS
BEGIN
  -- Mezuniyet tablosunu kontrol et
  FOR mezuniyeti IN (SELECT * FROM Mezuniyet WHERE MezuniyetTarihi < SYSDATE) LOOP
    DBMS_OUTPUT.PUT_LINE('Hatalý Mezuniyet Kaydý: ' || mezuniyeti.MezuniyetID);
  END LOOP;
END;

--Prosedürü çalýþtýran kod
exec MezuniyetKontrolProseduru;

--Triggerlar

--Trigger 1
CREATE OR REPLACE TRIGGER SeminerEklendiTrigger
AFTER INSERT ON Seminerler
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Seminer tablosuna Yeni bir veri eklendi - SeminerID: ' || :NEW.SeminerID || ', Konu: ' || :NEW.Konu);
END;


-- trigger 2 
CREATE OR REPLACE TRIGGER SeminerTarihKontrolTrigger
BEFORE INSERT ON Seminerler
FOR EACH ROW
BEGIN
    IF :NEW.Tarih > SYSDATE THEN
        raise_application_error(-20001, 'Seminer tarihi bugünden sonrasý olamaz.');
    END IF;
END;


--Job
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name      => 'Mezuniyet_Kontrol_JOB',
    job_type      => 'PLSQL_BLOCK',
    job_action    => 'BEGIN
                        FOR rec IN (SELECT COUNT(*) AS yeni_veri_sayisi FROM Mezuniyet WHERE MezuniyetTarihi > SYSTIMESTAMP - INTERVAL ''1'' MINUTE) LOOP
                            IF rec.yeni_veri_sayisi > 0 THEN
                                DBMS_OUTPUT.PUT_LINE(''Yeni mezuniyet verisi eklenmiþ!'');
                            ELSE
                                DBMS_OUTPUT.PUT_LINE(''Yeni mezuniyet verisi eklenmemiþ.'');
                            END IF;
                        END LOOP;
                    END;',
    start_date    => SYSTIMESTAMP,
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
    enabled       => TRUE
  );
  DBMS_OUTPUT.PUT_LINE('Job baþarýyla yaratýldý.');
END;


--Job'ýn aktif olup olmadýðýný görme
select *
from all_scheduler_job_run_details
where job_name = 'MEZUNIYET_KONTROL_JOB';

--Log tablosunu temizleme
exec dbms_scheduler.purge_log();


--Sorgular

--Sorgu 1
SELECT o.AD, m.DERECE,M.MEZUNIYETTARIHI FROM 
Mezuniyet m join Ogrenciler o on m.OGRENCINO=o.ogrencino join Stajlar s on s.OGRENCINO =o.ogrencino;

--Sorgu 2
SELECT o.AD, ogr.GERIBILDIRIM, s.SIRKETADI, s.BITISTARIHI
FROM OgrenciGeribildirimleri ogr join Ogrenciler o 
on ogr.OGRENCINO=o.ogrencino join Stajlar s on s.OGRENCINO =o.ogrencino;

