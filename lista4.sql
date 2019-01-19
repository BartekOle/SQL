SET SERVEROUTPUT ON;
AlTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

---Zad 47

CREATE OR REPLACE TYPE KOTY_TYP AS OBJECT
(
  IMIE VARCHAR2(15),
  PLEC VARCHAR2(1),
  PSEUDO VARCHAR2(15),
  FUNKCJA VARCHAR2(10),
  SZEF REF KOTY_TYP,
  W_STADKU_OD DATE,
  PRZYDZIAL_MYSZY NUMBER(3),
  MYSZY_EXTRA NUMBER(3),
  BANDA VARCHAR2(20),
  MAP MEMBER FUNCTION OdwzorowujacaPseudo RETURN VARCHAR2,
  MEMBER FUNCTION CzySzef RETURN VARCHAR2,
  MEMBER FUNCTION SzefPseudo RETURN VARCHAR2,
  MEMBER FUNCTION DolaczylPrzed(K KOTY_TYP) RETURN VARCHAR2,
  MEMBER FUNCTION Zjada RETURN NUMBER,
  MEMBER FUNCTION ZjadaRocznie RETURN NUMBER,
  MEMBER FUNCTION ZwrocDane RETURN VARCHAR2
);



CREATE OR REPLACE TYPE BODY KOTY_TYP AS 
    MAP MEMBER FUNCTION OdwzorowujacaPseudo RETURN VARCHAR2 IS 
    BEGIN
        RETURN pseudo;
    END;
    MEMBER FUNCTION CzySzef RETURN VARCHAR2 IS 
    BEGIN
    IF szef IS NOT NULL THEN
        RETURN 'TRUE';
        END IF;
        RETURN 'FALSE';
    END;
    MEMBER FUNCTION SzefPseudo RETURN VARCHAR2 IS 
    K KOTY_TYP;
    BEGIN
      SELECT DEREF(SZEF) INTO K FROM DUAL; 
      RETURN K.PSEUDO; 
    END;
    MEMBER FUNCTION DolaczylPrzed(K KOTY_TYP) RETURN VARCHAR2 IS 
    BEGIN
        IF w_stadku_od < K.w_stadku_od THEN
          RETURN 'TRUE';
        END IF;
        RETURN 'FALSE';
    END;
    MEMBER FUNCTION Zjada RETURN NUMBER IS 
    BEGIN
        RETURN NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0);
    END;
    MEMBER FUNCTION ZjadaRocznie RETURN NUMBER IS
    BEGIN
        RETURN Zjada()*12;
    END;
    MEMBER FUNCTION ZwrocDane RETURN VARCHAR2 IS
    BEGIN
        RETURN IMIE || ', ' || PLEC || ', ' || PSEUDO || ', ' || FUNKCJA || ', ' || SzefPseudo() || ', ' || W_STADKU_OD || ', ' || NVL(PRZYDZIAL_MYSZY, 0) || ', ' || NVL(MYSZY_EXTRA, 0) || ', ' || BANDA;
    END;
END;

CREATE TABLE KOTY_TAB OF KOTY_TYP
(
  SZEF SCOPE IS KOTY_TAB,
  CONSTRAINT kot_pk PRIMARY KEY(PSEUDO),
  CONSTRAINT kot_pl_ch CHECK(plec IN ('M', 'D')),
  CONSTRAINT kot_im_nn CHECK(imie IS NOT NULL),
  w_stadku_od DEFAULT (SYSDATE)
);

