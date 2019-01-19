AlTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE TABLE Bandy
    (nr_bandy NUMBER(2) CONSTRAINT bnd_pk PRIMARY KEY,
    nazwa VARCHAR2(20) CONSTRAINT bnd_naz_nn NOT NULL,
    teren VARCHAR2(22) CONSTRAINT bnd_tr_un UNIQUE,
    szef_bandy VARCHAR2(15) CONSTRAINT bnd_sb_un UNIQUE                     
    );

CREATE TABLE Funkcje
    (funkcja VARCHAR2(10) CONSTRAINT fun_pk PRIMARY KEY,
    min_myszy NUMBER(3) CONSTRAINT fun_min_w CHECK(min_myszy > 5),
    max_myszy NUMBER(3) CONSTRAINT fun_max_w CHECK(200 > max_myszy),
    CONSTRAINT fun_ch CHECK(max_myszy >= min_myszy)
    );
    
CREATE TABLE Wrogowie
    (imie_wroga VARCHAR2(15) CONSTRAINT wr_pk PRIMARY KEY,
    stopien_wrogosci NUMBER(2) CONSTRAINT wr_sw_w CHECK(stopien_wrogosci between 1 AND 10),
    gatunek VARCHAR2(15),
    lapowka VARCHAR(20)
    );

CREATE TABLE Kocury
    (imie VARCHAR2(15) CONSTRAINT koc_im_nn NOT NULL,
    plec VARCHAR(1) CONSTRAINT koc_pl_ch CHECK(plec IN ('M', 'D')),
    pseudo VARCHAR(15) CONSTRAINT koc_pk PRIMARY KEY,
    funkcja VARCHAR(10) CONSTRAINT koc_fun_fk REFERENCES Funkcje(funkcja),
    szef VARCHAR2(15) CONSTRAINT koc_sz_fk REFERENCES Kocury(pseudo),
    w_stadku_od DATE DEFAULT SYSDATE,
    przydzial_myszy NUMBER(3),
    myszy_extra NUMBER(3),
    nr_bandy NUMBER(2) CONSTRAINT koc_nb_fk REFERENCES Bandy(nr_bandy)
                                            );

CREATE TABLE Wrogowie_Kocurow
    (pseudo VARCHAR2(15) CONSTRAINT wk_ps_fk REFERENCES Kocury(pseudo),
    imie_wroga VARCHAR2(15) CONSTRAINT wk_iw_fk REFERENCES Wrogowie(imie_wroga),
    data_incydentu DATE CONSTRAINT wk_di_nn NOT NULL,
    opis_incydentu VARCHAR2(50),
    CONSTRAINT wk_pk PRIMARY KEY(pseudo, imie_wroga)
    );
    
ALTER TABLE Bandy
    ADD CONSTRAINT bnd_fk FOREIGN KEY(szef_bandy)
                            REFERENCES Kocury(pseudo);

                            
ALTER TABLE Bandy
    DISABLE CONSTRAINT bnd_fk;

ALTER TABLE KOCURY
    DISABLE CONSTRAINT koc_sz_fk;
    
INSERT INTO Bandy(nr_bandy, nazwa, teren, szef_bandy) VALUES
(1, 'SZEFOSTWO', 'CALOSC', 'TYGRYS');

INSERT INTO Bandy(nr_bandy, nazwa, teren, szef_bandy) VALUES
(2, 'CZARNI RYCERZE', 'POLE', 'LYSY');

INSERT INTO Bandy(nr_bandy, nazwa, teren, szef_bandy) VALUES
(3, 'BIALI LOWCY', 'SAD', 'ZOMBI');

INSERT INTO Bandy(nr_bandy, nazwa, teren, szef_bandy) VALUES
(4, 'LACIACI MYSLIWI', 'GORKA', 'RAFA');

