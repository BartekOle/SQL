AlTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

-- zad17
SELECT
  pseudo "POLUJE W POLU",
  przydzial_myszy "PRZYDZIAL MYSZY",
  nazwa "BANDA"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
      przydzial_myszy > 50
  AND teren IN ('POLE', 'CALOSC')
ORDER BY przydzial_myszy DESC;

-- zad18
SELECT
  Kocury.imie "IMIE",
  Kocury.w_stadku_od "POLUJE OD"
FROM
  Kocury, Kocury Kocury2
WHERE
      Kocury2.imie = 'JACEK'
  AND Kocury.w_stadku_od < Kocury2.w_stadku_od
ORDER BY Kocury.w_stadku_od DESC;

-- zad19

-- a.
SELECT
  Kocury.imie "Imie",
  '|' "'|'",
  Kocury.funkcja "Funkcja",
  '|' "'|'",
  NVL(Kocury2.imie, ' ') "Szef 1",
    '|' "'|' ",
  NVL(Kocury3.imie, ' ') "Szef 2",
  '|' "'|'  ",
  NVL(Kocury4.imie, ' ') "Szef 3"
FROM
  Kocury
LEFT JOIN Kocury Kocury2 ON Kocury.szef=Kocury2.pseudo
LEFT JOIN Kocury Kocury3 ON Kocury2.szef=Kocury3.pseudo
LEFT JOIN Kocury Kocury4 ON Kocury3.szef=Kocury4.pseudo
WHERE
      Kocury.funkcja IN ('KOT', 'MILUSIA');


--b
SELECT
    korzen          "Imie",
    '|'             " ",
    funkcja         "Funkcja",
    '|'             "  ",
    NVL(szef1, ' ') "Szef 1",
     '|'             "  ",
    NVL(szef2, ' ') "Szef 2",
     '|'             "  ",
    NVL(szef3, ' ') "Szef 3"
FROM (SELECT CONNECT_BY_ROOT (imie) korzen, CONNECT_BY_ROOT (funkcja) funkcja, imie, level lvl
    FROM KOCURY
    CONNECT BY PRIOR SZEF = PSEUDO
    START WITH FUNKCJA in ('KOT', 'MILUSIA'))
    PIVOT
    (MAX(imie)
    FOR (lvl)
    IN (
      2 szef1,
      3 szef2,
      4 szef3)
    );

	

--c)
SELECT imie, funkcja, REPLACE(SUBSTR(imiona_szefow, LENGTH(imie) + 3), '/', '         | ') "Imiona kolejnych  szefow"
FROM (SELECT CONNECT_BY_ROOT(imie) imie,
             CONNECT_BY_ROOT (funkcja) funkcja,
             level lvl,
             MAX(level) OVER (PARTITION BY CONNECT_BY_ROOT (imie)) max_level,
             SYS_CONNECT_BY_PATH(imie, '/') imiona_szefow
      FROM Kocury
      CONNECT BY PRIOR szef = pseudo
      START WITH funkcja IN ('KOT', 'MILUSIA'))
WHERE lvl = max_level;

-- zad20
SELECT
  Kocury.imie "Imie kotki",
  Bandy.nazwa "Nazwa bandy",
  Wrogowie.imie_wroga "Imie wroga",
  Wrogowie.stopien_wrogosci "Ocena wroga",
  Wrogowie_Kocurow.data_incydentu "Data inc."
FROM
  Wrogowie_Kocurow
LEFT JOIN Kocury ON Wrogowie_Kocurow.pseudo=Kocury.pseudo
LEFT JOIN Bandy ON Kocury.nr_bandy=Bandy.nr_bandy
LEFT JOIN Wrogowie ON Wrogowie_Kocurow.imie_wroga=Wrogowie.imie_wroga
WHERE
      Kocury.plec = 'D'
  AND Wrogowie_Kocurow.data_incydentu > '2007-01-01'
ORDER BY Kocury.imie;

-- zad21
SELECT
  Bandy.nazwa "Nazwa bandy",
  COUNT (DISTINCT Kocury.pseudo)  "Koty z wrogami"
FROM
  Bandy
RIGHT JOIN Kocury ON Bandy.nr_bandy=Kocury.nr_bandy
JOIN Wrogowie_Kocurow ON Kocury.pseudo=Wrogowie_Kocurow.pseudo
GROUP BY Bandy.nazwa;