INSERT INTO KOTY_TAB VALUES ('MRUCZEK', 'M', 'TYGRYS', 'SZEFUNIO', NULL, '2002-01-01', 103, 33, 'SZEFOSTWO');
INSERT INTO KOTY_TAB VALUES ('RUDA', 'D', 'MALA', 'MILUSIA', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'TYGRYS'), '2006-09-17', 22, 42, 'SZEFOSTWO');
INSERT INTO KOTY_TAB VALUES ('MICKA', 'D', 'LOLA', 'MILUSIA', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'TYGRYS'), '2009-10-14', 25, 47, 'SZEFOSTWO');
INSERT INTO KOTY_TAB VALUES ('PUCEK', 'M', 'RAFA', 'LOWCZY', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'TYGRYS'), '2006-10-15', 65, NULL, 'LACIACI MYSLIWI');
INSERT INTO KOTY_TAB VALUES ('CHYTRY', 'M', 'BOLEK', 'DZIELCZY', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'TYGRYS'), '2002-05-05', 50, NULL, 'SZEFOSTWO');
INSERT INTO KOTY_TAB VALUES ('KOREK', 'M', 'ZOMBI', 'BANDZIOR', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'TYGRYS'), '2004-03-16', 75, 13, 'BIALI LOWCY');
INSERT INTO KOTY_TAB VALUES ('BOLEK', 'M', 'LYSY', 'BANDZIOR', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'TYGRYS'), '2006-08-15', 72, 21, 'CZARNI RYCERZE');
INSERT INTO KOTY_TAB VALUES ('KSAWERY', 'M', 'MAN', 'LAPACZ', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'RAFA'), '2008-07-12', 51, NULL, 'LACIACI MYSLIWI');
INSERT INTO KOTY_TAB VALUES ('MELA', 'D', 'DAMA', 'LAPACZ', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'RAFA'), '2008-11-01', 51, NULL, 'LACIACI MYSLIWI');
INSERT INTO KOTY_TAB VALUES ('LATKA', 'D', 'UCHO', 'KOT', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'RAFA'), '2011-01-01', 40, NULL, 'LACIACI MYSLIWI');
INSERT INTO KOTY_TAB VALUES ('DUDEK', 'M', 'MALY', 'KOT', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'RAFA'), '2011-05-15', 40, NULL, 'LACIACI MYSLIWI');
INSERT INTO KOTY_TAB VALUES ('ZUZIA' ,'D', 'SZYBKA', 'LOWCZY', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'LYSY'), '2006-07-21', 65, NULL, 'CZARNI RYCERZE');
INSERT INTO KOTY_TAB VALUES ('BELA', 'D', 'LASKA', 'MILUSIA', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'LYSY'), '2008-02-01', 24, 28, 'CZARNI RYCERZE');
INSERT INTO KOTY_TAB VALUES ('JACEK', 'M', 'PLACEK', 'LOWCZY', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'LYSY'), '2008-12-01', 67, NULL, 'CZARNI RYCERZE');
INSERT INTO KOTY_TAB VALUES ('BARI', 'M', 'RURA', 'LAPACZ', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'LYSY'), '2009-09-01', 56, NULL, 'CZARNI RYCERZE');
INSERT INTO KOTY_TAB VALUES ('PUNIA', 'D', 'KURKA', 'LOWCZY', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'ZOMBI'), '2008-01-01', 61, NULL, 'BIALI LOWCY');
INSERT INTO KOTY_TAB VALUES ('SONIA', 'D', 'PUSZYSTA', 'MILUSIA', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'ZOMBI'), '2010-11-18', 20, 35, 'BIALI LOWCY');
INSERT INTO KOTY_TAB VALUES ('LUCEK', 'M', 'ZERO', 'KOT', (SELECT REF(S) FROM KOTY_TAB S WHERE S.pseudo = 'KURKA'), '2010-03-01', 43, NULL, 'BIALI LOWCY');

