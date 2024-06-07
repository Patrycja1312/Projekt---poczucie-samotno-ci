-- ** -- ** -- ** -- DO STRONY 1 -- ** -- ** -- ** --
-- zmiany w nazwach warto�ci dla lepszej wizualizacji --
UPDATE samotnoscdane
SET Stan_cywilny = 'W zwi�zku nieformalnym'
WHERE Stan_cywilny LIKE 'Jestem w%';

UPDATE samotnoscdane
SET Miejscowosc = 'Wielkie miasto'
WHERE Miejscowosc LIKE '%Wielkie miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Du�e miasto'
WHERE Miejscowosc LIKE '%Du�e miasto%';

UPDATE samotnoscdane
SET Miejscowosc = '�rednie miasto'
WHERE Miejscowosc LIKE '%�rednie miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Ma�e miasto'
WHERE Miejscowosc LIKE '%Ma�e miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Wie�'
WHERE Miejscowosc LIKE '%wie�%';

UPDATE samotnoscdane
SET Czy_mozna_ufac_ludziom_skala_do_10 = '10'
WHERE Czy_mozna_ufac_ludziom_skala_do_10 LIKE '10%';

UPDATE samotnoscdane
SET Czy_mozna_ufac_ludziom_skala_do_10 = '0'
WHERE Czy_mozna_ufac_ludziom_skala_do_10 LIKE '0%';


-- ** -- ** -- ** -- DO STRONY 2 -- ** -- ** -- ** --
-- Sprawdzenie jakie opcje by�y do wyboru jako odpowied� na pytanie "Jak cz�sto w ostatnim roku czu�e� si� samotny?"
SELECT DISTINCT Ostatni_rok_poczucie_samotnosci
FROM samotnoscdane;
-- Odpowiedzi: Nigdy, Rzadko, Czasami, Cz�sto

-- Ile os�b da�o poszczeg�lne odpowiedzi
SELECT Ostatni_rok_poczucie_samotnosci, COUNT(Ostatni_rok_poczucie_samotnosci) AS Ilo��
FROM samotnoscdane
GROUP BY Ostatni_rok_poczucie_samotnosci
ORDER BY Ilo�� DESC;
GO

-- ** -- WIDOK - czy osoba ankietowana do�wiadczy�a poczucia samotno�ci w ostatnim roku -- ** -- 
CREATE OR ALTER VIEW czy_doswiadczyl_poczucia_samotnosci_w_ostatnim_roku AS
SELECT Nr_ankiety,
CASE
	WHEN Ostatni_rok_poczucie_samotnosci NOT LIKE 'NIGDY' THEN 'Tak'
	ELSE 'Nie'
END AS Poczucie_samotnosci
FROM samotnoscdane;
GO

SELECT * FROM czy_doswiadczyl_poczucia_samotnosci_w_ostatnim_roku;
GO

-- ** -- WIDOK - osoby, kt�re czasami lub cz�sto w ostatnim roku do�wiadczy�y poczucia samotno�ci -- ** -- 
CREATE OR ALTER VIEW czy_doswiadczyl_czasami_lub_czesto_poczucia_samotnosci_w_ostatnim_roku AS
SELECT Nr_ankiety,
CASE
	WHEN Ostatni_rok_poczucie_samotnosci LIKE 'Cz�sto' OR Ostatni_rok_poczucie_samotnosci LIKE 'Czasami' THEN 'Tak'
	ELSE 'Nie'
END AS Poczucie_samotnosci
FROM samotnoscdane;
GO

SELECT * FROM czy_doswiadczyl_czasami_lub_czesto_poczucia_samotnosci_w_ostatnim_roku;
GO

-- ** -- WIDOK - osoby, kt�re kiedykolwiek w ostatnim roku do�wiadczy�y poczucia samotno�ci -- ** --
CREATE OR ALTER VIEW samotni AS
SELECT * 
FROM samotnoscdane
WHERE Ostatni_rok_poczucie_samotnosci NOT LIKE 'Nigdy'
GO

SELECT * FROM samotni

-- Procentowo z podzia�em na wiek i p�e� - osoby, kt�re kiedykolwiek w ostatnim roku do�wiadczy�y poczucia samotno�ci
SELECT sd.Wiek_przedzial, sd.P�e�, 
COUNT(sd.Wiek_przedzial) AS ca�o��_wiek, 
COUNT(s.Wiek_przedzial) AS samotni_wiek, 
COUNT(s.Wiek_przedzial)/CAST(COUNT(sd.Wiek_przedzial) 
AS DECIMAL(7,2))*100 AS procent
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Wiek_przedzial, sd.P�e�
ORDER BY Wiek_przedzial ASC, procent DESC
GO