-- zad22
SELECT
  Kocury.funkcja "Funkcja",
  Kocury.pseudo "Pseudonim kota",
  COUNT(Wrogowie_Kocurow.pseudo)  "Liczba wrogow"
FROM
  Kocury
RIGHT JOIN Wrogowie_Kocurow ON Kocury.pseudo = Wrogowie_Kocurow.pseudo
GROUP BY Kocury.pseudo, Kocury.funkcja
HAVING COUNT(Wrogowie_Kocurow.pseudo) > 1;

-- zad23

SELECT
  imie "IMIE",
  (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 "DAWKA ROCZNA",
  'powyzej 864' "DAWKA"
FROM
  Kocury
WHERE
      NVL(myszy_extra, 0) > 0
  AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 > 864
UNION SELECT
  imie "IMIE",
  864 "DAWKA ROCZNA",
  '864' "DAWKA"
FROM
  Kocury
WHERE
      NVL(myszy_extra, 0) > 0
  AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 = 864
UNION SELECT
  imie "IMIE",
  (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 "DAWKA ROCZNA",
  'ponizej 864' "DAWKA"
FROM
  Kocury
WHERE
      NVL(myszy_extra, 0) > 0
  AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 < 864
ORDER BY "DAWKA ROCZNA" DESC;

-- zad24

--a

SELECT
  Bandy.nr_bandy "NR BANDY",
  Bandy.nazwa "NAZWA",
  Bandy.teren "TEREN"
FROM
  Bandy
LEFT JOIN Kocury ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE Kocury.nr_bandy IS NULL;

--b

SELECT
  Bandy.nr_bandy "NR BANDY",
  Bandy.nazwa "NAZWA",
  Bandy.teren "TEREN"
FROM
  Bandy
MINUS
SELECT
  Bandy.nr_bandy "NR BANDY",
  Bandy.nazwa "NAZWA",
  Bandy.teren "TEREN"
FROM
Bandy RIGHT JOIN KOCURY ON Bandy.nr_bandy = KOCURY.nr_bandy;

-- zad25

SELECT IMIE, FUNKCJA, PRZYDZIAL_MYSZY
FROM KOCURY
WHERE PRZYDZIAL_MYSZY >= ALL (SELECT 3 * PRZYDZIAL_MYSZY
                              FROM KOCURY K LEFT JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
                              WHERE (B.TEREN = 'SAD' or B.TEREN = 'CALOSC')
                              AND K.FUNKCJA = 'MILUSIA');

-- zad26

SELECT
  funkcja "Funkcja",
  ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) )) "Srednio najw. i najm. myszy"
FROM
  Kocury
WHERE
  funkcja <> 'SZEFUNIO'
GROUP BY
  funkcja
HAVING
  ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) ))
  IN ( (
      SELECT * FROM (
        SELECT ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) )) x
        FROM Kocury
        WHERE funkcja != 'SZEFUNIO'
        GROUP BY funkcja
        ORDER BY x ASC
      ) WHERE rownum=1
    ), (
      SELECT * FROM (
        SELECT ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) )) x
        FROM Kocury
        WHERE funkcja != 'SZEFUNIO'
        GROUP BY funkcja
        ORDER BY x DESC
      ) WHERE rownum=1
    ));
    
-- zad27

--a

SELECT
  pseudo "PSEUDO",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA"
FROM
  Kocury
WHERE
  &n >= (
    SELECT COUNT(*)
    FROM Kocury Kocury2
    WHERE NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0)
       < NVL(Kocury2.przydzial_myszy,0) + NVL(Kocury2.myszy_extra,0)
  )
ORDER BY "ZJADA" DESC;

--b

SELECT
  pseudo "PSEUDO",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA"
FROM
  Kocury
WHERE
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) >= ANY(
      SELECT x FROM (
      SELECT DISTINCT(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) x
      FROM Kocury
      ORDER BY x DESC
    ) WHERE rownum <= &n
  )
ORDER BY "ZJADA" DESC;

--c

SELECT
  Kocury.pseudo "PSEUDO",
  NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0) "ZJADA"
FROM
  Kocury, Kocury Kocury2
WHERE
     NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0)
  <= NVL(Kocury2.przydzial_myszy,0) + NVL(Kocury2.myszy_extra,0)
GROUP BY
  Kocury.pseudo, NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0)
HAVING
  COUNT(DISTINCT (NVL(Kocury2.przydzial_myszy,0) + NVL(Kocury2.myszy_extra,0)))
    <= &n
ORDER BY "ZJADA" DESC;