CREATE OR REPLACE TYPE INCYDENTY_TYP AS OBJECT
(
  NR_INCYDENTU NUMBER(10),
  KOT REF KOTY_TYP,
  IMIE_WROGA VARCHAR2(15),
  DATA_INCYDENTU DATE,
  OPIS_INCYDENTU VARCHAR2(50),
  MEMBER FUNCTION KotPseudo RETURN VARCHAR2,
  MEMBER FUNCTION IncydentPrzed(D DATE) RETURN VARCHAR2,
  MEMBER FUNCTION ZwrocDane RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY INCYDENTY_TYP AS 
    MEMBER FUNCTION KotPseudo RETURN VARCHAR2 IS 
    K KOTY_TYP;
    BEGIN
      SELECT DEREF(KOT) INTO K FROM DUAL; 
      RETURN K.PSEUDO; 
    END;
    MEMBER FUNCTION IncydentPrzed(D DATE) RETURN VARCHAR2 IS 
    BEGIN
        IF data_incydentu < D THEN
          RETURN 'TRUE';
        END IF;
        RETURN 'FALSE';
    END;
    MEMBER FUNCTION ZwrocDane RETURN VARCHAR2 IS
    BEGIN
        RETURN NR_INCYDENTU || ', ' || KotPseudo() || ', ' || IMIE_WROGA || ', ' || DATA_INCYDENTU || ', ' || OPIS_INCYDENTU;
    END;
END;


CREATE TABLE INCYDENTY_TAB OF INCYDENTY_TYP
(
  KOT SCOPE IS KOTY_TAB,
  CONSTRAINT inc_pk PRIMARY KEY (nr_incydentu),
  CONSTRAINT inc_di_nn CHECK(data_incydentu IS NOT NULL)
);

INSERT INTO INCYDENTY_TAB 
  SELECT ROWNUM,
  (SELECT REF(K) FROM KOTY_TAB K WHERE K.PSEUDO = WK.PSEUDO),
  IMIE_WROGA, DATA_INCYDENTU, OPIS_INCYDENTU
  FROM WROGOWIE_KOCUROW WK;
  
  CREATE OR REPLACE TYPE PLEBS_TYP AS OBJECT
(
  NR_PLEBS NUMBER(3),
  KOT REF KOTY_TYP,
  MEMBER FUNCTION KotPseudo RETURN VARCHAR2,
  MEMBER FUNCTION ZwrocDanePlebs RETURN VARCHAR2,
  MEMBER FUNCTION ZwrocDaneKot RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY PLEBS_TYP AS 
    MEMBER FUNCTION KotPseudo RETURN VARCHAR2 IS 
    K KOTY_TYP;
    BEGIN
      SELECT DEREF(KOT) INTO K FROM DUAL; 
      RETURN K.PSEUDO; 
    END;
    MEMBER FUNCTION ZwrocDanePlebs RETURN VARCHAR2 IS
    BEGIN
        RETURN NR_PLEBS || ', ' || KotPseudo();
    END;
    MEMBER FUNCTION ZwrocDaneKot RETURN VARCHAR2 IS
    K KOTY_TYP;
    BEGIN
        SELECT DEREF(KOT) INTO K FROM DUAL; 
        RETURN K.IMIE || ', ' || K.PLEC || ', ' || K.PSEUDO || ', ' || K.FUNKCJA || ', ' || K.SzefPseudo() || ', ' ||K.W_STADKU_OD || ', ' || NVL(K.PRZYDZIAL_MYSZY, 0) || ', ' || NVL(K.MYSZY_EXTRA, 0) || ', ' || K.BANDA;
    END;
END;

CREATE TABLE PLEBS_TAB OF PLEBS_TYP
(
  KOT SCOPE IS KOTY_TAB,
  CONSTRAINT ple_pk PRIMARY KEY (NR_PLEBS) 
);

 INSERT INTO PLEBS_TAB
  SELECT ROWNUM, REF(K) 
  FROM KOTY_TAB K 
  WHERE K.SzefPseudo() <> 'TYGRYS';
  
 CREATE OR REPLACE TYPE ELITA_TYP AS OBJECT
(
  NR_ELITA NUMBER(3),
  KOT REF KOTY_TYP,
  SLUGA REF PLEBS_TYP,
  MEMBER FUNCTION KotPseudo RETURN VARCHAR2,
  MEMBER FUNCTION SlugaPseudo RETURN VARCHAR2,
  MEMBER FUNCTION ZwrocDaneElita RETURN VARCHAR2,
  MEMBER FUNCTION ZwrocDaneKot RETURN VARCHAR2,
  MEMBER FUNCTION ZwrocDaneSluga RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY ELITA_TYP AS 
    MEMBER FUNCTION KotPseudo RETURN VARCHAR2 IS 
    K KOTY_TYP;
    BEGIN
      SELECT DEREF(KOT) INTO K FROM DUAL; 
      RETURN K.PSEUDO; 
    END;
    MEMBER FUNCTION SlugaPseudo RETURN VARCHAR2 IS 
    K PLEBS_TYP;
    BEGIN
      SELECT DEREF(SLUGA) INTO K FROM DUAL; 
      RETURN K.KotPseudo(); 
    END;
    MEMBER FUNCTION ZwrocDaneElita RETURN VARCHAR2 IS
    BEGIN
        RETURN NR_ELITA || ', ' || KotPseudo() || ', ' || SlugaPseudo();
    END;
    MEMBER FUNCTION ZwrocDaneKot RETURN VARCHAR2 IS
    K KOTY_TYP;
    BEGIN
        SELECT DEREF(KOT) INTO K FROM DUAL; 
        RETURN K.IMIE || ', ' || K.PLEC || ', ' || K.PSEUDO || ', ' || K.FUNKCJA || ', ' || K.SzefPseudo() || ', ' ||K.W_STADKU_OD || ', ' || NVL(K.PRZYDZIAL_MYSZY, 0) || ', ' || NVL(K.MYSZY_EXTRA, 0) || ', ' || K.BANDA;
    END;
    MEMBER FUNCTION ZwrocDaneSluga RETURN VARCHAR2 IS
    K PLEBS_TYP;
    BEGIN
        SELECT DEREF(SLUGA) INTO K FROM DUAL; 
        RETURN K.ZwrocDaneKot();
    END;
END;

CREATE TABLE ELITA_TAB OF ELITA_TYP
(
  KOT SCOPE IS KOTY_TAB,
  SLUGA SCOPE IS PLEBS_TAB,
  CONSTRAINT NR_KOTA_E_PK PRIMARY KEY (NR_ELITA) 
);

INSERT INTO ELITA_TAB VALUES (1, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='TYGRYS'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=10));
INSERT INTO ELITA_TAB VALUES (2, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='MALA'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=8));
INSERT INTO ELITA_TAB VALUES (3, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='LOLA'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=11));
INSERT INTO ELITA_TAB VALUES (4, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='RAFA'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=1));
INSERT INTO ELITA_TAB VALUES (5, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='BOLEK'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=3));
INSERT INTO ELITA_TAB VALUES (6, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='ZOMBI'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=5));
INSERT INTO ELITA_TAB VALUES (7, (SELECT REF(K) FROM KOTY_TAB k WHERE k.pseudo='LYSY'), (SELECT REF(S) FROM PLEBS_TAB s WHERE s.nr_plebs=7));