INSERT INTO Bandy(nr_bandy, nazwa, teren, szef_bandy) VALUES
(5, 'ROCKERSI', 'ZAGRODA', NULL);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('SZEFUNIO', 90, 110);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('BANDZIOR', 70, 90);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('LOWCZY', 60, 70);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('LAPACZ', 50, 60);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('KOT', 40, 50);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('MILUSIA', 20, 30);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('DZIELCZY', 45, 55);

INSERT INTO Funkcje(funkcja, min_myszy, max_myszy) VALUES
('HONOROWA', 6, 25);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('JACEK', 'M', 'PLACEK', 'LOWCZY', 'LYSY', '2008-12-01', 67, NULL, 2);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('BARI', 'M', 'RURA', 'LAPACZ', 'LYSY', '2009-09-01', 56, NULL, 2);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('MICKA', 'D', 'LOLA', 'MILUSIA', 'TYGRYS', '2009-10-14', 25, 47, 1);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('LUCEK', 'M', 'ZERO', 'KOT', 'KURKA', '2010-03-01', 43, NULL, 3);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('SONIA', 'D', 'PUSZYSTA', 'MILUSIA', 'ZOMBI', '2010-11-18', 20, 35, 3);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('LATKA', 'D', 'UCHO', 'KOT', 'RAFA', '2011-01-01', 40, NULL, 4);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('DUDEK', 'M', 'MALY', 'KOT', 'RAFA', '2011-05-15', 40, NULL, 4);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('MRUCZEK', 'M', 'TYGRYS', 'SZEFUNIO', NULL, '2002-01-01', 103, 33, 1);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('CHYTRY', 'M', 'BOLEK', 'DZIELCZY', 'TYGRYS', '2002-05-05', 50, NULL, 1);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('KOREK', 'M', 'ZOMBI', 'BANDZIOR', 'TYGRYS', '2004-03-16', 75, 13, 3);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('BOLEK', 'M', 'LYSY', 'BANDZIOR', 'TYGRYS', '2006-08-15', 72, 21, 2);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('ZUZIA', 'D', 'SZYBKA', 'LOWCZY', 'LYSY', '2006-07-21', 65, NULL, 2);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('RUDA', 'D', 'MALA', 'MILUSIA', 'TYGRYS', '2006-09-17', 22, 42, 1);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('PUCEK', 'M', 'RAFA', 'LOWCZY', 'TYGRYS', '2006-10-15', 65, NULL, 4);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('PUNIA', 'D', 'KURKA', 'LOWCZY', 'ZOMBI', '2008-01-01', 61, NULL, 3);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('BELA', 'D', 'LASKA', 'MILUSIA', 'LYSY', '2008-02-01', 24, 28, 2);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('KSAWERY', 'M', 'MAN', 'LAPACZ', 'RAFA', '2008-07-12', 51, NULL, 4);

INSERT INTO Kocury (imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy) VALUES
('MELA', 'D', 'DAMA', 'LAPACZ', 'RAFA', '2008-11-01', 51, NULL, 4);

ALTER TABLE Bandy
    ENABLE CONSTRAINT bnd_fk;
    
ALTER TABLE KOCURY
    ENABLE CONSTRAINT koc_sz_fk;

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('KAZIO', 10, 'CZLOWIEK', 'FLASZKA');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('GLUPIA ZOSKA', 1, 'CZLOWIEK', 'KORALIK');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('SWAWOLNY DYZIO', 7, 'CZLOWIEK', 'GUMA DO ZUCIA');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('BUREK', 4, 'PIES', 'KOSC');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('DZIKI BILL', 10, 'PIES', NULL);

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('REKSIO', 2, 'PIES', 'KOSC');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('BETHOVEN', 1, 'PIES', 'PEDIGRIPALL');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('CHYTRUSEK', 5, 'LIS', 'KURCZAK');

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('SMUKLA', 1, 'SOSNA', NULL);