--d

SELECT PSEUDO, zjada FROM
                          (SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) AS zjada, 
                          DENSE_RANK()
                          OVER (
                          ORDER BY NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA,0) DESC ) rank
FROM KOCURY)
WHERE rank<=&n;

-- zad28

SELECT
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
  COUNT(pseudo) "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
HAVING
  COUNT(pseudo) = (
    SELECT * FROM (
      SELECT MIN(COUNT(pseudo)) FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(pseudo) >= (SELECT AVG(COUNT(pseudo)) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
    ) 
  )
UNION SELECT
  'Srednia' "ROK",
  ROUND(AVG(COUNT(pseudo)), 7)  "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
UNION  SELECT
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
  COUNT(pseudo) "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
HAVING
  COUNT(pseudo) = (
    SELECT * FROM (
      SELECT MAX(COUNT(pseudo)) FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(pseudo) <= (SELECT AVG(COUNT(pseudo)) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      
    )
  )
ORDER BY "LICZBA WSTAPIEN";

SELECT
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
  COUNT(pseudo) "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
HAVING
  COUNT(pseudo) = (
    SELECT * FROM (
      SELECT COUNT(pseudo) FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(pseudo) >= (SELECT AVG(COUNT(pseudo)) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      ORDER BY COUNT(pseudo) ASC
    ) WHERE rownum=1
  )
UNION SELECT
  'Srednia' "ROK",
  ROUND(AVG(COUNT(pseudo)), 7)  "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
UNION  SELECT
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
  COUNT(pseudo) "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
HAVING
  COUNT(pseudo) = (
    SELECT * FROM (
      SELECT COUNT(pseudo) FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(pseudo) <= (SELECT AVG(COUNT(pseudo)) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      ORDER BY COUNT(pseudo) DESC
    ) WHERE rownum=1
  )
ORDER BY "LICZBA WSTAPIEN";
-- zad29

-- a

SELECT
  Kocury.imie "IMIE",
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0)  "ZJADA",
  Kocury2.nr_bandy "NR BANDY",
  TO_CHAR(
    AVG(NVL(Kocury2.przydzial_myszy, 0) + NVL(Kocury2.myszy_extra, 0))
  , '99.99') "SREDNIA BANDY"
FROM
  Kocury
RIGHT JOIN Kocury Kocury2 ON Kocury.nr_bandy = Kocury2.nr_bandy
WHERE
  Kocury.plec = 'M'
GROUP BY
  Kocury2.nr_bandy, Kocury.pseudo, Kocury.imie, NVL(Kocury.PRZYDZIAl_MYSZY,0) + NVL(Kocury.MYSZY_EXTRA,0)
HAVING
     NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0)
  <= AVG(NVL(Kocury2.przydzial_myszy, 0) + NVL(Kocury2.myszy_extra, 0))
ORDER BY "SREDNIA BANDY";

-- b

SELECT
  Kocury.imie "IMIE",
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) "ZJADA",
  Kocury.nr_bandy "NR BANDY",
  TO_CHAR(srednia, '99.99') "SREDNIA BANDY"
FROM
  Kocury
LEFT JOIN (
  SELECT
    AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) srednia,
    nr_bandy banda
  FROM Kocury GROUP BY nr_bandy
) ON banda=Kocury.nr_bandy
WHERE
      NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) < srednia
  AND plec = 'M'
ORDER BY "SREDNIA BANDY";

-- c

SELECT
  Kocury.imie "IMIE",
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) "ZJADA",
  Kocury.nr_bandy "NR BANDY",
  ( SELECT
      TO_CHAR(AVG(NVL(x.przydzial_myszy, 0) + NVL(x.myszy_extra, 0)), '99.99')
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ) "SREDNIA BANDY"
FROM
  Kocury
WHERE
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) < (
    SELECT AVG(NVL(x.przydzial_myszy, 0) + NVL(x.myszy_extra, 0))
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ) AND plec = 'M'
  ORDER BY 3 DESC;
  
-- zad30