CREATE OR REPLACE TYPE KONTA_TYP AS OBJECT (
  NR_MYSZY NUMBER(3), 
  WLASCICIEL REF ELITA_TYP, 
  DATA_WPROWADZENIA DATE, 
  DATA_USUNIECIA DATE,
  MEMBER FUNCTION WlascicielKot RETURN KOTY_TYP,
  MEMBER FUNCTION WlascicielPseudo RETURN VARCHAR2,
  MEMBER FUNCTION CzyOddane RETURN BOOLEAN,
  MEMBER FUNCTION JakDlugo RETURN NUMBER,
  MEMBER FUNCTION ZwrocDane RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY KONTA_TYP AS 
  MEMBER FUNCTION WlascicielKot RETURN KOTY_TYP IS 
    K KOTY_TYP;
    BEGIN
      SELECT DEREF(DEREF(WLASCICIEL).KOT) INTO K FROM DUAL; 
      RETURN K; 
    END;
  MEMBER FUNCTION WlascicielPseudo RETURN VARCHAR2 IS 
    K ELITA_TYP;
    BEGIN
      SELECT DEREF(WLASCICIEL) INTO K FROM DUAL; 
      RETURN K.KotPseudo(); 
    END;
  MEMBER FUNCTION CzyOddane RETURN BOOLEAN IS 
    BEGIN
        RETURN DATA_USUNIECIA IS NOT NULL;
    END;
  MEMBER FUNCTION JakDlugo RETURN NUMBER IS
    BEGIN
      RETURN DATA_USUNIECIA - DATA_WPROWADZENIA;
    END;
  MEMBER FUNCTION ZwrocDane RETURN VARCHAR2 IS
    BEGIN
        RETURN NR_MYSZY || ', ' || WlascicielPseudo() || ', ' || DATA_WPROWADZENIA || ', ' || DATA_USUNIECIA;
    END;
END;

CREATE TABLE KONTA_TAB OF KONTA_TYP
(
  WLASCICIEL SCOPE IS ELITA_TAB,
  CONSTRAINT kon_pk PRIMARY KEY (NR_MYSZY) 
);


INSERT INTO KONTA_TAB VALUES(1,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'TYGRYS' ), SYSDATE, NULL);
INSERT INTO KONTA_TAB VALUES(2,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'MALA' ), '2018-12-21', NULL);
INSERT INTO KONTA_TAB VALUES(3,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'TYGRYS' ), '2015-02-10', '2015-03-02');
INSERT INTO KONTA_TAB VALUES(4,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'RAFA' ), '2019-01-10', '2019-01-13');
INSERT INTO KONTA_TAB VALUES(5,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'LYSY' ), '2018-11-20', NULL);
INSERT INTO KONTA_TAB VALUES(6,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'LOLA' ), '2019-01-15', NULL);
INSERT INTO KONTA_TAB VALUES(7,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'BOLEK' ), '2017-05-05', '2017-05-06');
INSERT INTO KONTA_TAB VALUES(8,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'TYGRYS' ), SYSDATE, NULL);
INSERT INTO KONTA_TAB VALUES(9,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'TYGRYS' ), '2018-12-30', NULL);
INSERT INTO KONTA_TAB VALUES(10,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'MALA' ), '2018-08-21', '2018-09-21');
INSERT INTO KONTA_TAB VALUES(11,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'TYGRYS' ), '2016-10-10', '2016-10-12');
INSERT INTO KONTA_TAB VALUES(12,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'BOLEK' ), SYSDATE, NULL);
INSERT INTO KONTA_TAB VALUES(13,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'ZOMBI' ), '2019-01-01', NULL);
INSERT INTO KONTA_TAB VALUES(14,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'ZOMBI' ), '2018-03-05', '2018-03-10');
INSERT INTO KONTA_TAB VALUES(15,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'RAFA' ), '2018-07-15', '2018-08-01');
INSERT INTO KONTA_TAB VALUES(16,(SELECT REF(E) FROM ELITA_TAB E WHERE E.KOT.PSEUDO = 'BOLEK' ), '2018-12-21', NULL);