-- ** -- WIDOK - osoby, kt�re czasami lub cz�sto w ostatnim roku do�wiadczy�y poczucia samotno�ci -- ** --
CREATE OR ALTER VIEW samotni_czasami_czesto AS
SELECT * 
FROM samotnoscdane
WHERE Ostatni_rok_poczucie_samotnosci LIKE 'Cz�sto' OR Ostatni_rok_poczucie_samotnosci LIKE 'Czasami'
GO

SELECT * FROM samotni_czasami_czesto

--- Procentowo z podzia�em na wiek i p�e� - osoby, kt�re czasami lub cz�sto w ostatnim roku do�wiadczy�y poczucia samotno�ci
SELECT sd.Wiek_przedzial, sd.P�e�, COUNT(sd.Wiek_przedzial) AS ca�o��_wiek, COUNT(scc.Wiek_przedzial) AS samotni_czasami_czesto_wiek, COUNT(scc.Wiek_przedzial)/CAST(COUNT(sd.Wiek_przedzial) AS DECIMAL(7,2))*100 AS procent
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Wiek_przedzial, sd.P�e�
ORDER BY Wiek_przedzial ASC, procent DESC

-- ** DZIA�ANIA NA WIDOKU samotni_czasami_czesto ** --
-- wykszta�cenie
SELECT sd.Wyksztalcenie, COUNT(sd.Wyksztalcenie) AS ca�o��_wykszta�cenie, COUNT(scc.Wyksztalcenie) AS samotni_czas_czes_wyksztalcenie, 
ROUND(COUNT(scc.Wyksztalcenie)/CAST(COUNT(sd.Wyksztalcenie) AS DECIMAL(7,2))*100,2) AS procent_wykszta�cenie
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Wyksztalcenie
ORDER BY procent_wykszta�cenie DESC