SELECT
  Kocury.imie "IMIE",
  Kocury.w_stadku_od || ' <---' "WSTAPIL DO STADKA",
  'NAJSTARSZY STAZEM W BANDZIE ' || Bandy.nazwa " "
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
  Kocury.w_stadku_od = (
    SELECT MIN(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  )
UNION SELECT
  Kocury.imie "IMIE",
  Kocury.w_stadku_od || ' <---' "WSTAPIL DO STADKA",
  'NAJMLODSZY STAZEM W BANDZIE ' || Bandy.nazwa " "
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
  Kocury.w_stadku_od = (
    SELECT MAX(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  )
UNION SELECT
  Kocury.imie "IMIE",
  TO_CHAR(Kocury.w_stadku_od) "WSTAPIL DO STADKA",
  ' ' " "
FROM
  Kocury
WHERE
  Kocury.w_stadku_od NOT IN (
  (
    SELECT MAX(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ),(
    SELECT MIN(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ));
  
-- zad31

DROP VIEW Perspektywa;
CREATE VIEW Perspektywa (
  NAZWA_BANDY, SRE_SPOZ, MAX_SPOZ, MIN_SPOZ, KOTY, KOTY_Z_DOD
) AS SELECT
  Bandy.nazwa,
  AVG(NVL(przydzial_myszy, 0)) " ",
  MAX(NVL(przydzial_myszy, 0)) " ",
  MIN(NVL(przydzial_myszy, 0)) " ",
  COUNT(pseudo),
  COUNT(myszy_extra)
FROM BANDY, KOCURY
WHERE BANDY.NR_BANDY = KOCURY.NR_BANDY
GROUP BY Bandy.nazwa;

SELECT * FROM Perspektywa;

SELECT
  pseudo "PSEUDONIM",
  imie  "IMIE",
  funkcja "FUNKCJA",
  NVL(przydzial_myszy, 0) "ZJADA",
  'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "GRANICE SPOZYCIA",
  w_stadku_od "LOWI OD"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
LEFT JOIN Perspektywa ON Bandy.nazwa = NAZWA_BANDY
WHERE
  pseudo = '&p';
  
-- zad32

SELECT
  pseudo "Pseudonim",
  plec "Plec",
  NVL(przydzial_myszy, 0) "Myszy przed podw.",
  NVL(myszy_extra, 0) "Extra przed podw."
FROM
  Kocury
WHERE KOCURY.PSEUDO IN ( (SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'CZARNI RYCERZE'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3)
UNION
( SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'LACIACI MYSLIWI'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3));

SET AUTOCOMMIT OFF;

UPDATE KOCURY
SET KOCURY.PRZYDZIAL_MYSZY = CASE KOCURY.PLEC
    WHEN 'M' THEN NVL(kocury.PRZYDZIAL_MYSZY,0) + 10
    WHEN 'D' THEN NVL(KOCURY.PRZYDZIAL_MYSZY,0) + (
      SELECT MIN(NVL(K.przydzial_myszy, 0)) FROM Kocury K
    ) * 0.1
END
WHERE KOCURY.PSEUDO IN ( (SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'CZARNI RYCERZE'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3)
UNION ALL
( SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'LACIACI MYSLIWI'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3));


UPDATE KOCURY
SET KOCURY.MYSZY_EXTRA = (NVL(KOCURY.MYSZY_EXTRA, 0) +  (SELECT AVG(nvl(K.MYSZY_EXTRA, 0)) FROM KOCURY K
                                                      GROUP BY K.NR_BANDY
                                                      HAVING K.NR_BANDY = KOCURY.NR_BANDY)  * 0.15)
WHERE KOCURY.PSEUDO IN ( (SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'CZARNI RYCERZE'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3)
UNION ALL
( SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'LACIACI MYSLIWI'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3));

SELECT
  pseudo "Pseudonim",
  plec "Plec",
  NVL(przydzial_myszy, 0) "Myszy po podw.",
  NVL(myszy_extra, 0) "Extra po podw."
FROM
  Kocury
WHERE KOCURY.PSEUDO IN ( (SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'CZARNI RYCERZE'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3)
UNION ALL
( SELECT * FROM
                        (SELECT K1.PSEUDO
                        FROM KOCURY K1 JOIN BANDY B ON K1.NR_BANDY = B.NR_BANDY
                        WHERE B.NAZWA = 'LACIACI MYSLIWI'
                        ORDER BY K1.W_STADKU_OD ASC)
                           WHERE ROWNUM <= 3));

ROLLBACK;

--zad 33

--a

SELECT * FROM ( 
SELECT
  DECODE(plec, 'M', ' ', 'D', nazwa) "NAZWA BANDY",
  DECODE(plec, 'M', 'Kocur', 'D', 'Kotka') "PLEC",
  TO_CHAR(count(*)) "ILE",
  TO_CHAR(SUM(DECODE(funkcja,
    'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "SZEFUNIO",
  TO_CHAR(SUM(DECODE(funkcja,
    'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "BANDZIOR",
  TO_CHAR(SUM(DECODE(funkcja,
    'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LOWCZY",
  TO_CHAR(SUM(DECODE(funkcja,
    'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,
    'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "KOT",
  TO_CHAR(SUM(DECODE(funkcja,
    'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,
    'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "SUMA"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
GROUP BY
  nazwa, plec
ORDER BY nazwa ASC )
UNION ALL SELECT
  'Z----------------',
  '------',
  '----',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '-------'
FROM DUAL
UNION ALL SELECT
  'ZJADA RAZEM',
  ' ',
  ' ',
  TO_CHAR(SUM(DECODE(funkcja,
    'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "SZEFUNIO",
  TO_CHAR(SUM(DECODE(funkcja,
    'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "BANDZIOR",
  TO_CHAR(SUM(DECODE(funkcja,
    'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LOWCZY",
  TO_CHAR(SUM(DECODE(funkcja,
    'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,
    'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "KOT",
  TO_CHAR(SUM(DECODE(funkcja,
    'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,
    'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "SUMA"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy;




-- b

SELECT *
FROM (SELECT DECODE(plec, 'Kocur', ' ', 'Kotka', nazwa) "NAZWA BANDY",
             plec,
             TO_CHAR(SUM(ILE))                          "ILE",
             TO_CHAR(NVL(SUM("SZEFUNIO"), 0))           "SZEFUNIO",
             TO_CHAR(NVL(SUM("BANDZIOR"), 0))           "BANDZIOR",
             TO_CHAR(NVL(SUM("LOWCZY"), 0))             "LOWCZY",
             TO_CHAR(NVL(SUM("LAPACZ"), 0))             "LAPACZ",
             TO_CHAR(NVL(SUM("KOT"), 0))                "KOT",
             TO_CHAR(NVL(SUM("MILUSIA"), 0))            "MILUSIA",
             TO_CHAR(NVL(SUM("DZIELCZY"), 0))           "DZIELCZY",
             TO_CHAR(SUM(SUMA))                         "SUMA"
      FROM (SELECT nazwa,
                   funkcja,
                   DECODE(plec, 'M', 'Kocur', 'D', 'Kotka')   AS PLEC,
                   COUNT(plec)                                AS ILE,
                   NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)         zjada,
                   SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) AS SUMA,
                   przydzial_myszy,
                   myszy_extra
            FROM KOCURY K
                   JOIN BANDY B on K.NR_BANDY = B.NR_BANDY
            GROUP BY nazwa, funkcja, plec, DECODE(plec, 'M', 'Kocor', 'D', 'Kotka'),
                     NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), przydzial_myszy, myszy_extra)
          PIVOT
          (SUM(zjada)
          FOR funkcja
          IN ('SZEFUNIO' "SZEFUNIO", 'BANDZIOR' "BANDZIOR", 'LOWCZY' "LOWCZY", 'LAPACZ' "LAPACZ", 'KOT' "KOT", 'MILUSIA' "MILUSIA", 'DZIELCZY' "DZIELCZY"))
      GROUP BY nazwa, plec
      ORDER BY nazwa, plec desc)

UNION ALL

SELECT 'Z----------------',
       '------',
       '----',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '-------'
FROM DUAL
UNION ALL
SELECT 'ZJADA RAZEM',
       ' ',
       ' ',
       TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', przydzial_myszy + NVL(myszy_extra, 0), 0))) "SZEFUNIO",
       TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', przydzial_myszy + NVL(myszy_extra, 0), 0))) "BANDZIOR",
       TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', przydzial_myszy + NVL(myszy_extra, 0), 0)))   "LOWCZY",
       TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', przydzial_myszy + NVL(myszy_extra, 0), 0)))   "LAPACZ",
       TO_CHAR(SUM(DECODE(funkcja, 'KOT', przydzial_myszy + NVL(myszy_extra, 0), 0)))      "KOT",
       TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', przydzial_myszy + NVL(myszy_extra, 0), 0)))  "MILUSIA",
       TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', przydzial_myszy + NVL(myszy_extra, 0), 0))) "DZIELCZY",
       TO_CHAR(SUM(przydzial_myszy + NVL(myszy_extra, 0)))                                 "SUMA"
FROM KOCURY
       LEFT JOIN BANDY ON KOCURY.nr_bandy = BANDY.nr_bandy;
       
       
       