--Przyklady

SELECT 
K.ZwrocDane() "Wszystkie dane" 
FROM KOTY_TAB K 
WHERE K.plec = 'M';

SELECT 
DECODE(plec, 'M', 'Kocur', 'D', 'Kotka') "Plec", 
SUM(K.Zjada()) "Suma myszy" 
FROM KOTY_TAB K 
GROUP BY Plec;


--21  
SELECT
  BANDA "Nazwa bandy",
  COUNT (DISTINCT pseudo)  "Koty z wrogami"
FROM
  KOTY_TAB K, INCYDENTY_TAB I
WHERE
K.pseudo = I.KotPseudo()
GROUP BY BANDA;

--22
SELECT
  FUNKCJA "Funkcja",
  PSEUDO "Pseudonim kota",
  COUNT(pseudo)  "Liczba wrogow"
FROM
  KOTY_TAB K, INCYDENTY_TAB I
WHERE
K.pseudo = I.KotPseudo()
GROUP BY K.pseudo, K.funkcja
HAVING COUNT(K.pseudo) > 1;

--35

DECLARE
  crpm NUMBER;
  imie KOTY_TAB.imie%TYPE;
  miesiac NUMBER;
  bylo BOOLEAN DEFAULT FALSE;
BEGIN
  SELECT
    imie,
    K.ZjadaRocznie(),
    EXTRACT(MONTH FROM w_stadku_od)
  INTO
    imie, crpm, miesiac
  FROM KOTY_TAB K
  WHERE pseudo='&pseudo_kota';
  IF crpm > 700 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''calkowity roczny przydzial myszy >700''');
    bylo := TRUE;
  END IF;
  IF imie LIKE '%A%' THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''imie zawiera litere A''');  
    bylo := TRUE;
  END IF;
  IF miesiac = 1 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''styczen jest miesiacem przystapienia do stada''');    
    bylo := TRUE;
  END IF;
  IF NOT bylo THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''nie odpowiada kryteriom''');      
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''nie odpowiada kryteriom''');    
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SET SERVEROUTPUT ON;
AlTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

--37
DECLARE
I NUMBER DEFAULT 1; 
BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
  DBMS_OUTPUT.PUT_LINE('------------------------');
  FOR KOT IN (SELECT K.PSEUDO, K.ZJADA() "Zjada"
              FROM KOTY_TAB K
              ORDER BY K.ZJADA() DESC)
  LOOP
    EXIT WHEN I>5;
    DBMS_OUTPUT.PUT_LINE(RPAD(I, 4)||'  '||RPAD(KOT.PSEUDO, 11)||'  '||LPAD(KOT."Zjada", 5));
    I:=I+1;
  END LOOP;
END;

--Zadanie 49

DECLARE
Polecenie VARCHAR2(1000) := 'CREATE TABLE MYSZY(
 nr_myszy INTEGER CONSTRAINT mys_pk PRIMARY KEY,
 lowca VARCHAR2(15) CONSTRAINT mys_low_fk REFERENCES KOCURY(pseudo),
 zjadacz VARCHAR2(15) CONSTRAINT mys_zja_fk REFERENCES KOCURY(pseudo),
 waga_myszy NUMBER(3) CONSTRAINT mys_wm_ch CHECK (waga_myszy BETWEEN 3 AND 29),
 data_zlowienia DATE CONSTRAINT mys_dz_nn NOT NULL,
 data_wydania DATE CONSTRAINT mys_dw_ch CHECK(data_wydania = (next_day(last_day(data_wydania)-7,''Wednesday''))),
 CONSTRAINT daty_popr CHECK (data_zlowienia <= data_wydania))';
BEGIN
 EXECUTE IMMEDIATE Polecenie;
EXCEPTION
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


DECLARE

 TYPE KOTREKORD IS RECORD (PSEUDO KOCURY.PSEUDO%TYPE, MYSZY NUMBER(3));
 TYPE KOTTABLICA IS TABLE OF KOTREKORD INDEX BY BINARY_INTEGER;
 KOTY KOTTABLICA;
 
 TYPE MYSZYTABLICA IS TABLE OF MYSZY%ROWTYPE INDEX BY BINARY_INTEGER;
 MYSZYTAB MYSZYTABLICA;
 
 DATAZLOWIENIA MYSZY.DATA_ZLOWIENIA%TYPE;
 
 OSTSRODAMIES DATE := (NEXT_DAY(LAST_DAY(TO_DATE('2004-01-01'))-7, 'Środa'));
 PIERWSZYDZIEN DATE := TO_DATE('2004-01-01');
 EWIDENCJI DATE := TO_DATE('2019-01-16');
 
 SREDLICZBAMYSZY NUMBER(5);
 
 MYSZYZLAP BINARY_INTEGER := 1;
 MYSZYPRZYDZ BINARY_INTEGER := 1;
 
BEGIN
 WHILE PIERWSZYDZIEN <= EWIDENCJI
 LOOP
 
 SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0)
 BULK COLLECT INTO KOTY
    FROM KOCURY
    WHERE W_STADKU_OD < PIERWSZYDZIEN;  
  
  SELECT ROUND(AVG(NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0))+0.5, 0)
  INTO SREDLICZBAMYSZY
  FROM KOCURY
  WHERE W_STADKU_OD < PIERWSZYDZIEN;
  
    FOR I IN 1..KOTY.COUNT
    LOOP
        FOR J IN 1..SREDLICZBAMYSZY
        LOOP
          DATAZLOWIENIA := PIERWSZYDZIEN + DBMS_RANDOM.VALUE(0,OSTSRODAMIES - PIERWSZYDZIEN);
         
          IF DATAZLOWIENIA <= EWIDENCJI THEN
          MYSZYTAB(MYSZYZLAP).NR_MYSZY := MYSZYZLAP;
          MYSZYTAB(MYSZYZLAP).LOWCA := KOTY(I).PSEUDO;
          MYSZYTAB(MYSZYZLAP).WAGA_MYSZY := DBMS_RANDOM.VALUE(3,29);
          MYSZYTAB(MYSZYZLAP).DATA_ZLOWIENIA := DATAZLOWIENIA;
            IF OSTSRODAMIES <= EWIDENCJI THEN
            MYSZYTAB(MYSZYZLAP).DATA_WYDANIA := OSTSRODAMIES;
            END IF;
           
          MYSZYZLAP:=MYSZYZLAP+1;
           
          END IF;
        
        END LOOP;
     END LOOP;
     
    IF OSTSRODAMIES <= EWIDENCJI THEN 
       FOR I IN 1..KOTY.COUNT
       LOOP
           FOR J IN 1..KOTY(I).MYSZY
            LOOP
            MYSZYTAB(MYSZYPRZYDZ).ZJADACZ := KOTY(I).PSEUDO;
            MYSZYPRZYDZ:=MYSZYPRZYDZ+1;
            END LOOP;
        END LOOP;
        
       
        WHILE MYSZYPRZYDZ < MYSZYZLAP
        LOOP
        MYSZYTAB(MYSZYPRZYDZ).ZJADACZ := 'TYGRYS';
        MYSZYPRZYDZ:=MYSZYPRZYDZ+1;
        END LOOP;
    END IF;

    PIERWSZYDZIEN := OSTSRODAMIES + 1; 
    OSTSRODAMIES := (NEXT_DAY(LAST_DAY(ADD_MONTHS(OSTSRODAMIES,1))-7, 'Środa'));
    
 END LOOP;

   FORALL I IN 1..MYSZYTAB.COUNT 
    INSERT INTO MYSZY(NR_MYSZY, LOWCA, ZJADACZ, WAGA_MYSZY, DATA_ZLOWIENIA, DATA_WYDANIA)
    VALUES(MYSZYTAB(I).NR_MYSZY, MYSZYTAB(I).LOWCA, MYSZYTAB(I).ZJADACZ, MYSZYTAB(I).WAGA_MYSZY, MYSZYTAB(I).DATA_ZLOWIENIA, MYSZYTAB(I).DATA_WYDANIA);
    
EXCEPTION
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

DECLARE
 Polecenie VARCHAR2(1000);
BEGIN
 FOR KOT IN (SELECT PSEUDO FROM KOCURY)
 LOOP
 Polecenie:='CREATE TABLE MYSZY_' || KOT.PSEUDO ||'(
 nr_myszy INTEGER CONSTRAINT pk_myszy_' || KOT.PSEUDO || ' PRIMARY KEY,
 waga_myszy NUMBER(3) CONSTRAINT waga_myszy_' || KOT.PSEUDO ||' CHECK (waga_myszy BETWEEN 3 AND 29),
 data_zlowienia DATE CONSTRAINT data_nn_' || KOT.PSEUDO ||' NOT NULL)';
 EXECUTE IMMEDIATE Polecenie;
 END LOOP;
EXCEPTION
 WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

DECLARE
 Polecenie VARCHAR2(1000);
BEGIN
 FOR KOT IN (SELECT PSEUDO FROM KOCURY)
 LOOP
 Polecenie:='DROP TABLE MYSZY_' || KOT.PSEUDO;
 EXECUTE IMMEDIATE Polecenie;
 END LOOP;
EXCEPTION
 WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

CREATE OR REPLACE PROCEDURE PRZYJMIJ_MYSZY_KOTA(KOT KOCURY.PSEUDO%TYPE, DZIEN DATE) AS
  NRMYSZY NUMBER;
  LICZBAKOTOW NUMBER;
  Polecenie VARCHAR2(1000);
  
  TYPE MYSZYTABLICA IS TABLE OF MYSZY%ROWTYPE INDEX BY BINARY_INTEGER;
  MYSZYTAB MYSZYTABLICA;
  
  TYPE MYSZYKOTARECORD IS RECORD (NR_MYSZY MYSZY.NR_MYSZY%TYPE, WAGA_MYSZY MYSZY.WAGA_MYSZY%TYPE, DATA_ZLOWIENIA MYSZY.DATA_ZLOWIENIA%TYPE);
  TYPE MYSZYKOTA IS TABLE OF WIERSZMYSZYKOTA INDEX BY BINARY_INTEGER;
  MYSZYKOTATAB MYSZYKOTA;
  
  ZLEPSEUDO EXCEPTION;
  
BEGIN

  SELECT COUNT(*) INTO LICZBAKOTOW
  FROM KOCURY
  WHERE PSEUDO = KOT;
  
  IF LICZBAKOTOW = 0 THEN
    RAISE ZLEPSEUDO;
  END IF;
  
  SELECT NVL(MAX(NR_MYSZY),0)
  INTO NRMYSZY
  FROM MYSZY;  
  
  Polecenie:='SELECT * FROM MYSZY_'||KOT||' WHERE data_zlowienia = ''' || DZIEN || '''';
  EXECUTE IMMEDIATE Polecenie
  BULK COLLECT INTO MYSZYKOTATAB;
  
    NRMYSZY:=NRMYSZY+1;
  
    FOR I IN 1..MYSZYKOTATAB.COUNT
    LOOP
    MYSZYTAB(I).NR_MYSZY := NRMYSZY;
    MYSZYTAB(I).WAGA_MYSZY := MYSZYKOTATAB(I).WAGA_MYSZY;
    MYSZYTAB(I).DATA_ZLOWIENIA := MYSZYKOTATAB(I).DATA_ZLOWIENIA;
    NRMYSZY:=NRMYSZY+1;
   END LOOP;
  
    FORALL J IN 1..MYSZYTAB.COUNT
    INSERT INTO MYSZY(NR_MYSZY, LOWCA, ZJADACZ, WAGA_MYSZY, DATA_ZLOWIENIA, DATA_WYDANIA)
    VALUES(MYSZYTAB(J).NR_MYSZY, KOT, NULL, MYSZYTAB(J).WAGA_MYSZY, MYSZYTAB(J).DATA_ZLOWIENIA, NULL);
    
    
    Polecenie:='DELETE FROM MYSZY_'||KOT||' WHERE data_zlowienia = ''' || DZIEN || '''';
    EXECUTE IMMEDIATE Polecenie;
     
  EXCEPTION
    WHEN ZLEPSEUDO THEN DBMS_OUTPUT.PUT_LINE('Podano niepoprawne pseudo.');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM); 
END PRZYJMIJ_MYSZY_KOTA;

INSERT INTO MYSZY_ZERO VALUES(1,3,TO_DATE('2019-01-17'));
INSERT INTO MYSZY_ZERO VALUES(2,29,TO_DATE('2019-01-17'));

EXECUTE PRZYJMIJ_MYSZY('ZERO',TO_DATE('2019-01-17'));

CREATE OR REPLACE PROCEDURE WYPLATA AS

  LICZBAKOTOW NUMBER;
  LICZBAMYSZY NUMBER;
  PRZYDZIELONO BOOLEAN;
  CZYPRZYDZIELACDALEJ BOOLEAN;
  LICZ NUMBER;
  SUMA NUMBER;
  
  SRODA DATE := (NEXT_DAY(LAST_DAY(SYSDATE)-7, 'Środa'));
  
  TYPE MYSZYTABLICA IS TABLE OF MYSZY%ROWTYPE INDEX BY BINARY_INTEGER;
  MYSZYTAB MYSZYTABLICA;
  
  TYPE KOTREKORD IS RECORD (PSEUDO KOCURY.PSEUDO%TYPE, MYSZY NUMBER(3));
  TYPE KOTTABLICA IS TABLE OF KOTREKORD INDEX BY BINARY_INTEGER;
  KOTY KOTTABLICA;
  
BEGIN

  SELECT * BULK COLLECT INTO MYSZYTAB
  FROM MYSZY
  WHERE ZJADACZ IS NULL;
  
  SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) BULK COLLECT INTO KOTY
  FROM KOCURY
  WHERE W_STADKU_OD <= (NEXT_DAY(LAST_DAY(ADD_MONTHS( SYSDATE, -1))-7, 'Środa'))
  START WITH SZEF IS NULL
  CONNECT BY PRIOR PSEUDO=SZEF
  ORDER BY LEVEL ASC;
  
  LICZBAKOTOW := 1;
  LICZBAMYSZY := 1;
  SUMA:=0;
  
  FOR I IN  1..KOTY.COUNT
  LOOP
    SUMA := SUMA + KOTY(I).MYSZY;
  END LOOP;
  
  WHILE LICZBAMYSZY<=MYSZYTAB.COUNT AND SUMA>0
    LOOP
         
    PRZYDZIELONO:=FALSE;
    WHILE NOT PRZYDZIELONO
      LOOP
        
        IF KOTY(LICZBAKOTOW).MYSZY > 0 THEN
          MYSZYTAB(LICZBAMYSZY).ZJADACZ := KOTY(LICZBAKOTOW).PSEUDO;
          MYSZYTAB(LICZBAMYSZY).DATA_WYDANIA := SRODA;
          KOTY(LICZBAKOTOW).MYSZY := KOTY(LICZBAKOTOW).MYSZY - 1;
          SUMA:=SUMA-1;
          PRZYDZIELONO:=TRUE;
          LICZBAMYSZY := LICZBAMYSZY + 1;
        END IF;
      
        LICZBAKOTOW := LICZBAKOTOW + 1;
        IF LICZBAKOTOW > KOTY.COUNT THEN LICZBAKOTOW:=1; END IF;
      
      END LOOP;
      
      DBMS_OUTPUT.PUT_LINE('Jest dla kogo : '||(CASE CZYPRZYDZIELACDALEJ WHEN TRUE THEN 'true' ELSE 'false' END)||' Mysz: '||TO_CHAR(LICZBAMYSZY)||' Rozmiar tablicy myszy:'||TO_CHAR(MYSZYTAB.COUNT));
    
  END LOOP;
  
  FORALL J IN 1..MYSZYTAB.COUNT SAVE EXCEPTIONS
    UPDATE MYSZY
    SET DATA_WYDANIA = MYSZYTAB(J).DATA_WYDANIA, ZJADACZ = MYSZYTAB(J).ZJADACZ
    WHERE NR_MYSZY = MYSZYTAB(J).NR_MYSZY;
    
  EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END WYPLATA;



EXECUTE WYPLATA;
ROLLBACK;