-- dzieci
SELECT sd.Mam_dzieci, COUNT(sd.Mam_dzieci) AS ca�o��_dzieci, COUNT(scc.Mam_dzieci) AS samotni_czas_czes_dzieci, (COUNT(sd.Mam_dzieci) - COUNT(scc.Mam_dzieci)) AS roznica_dzieci,
ROUND(COUNT(scc.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_dzieci,
100 - ROUND(COUNT(scc.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_roznica_dzieci
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Mam_dzieci
ORDER BY procent_dzieci DESC

-- stan_cywilny
SELECT sd.Stan_cywilny, COUNT(sd.Stan_cywilny) AS ca�o��_stan_cywilny, COUNT(scc.Stan_cywilny) AS samotni_czas_czes_stan_cywilny, 
ROUND(COUNT(scc.Stan_cywilny)/CAST(COUNT(sd.Stan_cywilny) AS DECIMAL(7,2))*100,2) AS procent_stan_cywilny
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Stan_cywilny
ORDER BY procent_stan_cywilny DESC

-- miejscowo��
SELECT sd.Miejscowosc, COUNT(sd.Miejscowosc) AS ca�o��_miejscowosc, COUNT(scc.Miejscowosc) AS samotni_czas_czes_miejscowosc, 
ROUND(COUNT(scc.Miejscowosc)/CAST(COUNT(sd.Miejscowosc) AS DECIMAL(7,2))*100,2) AS procent_miejscowosc
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Miejscowosc
ORDER BY procent_miejscowosc DESC

-- ** DZIA�ANIA NA WIDOKU samotni ** --
-- wykszta�cenie
SELECT sd.Wyksztalcenie, COUNT(sd.Wyksztalcenie) AS ca�o��_wykszta�cenie, COUNT(s.Wyksztalcenie) AS samotni_wyksztalcenie, 
ROUND(COUNT(s.Wyksztalcenie)/CAST(COUNT(sd.Wyksztalcenie) AS DECIMAL(7,2))*100,2) AS procent_wykszta�cenie
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Wyksztalcenie
ORDER BY procent_wykszta�cenie DESC

-- dzieci
SELECT sd.Mam_dzieci, COUNT(sd.Mam_dzieci) AS ca�o��_dzieci, COUNT(s.Mam_dzieci) AS samotni_dzieci, 
ROUND(COUNT(s.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_dzieci
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Mam_dzieci
ORDER BY procent_dzieci DESC

-- stan_cywilny
SELECT sd.Stan_cywilny, COUNT(sd.Stan_cywilny) AS ca�o��_stan_cywilny, COUNT(s.Stan_cywilny) AS samotni_stan_cywilny, 
ROUND(COUNT(s.Stan_cywilny)/CAST(COUNT(sd.Stan_cywilny) AS DECIMAL(7,2))*100,2) AS procent_stan_cywilny
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Stan_cywilny
ORDER BY procent_stan_cywilny DESC

-- miejscowo��
SELECT sd.Miejscowosc, COUNT(sd.Miejscowosc) AS ca�o��_miejscowosc, COUNT(s.Miejscowosc) AS samotni_miejscowosc, 
ROUND(COUNT(s.Miejscowosc)/CAST(COUNT(sd.Miejscowosc) AS DECIMAL(7,2))*100,2) AS procent_miejscowosc
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Miejscowosc
ORDER BY procent_miejscowosc DESC


-- ** -- ** -- ** -- DO STRONY 3 -- ** -- ** -- ** -
-- poczucie atrakcyjno�ci
SELECT Czy_jestem_atrakcyjny_skala_do_5, COUNT(Czy_jestem_atrakcyjny_skala_do_5) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Czy_jestem_atrakcyjny_skala_do_5
ORDER BY Ilo�� DESC;

-- poczucie szcz�cia
SELECT Jak_bardzo_jestem_szczesliwy_skala_do_5, COUNT(Jak_bardzo_jestem_szczesliwy_skala_do_5) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Jak_bardzo_jestem_szczesliwy_skala_do_5
ORDER BY Ilo�� DESC;

-- aktywno�� 7 dni
SELECT Ostatnie_7_dni_aktywnosc_powyzej_30min, COUNT(Ostatnie_7_dni_aktywnosc_powyzej_30min) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Ostatnie_7_dni_aktywnosc_powyzej_30min
ORDER BY Ilo�� DESC;

-- poczucie opuszczenia
SELECT Czuj�_si�_opuszczony, COUNT(Czuj�_si�_opuszczony) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Czuj�_si�_opuszczony
ORDER BY Ilo�� DESC;

-- jestem zupe�nie do niczego
SELECT Czasami_my�l�_�e_jestem_zupe�nie_do_niczego, COUNT(Czasami_my�l�_�e_jestem_zupe�nie_do_niczego) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Czasami_my�l�_�e_jestem_zupe�nie_do_niczego
ORDER BY Ilo�� DESC;

-- zdrowie psychiczne
SELECT COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi') AS Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, COUNT(COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi')) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi')
ORDER BY Ilo�� DESC;

-- ludzie postepuja uczciwie
SELECT Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10, 
COUNT(Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10) AS Ilo��,
CASE 
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('10%','9','8') THEN '8-10'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('0%','1','2') THEN '0-2'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('3','4') THEN '3-4'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 LIKE '5' THEN '5'
	ELSE '6-7'
END AS uczciwosc
FROM samotni_czasami_czesto
GROUP BY Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10
ORDER BY Ilo�� DESC;

-- mozna ufa� ludziom
SELECT CAST(Czy_mozna_ufac_ludziom_skala_do_10 AS Int) AS Czy_mozna_ufac_ludziom_skala_do_10, COUNT(Czy_mozna_ufac_ludziom_skala_do_10) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Czy_mozna_ufac_ludziom_skala_do_10
ORDER BY Czy_mozna_ufac_ludziom_skala_do_10 ASC;

-- my�li samob�jcze
SELECT Ostatni_rok_mysli_samobojcze, 
COUNT(Ostatni_rok_mysli_samobojcze) AS Ilo��,
CASE Ostatni_rok_mysli_samobojcze
	WHEN 'Nigdy' THEN 'Nie'
	ELSE 'Tak'
END AS Mysli_samobojcze_ost_rok
FROM samotni_czasami_czesto
GROUP BY Ostatni_rok_mysli_samobojcze
ORDER BY Ilo�� DESC;

SELECT Ostatni_rok_mysli_samobojcze, COUNT(Ostatni_rok_mysli_samobojcze)
FROM samotnoscdane
GROUP BY Ostatni_rok_mysli_samobojcze

SELECT Mam_dzieci, COUNT(Mam_dzieci) AS Ilo��
FROM samotni_czasami_czesto
GROUP BY Mam_dzieci
ORDER BY Ilo�� DESC;