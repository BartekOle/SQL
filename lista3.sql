SET SERVEROUTPUT ON;
AlTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- Zadanie 34

DECLARE
  liczba NUMBER;
  funk Funkcje.funkcja%TYPE;
BEGIN
  SELECT COUNT(pseudo), MIN(funkcja) INTO liczba, funk
  FROM Kocury
  WHERE funkcja = '&nazwa_funkcji';
  IF liczba > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || funk);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono');
  END IF;
END;

-- Zadanie 35

DECLARE
  crpm NUMBER;
  imie Kocury.imie%TYPE;
  miesiac NUMBER;
  bylo BOOLEAN DEFAULT FALSE;
BEGIN
  SELECT
    imie,
    (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12,
    EXTRACT(MONTH FROM w_stadku_od)
  INTO
    imie, crpm, miesiac
  FROM Kocury
  WHERE pseudo='&pseudo_kota';
  IF crpm > 700 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''calkowity roczny przydzial myszy >700''');
    bylo := TRUE;
  END IF;
  IF imie LIKE '%A%' THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''imi? zawiera litere A''');  
    bylo := TRUE;
  END IF;
  IF miesiac = 1 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''stycze? jest miesiacem przystapienia do stada''');    
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

-- Zadanie 36

SET AUTOCOMMIT OFF;

DECLARE
  CURSOR kursor IS
    SELECT * FROM Kocury
    ORDER BY przydzial_myszy ASC
    FOR UPDATE OF przydzial_myszy;
  rekord kursor%ROWTYPE;
  update_count NUMBER DEFAULT 0;
  suma NUMBER DEFAULT 0;
  funkcja_max NUMBER DEFAULT 0;
  nju NUMBER DEFAULT 0;
BEGIN
  SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
  <<zewn>>LOOP
    OPEN kursor; -- otwarcie kursowa = poczatek zapytania

    LOOP
      IF suma > 1050 THEN
        DBMS_OUTPUT.put_line('Calk. przydzial w stadku ' || suma);
        DBMS_OUTPUT.put_line('Zmian - ' || update_count);
        EXIT zewn;
      END IF;
      
      FETCH kursor INTO rekord; -- pobiera pojedynczy rekord z kursora
      EXIT WHEN kursor%NOTFOUND; -- jesli nie ma juz wiecej elementow w kursorze
      
      SELECT max_myszy INTO funkcja_max FROM Funkcje WHERE funkcja=rekord.funkcja;
      
      nju := NVL(rekord.przydzial_myszy, 0) * 1.1;
      IF nju > funkcja_max THEN
        nju := funkcja_max;
      END IF;
      
      UPDATE Kocury SET przydzial_myszy=nju WHERE pseudo=rekord.pseudo;

      update_count := update_count + 1;
      
      SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
      
    END LOOP;
    
    CLOSE kursor;
  END LOOP;
END;

SELECT imie, NVL(przydzial_myszy,0) "Myszki po podwyzce" FROM Kocury;

ROLLBACK;

-- Zadanie 37

DECLARE
  bylo BOOLEAN DEFAULT FALSE;
  empty_rezult EXCEPTION;
  nr NUMBER DEFAULT 1;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
  DBMS_OUTPUT.PUT_LINE('------------------------');
  
  FOR kot IN (
    SELECT
      pseudo,
      NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) zjada
    FROM kocury ORDER BY zjada DESC
  ) LOOP
    bylo := TRUE;
    DBMS_OUTPUT.PUT_LINE(LPAD(nr,4) || '  ' || RPAD(kot.pseudo,9) || '    ' || LPAD(kot.zjada,5) );
    nr := nr + 1;
    EXIT WHEN nr > 5;
  END LOOP;
  IF NOT bylo THEN RAISE empty_rezult; END IF;
EXCEPTION
  WHEN empty_rezult THEN DBMS_OUTPUT.PUT_LINE('Straszny b³¹d! Nie ma kotow');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;

-- Zadanie 38

DECLARE
  curr_level NUMBER DEFAULT 1;
  max_level NUMBER DEFAULT 0;
  n_level NUMBER DEFAULT &n;
  kot kocury%ROWTYPE;
BEGIN

  SELECT
    MAX(level)-1 INTO max_level
  FROM Kocury
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL;

  IF n_level > max_level THEN
    n_level := max_level;
  END IF;
  
  DBMS_OUTPUT.PUT(RPAD('Imie', 10));
  
  FOR i IN 1..n_level LOOP
    DBMS_OUTPUT.PUT('  |  ' || RPAD('Szef ' || i, 10));
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(' ');
  DBMS_OUTPUT.PUT('----------');
  FOR i IN 1..n_level LOOP
    DBMS_OUTPUT.PUT(' --- ----------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ');

  FOR rekord IN (
    SELECT * FROM Kocury
    WHERE funkcja IN ('KOT', 'MILUSIA')
  ) LOOP
    curr_level := 1;
    DBMS_OUTPUT.PUT(RPAD(rekord.imie, 10));
    kot := rekord;
    WHILE curr_level <= n_level LOOP
      IF kot.szef IS NULL THEN
        DBMS_OUTPUT.PUT('  |  ' || RPAD(' ', 10));
      ELSE
        SELECT * INTO kot FROM Kocury WHERE pseudo=kot.szef;
        DBMS_OUTPUT.put('  |  ' || RPAD(kot.imie, 10));
      END IF;
      curr_level := curr_level + 1;    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' ');
  END LOOP;
END;

-- Zadanie 39

SET AUTOCOMMIT OFF;

DECLARE
  numer_bandy bandy.nr_bandy%TYPE DEFAULT &nr;
  nazwa_bandy bandy.nazwa%TYPE DEFAULT '&nazwa';
  teren_bandy bandy.teren%TYPE DEFAULT '&teren';
  ile NUMBER DEFAULT 0;
  blad STRING(256);
  ZLY_NUMER EXCEPTION;
  ZLA_WARTOSC EXCEPTION;
BEGIN
  IF numer_bandy <= 0 THEN
    RAISE ZLY_NUMER;
  END IF;
  
  blad := '';
  
  SELECT count(nr_bandy) INTO ile FROM bandy WHERE nr_bandy = numer_bandy;
  IF ile > 0 THEN
    blad := TO_CHAR(numer_bandy);
  END IF;
  
  SELECT count(nazwa) INTO ile FROM bandy WHERE nazwa = nazwa_bandy;
  IF ile > 0 THEN
    IF LENGTH(blad) > 0 THEN
      blad := blad || ', ' || nazwa_bandy;
    ELSE
      blad := nazwa_bandy;
    END IF;
  END IF;
  
  SELECT count(teren) INTO ile FROM bandy WHERE teren = teren_bandy;
  IF ile > 0 THEN
    IF LENGTH(blad) > 0 THEN
      blad := blad || ', ' || teren_bandy;
    ELSE
      blad := teren_bandy;
    END IF;
  END IF;

  IF LENGTH(blad) > 0 THEN
    RAISE ZLA_WARTOSC;
  END IF;

  INSERT INTO bandy (nr_bandy, nazwa, teren)
  VALUES (numer_bandy, nazwa_bandy, teren_bandy);
  
EXCEPTION
  WHEN ZLY_NUMER THEN DBMS_OUTPUT.PUT_LINE('Numer musi byc > 0');
  WHEN ZLA_WARTOSC THEN DBMS_OUTPUT.PUT_LINE(blad || ': Juz istnieje');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Straszny blad!');
END;

ROLLBACK;

-- Zadanie 40

CREATE OR REPLACE PROCEDURE nowa_banda
  (numer_bandy bandy.nr_bandy%TYPE, nazwa_bandy bandy.nazwa%TYPE, teren_bandy bandy.teren%TYPE)
IS
  ile NUMBER DEFAULT 0;
  blad STRING(256);
  ZLY_NUMER EXCEPTION;
  ZLA_WARTOSC EXCEPTION;
BEGIN
  IF numer_bandy <= 0 THEN
    RAISE ZLY_NUMER;
  END IF;
  
  blad := '';
  
  SELECT count(nr_bandy) INTO ile FROM bandy WHERE nr_bandy = numer_bandy;
  IF ile > 0 THEN
    blad := TO_CHAR(numer_bandy);
  END IF;
  
  SELECT count(nazwa) INTO ile FROM bandy WHERE nazwa = nazwa_bandy;
  IF ile > 0 THEN
    IF LENGTH(blad) > 0 THEN
      blad := blad || ', ' || nazwa_bandy;
    ELSE
      blad := nazwa_bandy;
    END IF;
  END IF;
  
  SELECT count(teren) INTO ile FROM bandy WHERE teren = teren_bandy;
  IF ile > 0 THEN
    IF LENGTH(blad) > 0 THEN
      blad := blad || ', ' || teren_bandy;
    ELSE
      blad := teren_bandy;
    END IF;
  END IF;

  IF LENGTH(blad) > 0 THEN
    RAISE ZLA_WARTOSC;
  END IF;

  INSERT INTO bandy (nr_bandy, nazwa, teren)
  VALUES (numer_bandy, nazwa_bandy, teren_bandy);
  
EXCEPTION
  WHEN ZLY_NUMER THEN DBMS_OUTPUT.PUT_LINE('Numer musi byc > 0');
  WHEN ZLA_WARTOSC THEN DBMS_OUTPUT.PUT_LINE(blad || ': Juz istnieje');
--  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Straszny blad!');
END;



CREATE OR REPLACE TRIGGER zad40
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
  SELECT MAX(nr_bandy) + 1 INTO :new.nr_bandy FROM Bandy;
END;

-- Zadanie 41

CREATE OR REPLACE TRIGGER zad40
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
  SELECT MAX(nr_bandy) + 1 INTO :new.nr_bandy FROM Bandy;
END;

SET AUTOCOMMIT OFF;

BEGIN
  nowa_banda(10, 'nowabanda', 'nowyteren');
END;

SELECT nr_bandy FROM Bandy WHERE nazwa='nowabanda';

ROLLBACK;

-- Zadanie 42a

SET AUTOCOMMIT OFF;

CREATE OR REPLACE PACKAGE Zad42 AS
  przydzial NUMBER DEFAULT 0;
  kara NUMBER DEFAULT 0;
  nagroda NUMBER DEFAULT 0;
END Zad42;

CREATE OR REPLACE TRIGGER Zad42_BeforeUpdate
BEFORE UPDATE ON kocury
BEGIN
  SELECT przydzial_myszy INTO Zad42.przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER Zad42_BeforeUpdateEachRow
BEFORE UPDATE ON Kocury
FOR EACH ROW
DECLARE
  f_min NUMBER DEFAULT 0;
  f_max NUMBER DEFAULT 0;
  diff NUMBER DEFAULT 0;
BEGIN
  SELECT min_myszy, max_myszy INTO f_min, f_max
  FROM Funkcje WHERE funkcja = :new.funkcja;
  
  IF :new.funkcja = 'MILUSIA' THEN
    IF :new.przydzial_myszy < :old.przydzial_myszy THEN
      :new.przydzial_myszy := :old.przydzial_myszy;
      DBMS_OUTPUT.PUT_LINE('Zablokowano probe obnizki kota ' || :new.pseudo
          || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
    END IF;
    
    diff := :new.przydzial_myszy - :old.przydzial_myszy;
  
    IF (diff > 0) AND (diff < 0.1 * Zad42.przydzial) THEN
    
           DBMS_OUTPUT.PUT_LINE('Kara dla Tygrysa za zmiane dla kota ' || :new.pseudo
          || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);

    
       Zad42.kara := Zad42.kara + 1;
       :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * Zad42.przydzial;
       :new.myszy_extra := :new.myszy_extra + 5;
    ELSIF (diff > 0) AND (diff >= 0.1 * Zad42.przydzial) THEN
    
           DBMS_OUTPUT.PUT_LINE('Nagroda dla Tygrysa za zmiane dla kota ' || :new.pseudo
          || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);

    
       Zad42.nagroda := Zad42.nagroda + 1;
    END IF;      
  END IF;
  
  -- Sprawdzanie przekroczenia wartosci dla funkcji:
  IF :new.przydzial_myszy < f_min THEN
    :new.przydzial_myszy := f_min;
  ELSIF :new.przydzial_myszy > f_max THEN
    :new.przydzial_myszy := f_max;
  END IF;
  
END;

CREATE OR REPLACE TRIGGER Zad42_AfterUpdate
AFTER UPDATE ON Kocury
DECLARE
  tmp NUMBER DEFAULT 0;
BEGIN

  IF Zad42.kara > 0 THEN
    tmp := Zad42.kara;
    Zad42.kara := 0; 
    UPDATE Kocury SET
      przydzial_myszy = przydzial_myszy * ( 1 - (0.1 * tmp))
    WHERE pseudo = 'TYGRYS';
  END IF;
  
  IF Zad42.nagroda > 0 THEN
    tmp := Zad42.nagroda;
    Zad42.nagroda := 0; 
    UPDATE Kocury SET
      myszy_extra = myszy_extra + (tmp * 5)
    WHERE pseudo = 'TYGRYS';
  END IF;

END;

-- test 

SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 3;
SELECT * FROM Kocury;
ROLLBACK;

-- Zadanie 42b

SET AUTOCOMMIT OFF;

CREATE OR REPLACE TRIGGER Zad42_CompoundTrigger
FOR UPDATE ON Kocury
COMPOUND TRIGGER
  przydzial NUMBER DEFAULT 0;
  kara NUMBER DEFAULT 0;
  nagroda NUMBER DEFAULT 0;
  f_min NUMBER DEFAULT 0;
  f_max NUMBER DEFAULT 0;
  diff NUMBER DEFAULT 0;
  tmp NUMBER DEFAULT 0;
  
  BEFORE STATEMENT IS BEGIN
    SELECT przydzial_myszy INTO przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
  END BEFORE STATEMENT;
  
  BEFORE EACH ROW IS BEGIN
    SELECT min_myszy, max_myszy INTO f_min, f_max
    FROM Funkcje WHERE funkcja = :new.funkcja;
    
    IF :new.funkcja = 'MILUSIA' THEN
      IF :new.przydzial_myszy < :old.przydzial_myszy THEN
        :new.przydzial_myszy := :old.przydzial_myszy;
        DBMS_OUTPUT.PUT_LINE('Zablokowano probe obnizki kota ' || :new.pseudo
            || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
      END IF;
      
      diff := :new.przydzial_myszy - :old.przydzial_myszy;
    
      IF (diff > 0) AND (diff < 0.1 * przydzial) THEN
      
             DBMS_OUTPUT.PUT_LINE('Kara dla Tygrysa za zmiane dla kota ' || :new.pseudo
            || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
  
      
         kara := kara + 1;
         :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * przydzial;
         :new.myszy_extra := :new.myszy_extra + 5;
      ELSIF (diff > 0) AND (diff >= 0.1 * przydzial) THEN
      
             DBMS_OUTPUT.PUT_LINE('Nagroda dla Tygrysa za zmiane dla kota ' || :new.pseudo
            || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
  
      
         nagroda := nagroda + 1;
      END IF;      
    END IF;
    
    -- Sprawdzanie przekroczenia wartosci dla funkcji:
    IF :new.przydzial_myszy < f_min THEN
      :new.przydzial_myszy := f_min;
    ELSIF :new.przydzial_myszy > f_max THEN
      :new.przydzial_myszy := f_max;
    END IF;
  END BEFORE EACH ROW;
  
  AFTER STATEMENT IS BEGIN
    IF kara > 0 THEN
      tmp := kara;
      kara := 0; 
      UPDATE Kocury SET
        przydzial_myszy = przydzial_myszy * ( 1 - (0.1 * tmp))
      WHERE pseudo = 'TYGRYS';
    END IF;
    
    IF nagroda > 0 THEN
      tmp := nagroda;
      nagroda := 0; 
      UPDATE Kocury SET
        myszy_extra = myszy_extra + (tmp * 5)
      WHERE pseudo = 'TYGRYS';
    END IF;
  END AFTER STATEMENT;
END Zad42_CompoundTrigger;


-- test

SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 13;
SELECT * FROM Kocury;
ROLLBACK;

-- Zadanie 43

DECLARE
  CURSOR curFunkcje IS
    SELECT DISTINCT Funkcje.funkcja
    FROM Kocury
    LEFT JOIN Funkcje ON Kocury.funkcja = Funkcje.funkcja;
  CURSOR curBandy IS
    SELECT DISTINCT Bandy.nr_bandy, Bandy.nazwa
    FROM Kocury
    LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy;
  plec2 Kocury.plec%TYPE;
  ile NUMBER;
BEGIN
  DBMS_OUTPUT.PUT(RPAD('NAZWA BANDY', 20) || RPAD('PLEC', 7) || RPAD('ILE', 5));
  FOR funkcja IN curFunkcje LOOP
      DBMS_OUTPUT.PUT(RPAD(funkcja.funkcja, 10));
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(RPAD('SUMA', 10));
  DBMS_OUTPUT.PUT(LPAD(' ', 20, '-') || LPAD(' ', 7, '-') || LPAD(' ', 5, '-'));
  FOR funkcja IN curFunkcje LOOP
      DBMS_OUTPUT.PUT(' ---------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');
  
  FOR banda IN curBandy LOOP
      DBMS_OUTPUT.PUT(RPAD(banda.nazwa, 20));
      FOR i IN 1..2 LOOP
        IF i = 1 THEN
          plec2 := 'D';
          DBMS_OUTPUT.PUT(RPAD('Kotka',7));
        ELSE
          plec2 := 'M';
          DBMS_OUTPUT.PUT(RPAD(' ',20));
          DBMS_OUTPUT.PUT(RPAD('Kocur',7));
        END IF;
        
        SELECT COUNT(*) INTO ile
        FROM Kocury
        WHERE Kocury.nr_bandy = banda.nr_bandy
          AND Kocury.plec = plec2;
          
        DBMS_OUTPUT.PUT(LPAD(ile || ' ',5));
        FOR funkcja IN curFunkcje LOOP
          SELECT SUM ( CASE
            WHEN Kocury.funkcja = funkcja.funkcja THEN NVL(przydzial_myszy,0) + NVL(myszy_extra,0)
            ELSE 0
            END ) INTO ile
          FROM Kocury
          WHERE Kocury.nr_bandy = banda.nr_bandy
            AND Kocury.plec = plec2;
          DBMS_OUTPUT.PUT(LPAD(ile || ' ',10));
        END LOOP;
            
        SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) INTO ile
        FROM Kocury
        WHERE Kocury.nr_bandy = banda.nr_bandy
          AND Kocury.plec = plec2;
        
        DBMS_OUTPUT.PUT(LPAD(ile || ' ',10));
        DBMS_OUTPUT.PUT_LINE('');
      END LOOP; -- FOR i IN 1..2
  END LOOP; -- FOR banda IN curBandy
  DBMS_OUTPUT.PUT('Z' || LPAD(' ', 19, '-') || LPAD(' ', 7, '-') || LPAD(' ', 5, '-'));
  FOR funkcja IN curFunkcje LOOP
        DBMS_OUTPUT.PUT(LPAD(' ', 10, '-'));
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(LPAD(' ', 10, '-'));
  DBMS_OUTPUT.PUT(RPAD('ZJADA RAZEM', 20) || LPAD(' ', 7) || LPAD(' ', 5));
  
  FOR funkcja IN curFunkcje LOOP
    SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) INTO ile
    FROM Kocury WHERE Kocury.funkcja = funkcja.funkcja;
    
    DBMS_OUTPUT.PUT(LPAD(ile || ' ', 10));
  END LOOP;
  
  SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) INTO ile FROM Kocury;
  
  DBMS_OUTPUT.PUT(LPAD(ile || ' ',10));
  DBMS_OUTPUT.PUT_LINE('');

END;

-- Zadanie 44

CREATE OR REPLACE PACKAGE Zad44 AS

  PROCEDURE nowa_banda (
      numer_bandy bandy.nr_bandy%TYPE,
      nazwa_bandy bandy.nazwa%TYPE,
      teren_bandy bandy.teren%TYPE);
      
  FUNCTION podatek_nalezny (
      pseudonim_kota Kocury.pseudo%TYPE
    ) RETURN NUMBER;
    
END Zad44;

CREATE OR REPLACE PACKAGE BODY Zad44 AS

  -- przekopiowane z zadania 40
  PROCEDURE nowa_banda (
      numer_bandy bandy.nr_bandy%TYPE,
      nazwa_bandy bandy.nazwa%TYPE,
      teren_bandy bandy.teren%TYPE) IS
    ile NUMBER DEFAULT 0;
    blad STRING(256);
    ZLY_NUMER EXCEPTION;
    ZLA_WARTOSC EXCEPTION;
  BEGIN
    IF numer_bandy <= 0 THEN
      RAISE ZLY_NUMER;
    END IF;
    
    blad := '';
    
    SELECT count(nr_bandy) INTO ile FROM bandy WHERE nr_bandy = numer_bandy;
    IF ile > 0 THEN
      blad := TO_CHAR(numer_bandy);
    END IF;
    
    SELECT count(nazwa) INTO ile FROM bandy WHERE nazwa = nazwa_bandy;
    IF ile > 0 THEN
      IF LENGTH(blad) > 0 THEN
        blad := blad || ', ' || nazwa_bandy;
      ELSE
        blad := nazwa_bandy;
      END IF;
    END IF;
    
    SELECT count(teren) INTO ile FROM bandy WHERE teren = teren_bandy;
    IF ile > 0 THEN
      IF LENGTH(blad) > 0 THEN
        blad := blad || ', ' || teren_bandy;
      ELSE
        blad := teren_bandy;
      END IF;
    END IF;
  
    IF LENGTH(blad) > 0 THEN
      RAISE ZLA_WARTOSC;
    END IF;
  
    INSERT INTO bandy (nr_bandy, nazwa, teren)
    VALUES (numer_bandy, nazwa_bandy, teren_bandy);
    
  EXCEPTION
    WHEN ZLY_NUMER THEN DBMS_OUTPUT.PUT_LINE('Numer musi byc > 0');
    WHEN ZLA_WARTOSC THEN DBMS_OUTPUT.PUT_LINE(blad || ': Juz istnieje');
  --  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Straszny blad!');
  END;

  -- zadanie 44 w³aœciwe
  
  FUNCTION podatek_nalezny (
      pseudonim_kota Kocury.pseudo%TYPE
    ) RETURN NUMBER IS
    rezult NUMBER DEFAULT 0;
    tmp NUMBER DEFAULT 0;
  BEGIN
    
    -- podstawowy podatek
    SELECT
      CEIL( 0.05 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) ) INTO rezult
    FROM Kocury WHERE pseudo = pseudonim_kota;
    
    SELECT COUNT(pseudo) INTO tmp
    FROM Kocury WHERE szef = pseudonim_kota;
    IF tmp <= 0 THEN
      rezult := rezult + 2;
    END IF;
    
    SELECT COUNT(pseudo) INTO tmp
    FROM Wrogowie_Kocurow WHERE pseudo = pseudonim_kota;
    IF tmp <= 0 THEN
      rezult := rezult + 1;
    END IF;
    
    SELECT COUNT(pseudo) INTO tmp FROM Kocury
    WHERE pseudo = pseudonim_kota AND plec = 'M';
    IF tmp > 0 THEN
      rezult := rezult + 1;
    END IF;
    
    IF rezult < 0 THEN
      RETURN 0;
    END IF;
    
    RETURN rezult;

  END;

END Zad44;

BEGIN
  podatek_nalezny('Zero');
END;


SELECT 
pseudo,
zad44.podatek_nalezny(pseudo)
FROM Kocury;

-- Zadanie 45

DROP TABLE Dodatki_extra;
CREATE TABLE Dodatki_extra (
 id_dodatku NUMBER(2) GENERATED BY DEFAULT ON NULL AS IDENTITY
  CONSTRAINT dx_pk PRIMARY KEY,
 pseudo VARCHAR2(15) CONSTRAINT dx_fk_k REFERENCES Kocury(pseudo),
 dodatek_extra NUMBER(3) NOT NULL
);

CREATE OR REPLACE TRIGGER Zad455
AFTER UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF  :new.przydzial_myszy > :old.przydzial_myszy
  AND :new.funkcja = 'MILUSIA'
  AND LOGIN_USER != 'TYGRYS' THEN
    EXECUTE IMMEDIATE '
      DECLARE
        CURSOR curMilusie IS
          SELECT pseudo FROM Kocury WHERE funkcja = ''MILUSIA'';
      BEGIN
        FOR kot IN curMilusie LOOP
          INSERT INTO dodatki_extra(pseudo, dodatek_extra)
          VALUES (kot.pseudo, -10);
        END LOOP;
      END;';
    COMMIT;
  END IF;
END;

-- Zadanie 46

CREATE TABLE Wykroczenia (
  kto      VARCHAR2(15),
  kiedy    DATE,
  komu     VARCHAR2(15),
  operacja VARCHAR2(10)
);
 
CREATE OR REPLACE TRIGGER monitor_przedzialu
  BEFORE INSERT OR UPDATE
  ON Kocury
  FOR EACH ROW
  DECLARE
    kto      Wykroczenia.kto%TYPE;
    komu     Wykroczenia.komu%TYPE;
    kiedy    Wykroczenia.kiedy%TYPE;
    operacja Wykroczenia.operacja%TYPE;
    min_m    Funkcje.min_myszy%TYPE;
    max_m    Funkcje.max_myszy%TYPE;
      NIE_W_PRZEDZIALE EXCEPTION;
    PRAGMA AUTONOMOUS_TRANSACTION;
 
  BEGIN
    SELECT min_myszy, max_myszy
        INTO min_m,
          max_m FROM Funkcje WHERE funkcja = :new.funkcja;
 
    kto := LOGIN_USER;
    komu := :new.pseudo;
    kiedy := SYSDATE;
    IF INSERTING
    THEN operacja := 'INSERT';
    ELSE operacja := 'UPDATE';
    END IF;
 
    IF :new.przydzial_myszy < min_m OR :new.przydzial_myszy > max_m
    THEN
      INSERT INTO Wykroczenia VALUES (kto, kiedy, komu, operacja);
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001, 'Przydzial poza zakresem dla funkcji pelnionej przez kota');
    END IF;
  END;
 
SELECT *
FROM Kocury;
 
SELECT *
FROM Funkcje;
 
UPDATE Kocury
SET przydzial_myszy = 588
WHERE Kocury.pseudo = 'PLACEK';
 
SELECT *
FROM Wykroczenia;
 
-- DROP TABLE Wykroczenia;
-- DROP TRIGGER monitor_przedzialu;
 
ROLLBACK;