INSERT INTO Wrogowie(imie_wroga, stopien_wrogosci, gatunek, lapowka) VALUES
('BAZYLI', 3, 'KOGUT', 'KURA DO STADA');    

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('TYGRYS', 'KAZIO', '2004-10-13', 'USILOWAL NABIC NA WIDLY');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('ZOMBI', 'SWAWOLNY DYZIO', '2005-03-07', 'WYBIL OKO Z PROCY');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('BOLEK', 'KAZIO', '2005-03-29', 'POSZCZUL BURKIEM');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('SZYBKA', 'GLUPIA ZOSKA', '2006-09-12', 'UZYLA KOTA JAKO SCIERKI');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('MALA', 'CHYTRUSEK', '2007-03-07', 'ZALECAL SIE');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('TYGRYS', 'DZIKI BILL', '2007-06-12', 'USILOWAL POZBAWIC ZYCIA');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('BOLEK', 'DZIKI BILL', '2007-11-10', 'ODGRYZL UCHO');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('LASKA', 'DZIKI BILL', '2008-12-12', 'POGRYZL ZE LEDWO SIE WYLIZALA');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('LASKA', 'KAZIO','2009-01-07', 'ZLAPAL ZA OGON I ZROBIL WIATRAK');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('DAMA', 'KAZIO', '2009-02-07', 'CHCIAL OBEDRZEC ZE SKORY');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('MAN', 'REKSIO', '2009-04-14', 'WYJATKOWO NIEGRZECZNIE OBSZCZEKAL');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('LYSY', 'BETHOVEN', '2009-05-11', 'NIE PODZIELIL SIE SWOJA KASZA');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('RURA', 'DZIKI BILL', '2009-09-03', 'ODGRYZL OGON');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('PLACEK', 'BAZYLI', '2010-07-12', 'DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('PUSZYSTA', 'SMUKLA','2010-11-19', 'OBRZUCILA SZYSZKAMI');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('KURKA', 'BUREK','2010-12-14', 'POGONIL');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('MALY', 'CHYTRUSEK','2011-07-13', 'PODEBRAL PODEBRANE JAJKA');

INSERT INTO Wrogowie_Kocurow(pseudo, imie_wroga, data_incydentu, opis_incydentu) VALUES
('UCHO', 'SWAWOLNY DYZIO','2011-07-14', 'OBRZUCIL KAMIENIAMI');

SELECT
  imie_wroga "WROG",
  opis_incydentu "PRZEWINA"
FROM Wrogowie_Kocurow
WHERE EXTRACT(YEAR FROM data_incydentu) = 2009;

SELECT
  imie, 
  funkcja,
  w_stadku_od "Z NAMI OD"
FROM Kocury
WHERE
  plec = 'D'
  AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';
  

SELECT
  imie_wroga "WROG",
  gatunek,
  stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

SELECT
    imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ')' || ' lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od
    "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo;

SELECT
    pseudo,
    REGEXP_REPLACE(
        REGEXP_REPLACE(pseudo, 'L', '%', 1, 1), 'A', '#', 1, 1)
    "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%A%L%' OR pseudo LIKE '%L%A%';

SELECT
    imie, 
    w_stadku_od "W stadku",
    ROUND(NVL(przydzial_myszy,0)*0.9) "Zjadal",
    ADD_MONTHS(w_stadku_od,6) "Podwyzka",
    przydzial_myszy "Zjada"
FROM Kocury
WHERE MONTHS_BETWEEN(SYSDATE, w_stadku_od) >= 108
AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9
ORDER BY przydzial_myszy DESC;

SELECT
    imie,
    NVL(przydzial_myszy, 0) * 3 "MYSZY KWARTALNIE",
    NVL(myszy_extra, 0) * 3 "KWARTALNE DODATKI"
FROM Kocury
WHERE NVL(przydzial_myszy, 0) > NVL(myszy_extra, 0)*2
AND NVL(przydzial_myszy, 0) >= 55
ORDER BY NVL(przydzial_myszy, 0) DESC, imie;

SELECT
    imie,
CASE
    WHEN (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12 > 660 THEN TO_CHAR((NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12)
    WHEN (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12 = 660 THEN 'Limit'
    ELSE 'Ponizej 660'
    END "Zjada rocznie"
FROM Kocury
ORDER BY imie;

SELECT
    pseudo,
    w_stadku_od "W STADKU",
    CASE
    WHEN EXTRACT (MONTH FROM NEXT_DAY('2018-09-25', 'ŒRODA')) = EXTRACT(MONTH FROM TO_DATE('2018-09-25')) THEN  
        CASE
        WHEN EXTRACT(DAY FROM w_stadku_od) < 16 THEN NEXT_DAY('2018-09-25', 'ŒRODA')
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2018-09-25',1))-7,'ŒRODA')
        END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2018-09-25',1))-7,'ŒRODA')
    END "WYPLATA"
    FROM KOCURY
    ORDER BY w_stadku_od;
    
SELECT
    pseudo,
    w_stadku_od "W STADKU",
    CASE
    WHEN EXTRACT (MONTH FROM NEXT_DAY('2018-09-27', 'ŒRODA')) = EXTRACT(MONTH FROM TO_DATE('2018-09-27')) THEN  
        CASE
        WHEN EXTRACT(DAY FROM w_stadku_od) < 16 THEN NEXT_DAY('2018-09-27', 'ŒRODA')
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2018-09-27',1))-7,'ŒRODA')
        END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2018-09-27',1))-7,'ŒRODA')
    END "WYPLATA"
    FROM KOCURY
    ORDER BY w_stadku_od;

SELECT
    CASE COUNT(pseudo)
    WHEN 1 THEN LPAD(pseudo, 10, ' ') || ' - Unikalny'
    ELSE pseudo || ' - nieunikalny'
    END "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;

SELECT
    CASE COUNT(szef)
    WHEN 1 THEN LPAD(szef, 10, ' ') || ' - Unikalny'
    ELSE LPAD(szef, 10, ' ') || ' - nieunikalny'
    END "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef
ORDER BY szef;

SELECT
    pseudo "Pseudonim",
    COUNT(imie_wroga) "Liczba wrogow"
FROM Wrogowie_Kocurow
GROUP BY pseudo
HAVING COUNT(imie_wroga) >= 2;

SELECT
    'Liczba kotow= ' " ",
    COUNT(funkcja) "  ",
    'lowi jako ' "   ",
    funkcja "    ",
    'i zjada max. ' "     ",
    TO_CHAR(MAX(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)), '90.99') "      ",
    'myszy miesiecznie' "       "
FROM Kocury
WHERE funkcja <> 'SZEFUNIO'
      AND plec <> 'M'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) > 50;

SELECT
    Nr_Bandy "Nr bandy",
    Plec "Plec",
    MIN(NVL(przydzial_myszy,0)) "Minimalny przydzial"
FROM Kocury
GROUP BY nr_bandy, plec;

SELECT
    LEVEL "Poziom",
    pseudo "Pseudonim      ",
    funkcja "Funkcja   ",
    nr_bandy " Nr bandy"
FROM Kocury
WHERE plec = 'M'
START WITH funkcja = 'BANDZIOR'
CONNECT BY PRIOR pseudo = szef;

SELECT
    RPAD(LPAD((LEVEL-1), (LEVEL-1)*4+1, '===>'), 16) ||
    LPAD(' ', (LEVEL-1)*4) || imie "Hierarchia",
    NVL(szef, 'Sam sobie panem') "Pseudo szefa",
    funkcja "Funkcja"
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0
START WITH szef IS NULL
CONNECT BY PRIOR pseudo = szef;


SELECT
    LPAD(' ', 4*(LEVEL-1)) || pseudo "Droga sluzbowa           "
FROM Kocury
CONNECT BY pseudo = PRIOR szef
START WITH plec = 'M'
    AND MONTHS_BETWEEN(SYSDATE, w_stadku_od) >= 108
    AND NVL(myszy_extra, 0) = 0;
    