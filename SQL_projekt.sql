-- ** -- ** -- ** -- DO STRONY 1 -- ** -- ** -- ** --
-- zmiany w nazwach wartości dla lepszej wizualizacji --
UPDATE samotnoscdane
SET Stan_cywilny = 'W związku nieformalnym'
WHERE Stan_cywilny LIKE 'Jestem w%';

UPDATE samotnoscdane
SET Miejscowosc = 'Wielkie miasto'
WHERE Miejscowosc LIKE '%Wielkie miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Duże miasto'
WHERE Miejscowosc LIKE '%Duże miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Średnie miasto'
WHERE Miejscowosc LIKE '%Średnie miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Małe miasto'
WHERE Miejscowosc LIKE '%Małe miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Wieś'
WHERE Miejscowosc LIKE '%wieś%';

UPDATE samotnoscdane
SET Czy_mozna_ufac_ludziom_skala_do_10 = '10'
WHERE Czy_mozna_ufac_ludziom_skala_do_10 LIKE '10%';

UPDATE samotnoscdane
SET Czy_mozna_ufac_ludziom_skala_do_10 = '0'
WHERE Czy_mozna_ufac_ludziom_skala_do_10 LIKE '0%';


-- ** -- ** -- ** -- DO STRONY 2 -- ** -- ** -- ** --
-- Sprawdzenie jakie opcje były do wyboru jako odpowiedź na pytanie "Jak często w ostatnim roku czułeś się samotny?"
SELECT DISTINCT Ostatni_rok_poczucie_samotnosci
FROM samotnoscdane;
-- Odpowiedzi: Nigdy, Rzadko, Czasami, Często

-- Ile osób dało poszczególne odpowiedzi
SELECT Ostatni_rok_poczucie_samotnosci, COUNT(Ostatni_rok_poczucie_samotnosci) AS Ilość
FROM samotnoscdane
GROUP BY Ostatni_rok_poczucie_samotnosci
ORDER BY Ilość DESC;
GO

-- ** -- WIDOK - czy osoba ankietowana doświadczyła poczucia samotności w ostatnim roku -- ** -- 
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

-- ** -- WIDOK - osoby, które czasami lub często w ostatnim roku doświadczyły poczucia samotności -- ** -- 
CREATE OR ALTER VIEW czy_doswiadczyl_czasami_lub_czesto_poczucia_samotnosci_w_ostatnim_roku AS
SELECT Nr_ankiety,
CASE
	WHEN Ostatni_rok_poczucie_samotnosci LIKE 'Często' OR Ostatni_rok_poczucie_samotnosci LIKE 'Czasami' THEN 'Tak'
	ELSE 'Nie'
END AS Poczucie_samotnosci
FROM samotnoscdane;
GO

SELECT * FROM czy_doswiadczyl_czasami_lub_czesto_poczucia_samotnosci_w_ostatnim_roku;
GO

-- ** -- WIDOK - osoby, które kiedykolwiek w ostatnim roku doświadczyły poczucia samotności -- ** --
CREATE OR ALTER VIEW samotni AS
SELECT * 
FROM samotnoscdane
WHERE Ostatni_rok_poczucie_samotnosci NOT LIKE 'Nigdy'
GO

SELECT * FROM samotni

-- Procentowo z podziałem na wiek i płeć - osoby, które kiedykolwiek w ostatnim roku doświadczyły poczucia samotności
SELECT sd.Wiek_przedzial, sd.Płeć, 
COUNT(sd.Wiek_przedzial) AS całość_wiek, 
COUNT(s.Wiek_przedzial) AS samotni_wiek, 
COUNT(s.Wiek_przedzial)/CAST(COUNT(sd.Wiek_przedzial) 
AS DECIMAL(7,2))*100 AS procent
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Wiek_przedzial, sd.Płeć
ORDER BY Wiek_przedzial ASC, procent DESC
GO

-- ** -- WIDOK - osoby, które czasami lub często w ostatnim roku doświadczyły poczucia samotności -- ** --
CREATE OR ALTER VIEW samotni_czasami_czesto AS
SELECT * 
FROM samotnoscdane
WHERE Ostatni_rok_poczucie_samotnosci LIKE 'Często' OR Ostatni_rok_poczucie_samotnosci LIKE 'Czasami'
GO

SELECT * FROM samotni_czasami_czesto

--- Procentowo z podziałem na wiek i płeć - osoby, które czasami lub często w ostatnim roku doświadczyły poczucia samotności
SELECT sd.Wiek_przedzial, sd.Płeć, COUNT(sd.Wiek_przedzial) AS całość_wiek, COUNT(scc.Wiek_przedzial) AS samotni_czasami_czesto_wiek, COUNT(scc.Wiek_przedzial)/CAST(COUNT(sd.Wiek_przedzial) AS DECIMAL(7,2))*100 AS procent
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Wiek_przedzial, sd.Płeć
ORDER BY Wiek_przedzial ASC, procent DESC

-- ** DZIAŁANIA NA WIDOKU samotni_czasami_czesto ** --
-- wykształcenie
SELECT sd.Wyksztalcenie, COUNT(sd.Wyksztalcenie) AS całość_wykształcenie, COUNT(scc.Wyksztalcenie) AS samotni_czas_czes_wyksztalcenie, 
ROUND(COUNT(scc.Wyksztalcenie)/CAST(COUNT(sd.Wyksztalcenie) AS DECIMAL(7,2))*100,2) AS procent_wykształcenie
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Wyksztalcenie
ORDER BY procent_wykształcenie DESC

-- dzieci
SELECT sd.Mam_dzieci, COUNT(sd.Mam_dzieci) AS całość_dzieci, COUNT(scc.Mam_dzieci) AS samotni_czas_czes_dzieci, (COUNT(sd.Mam_dzieci) - COUNT(scc.Mam_dzieci)) AS roznica_dzieci,
ROUND(COUNT(scc.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_dzieci,
100 - ROUND(COUNT(scc.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_roznica_dzieci
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Mam_dzieci
ORDER BY procent_dzieci DESC

-- stan_cywilny
SELECT sd.Stan_cywilny, COUNT(sd.Stan_cywilny) AS całość_stan_cywilny, COUNT(scc.Stan_cywilny) AS samotni_czas_czes_stan_cywilny, 
ROUND(COUNT(scc.Stan_cywilny)/CAST(COUNT(sd.Stan_cywilny) AS DECIMAL(7,2))*100,2) AS procent_stan_cywilny
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Stan_cywilny
ORDER BY procent_stan_cywilny DESC

-- miejscowość
SELECT sd.Miejscowosc, COUNT(sd.Miejscowosc) AS całość_miejscowosc, COUNT(scc.Miejscowosc) AS samotni_czas_czes_miejscowosc, 
ROUND(COUNT(scc.Miejscowosc)/CAST(COUNT(sd.Miejscowosc) AS DECIMAL(7,2))*100,2) AS procent_miejscowosc
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Miejscowosc
ORDER BY procent_miejscowosc DESC

-- ** DZIAŁANIA NA WIDOKU samotni ** --
-- wykształcenie
SELECT sd.Wyksztalcenie, COUNT(sd.Wyksztalcenie) AS całość_wykształcenie, COUNT(s.Wyksztalcenie) AS samotni_wyksztalcenie, 
ROUND(COUNT(s.Wyksztalcenie)/CAST(COUNT(sd.Wyksztalcenie) AS DECIMAL(7,2))*100,2) AS procent_wykształcenie
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Wyksztalcenie
ORDER BY procent_wykształcenie DESC

-- dzieci
SELECT sd.Mam_dzieci, COUNT(sd.Mam_dzieci) AS całość_dzieci, COUNT(s.Mam_dzieci) AS samotni_dzieci, 
ROUND(COUNT(s.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_dzieci
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Mam_dzieci
ORDER BY procent_dzieci DESC

-- stan_cywilny
SELECT sd.Stan_cywilny, COUNT(sd.Stan_cywilny) AS całość_stan_cywilny, COUNT(s.Stan_cywilny) AS samotni_stan_cywilny, 
ROUND(COUNT(s.Stan_cywilny)/CAST(COUNT(sd.Stan_cywilny) AS DECIMAL(7,2))*100,2) AS procent_stan_cywilny
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Stan_cywilny
ORDER BY procent_stan_cywilny DESC

-- miejscowość
SELECT sd.Miejscowosc, COUNT(sd.Miejscowosc) AS całość_miejscowosc, COUNT(s.Miejscowosc) AS samotni_miejscowosc, 
ROUND(COUNT(s.Miejscowosc)/CAST(COUNT(sd.Miejscowosc) AS DECIMAL(7,2))*100,2) AS procent_miejscowosc
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Miejscowosc
ORDER BY procent_miejscowosc DESC


-- ** -- ** -- ** -- DO STRONY 3 -- ** -- ** -- ** --
-- analiza jak osoby samotne odpowiedziały na inne pytania
	
-- poczucie atrakcyjności
SELECT Czy_jestem_atrakcyjny_skala_do_5, COUNT(Czy_jestem_atrakcyjny_skala_do_5) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Czy_jestem_atrakcyjny_skala_do_5
ORDER BY Ilość DESC;

-- poczucie szczęścia
SELECT Jak_bardzo_jestem_szczesliwy_skala_do_5, COUNT(Jak_bardzo_jestem_szczesliwy_skala_do_5) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Jak_bardzo_jestem_szczesliwy_skala_do_5
ORDER BY Ilość DESC;

-- aktywność 7 dni
SELECT Ostatnie_7_dni_aktywnosc_powyzej_30min, COUNT(Ostatnie_7_dni_aktywnosc_powyzej_30min) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Ostatnie_7_dni_aktywnosc_powyzej_30min
ORDER BY Ilość DESC;

-- poczucie opuszczenia
SELECT Czuję_się_opuszczony, COUNT(Czuję_się_opuszczony) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Czuję_się_opuszczony
ORDER BY Ilość DESC;

-- jestem zupełnie do niczego
SELECT Czasami_myślę_że_jestem_zupełnie_do_niczego, COUNT(Czasami_myślę_że_jestem_zupełnie_do_niczego) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Czasami_myślę_że_jestem_zupełnie_do_niczego
ORDER BY Ilość DESC;

-- zdrowie psychiczne
SELECT COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi') AS Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, COUNT(COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi')) AS Ilość
FROM samotni_czasami_czesto
GROUP BY COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi')
ORDER BY Ilość DESC;

-- ludzie postepuja uczciwie
SELECT Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10, 
COUNT(Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10) AS Ilość,
CASE 
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('10%','9','8') THEN '8-10'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('0%','1','2') THEN '0-2'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('3','4') THEN '3-4'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 LIKE '5' THEN '5'
	ELSE '6-7'
END AS uczciwosc
FROM samotni_czasami_czesto
GROUP BY Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10
ORDER BY Ilość DESC;

-- mozna ufać ludziom
SELECT CAST(Czy_mozna_ufac_ludziom_skala_do_10 AS Int) AS Czy_mozna_ufac_ludziom_skala_do_10, COUNT(Czy_mozna_ufac_ludziom_skala_do_10) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Czy_mozna_ufac_ludziom_skala_do_10
ORDER BY Czy_mozna_ufac_ludziom_skala_do_10 ASC;

-- myśli samobójcze
SELECT Ostatni_rok_mysli_samobojcze, 
COUNT(Ostatni_rok_mysli_samobojcze) AS Ilość,
CASE Ostatni_rok_mysli_samobojcze
	WHEN 'Nigdy' THEN 'Nie'
	ELSE 'Tak'
END AS Mysli_samobojcze_ost_rok
FROM samotni_czasami_czesto
GROUP BY Ostatni_rok_mysli_samobojcze
ORDER BY Ilość DESC;

SELECT Ostatni_rok_mysli_samobojcze, COUNT(Ostatni_rok_mysli_samobojcze)
FROM samotnoscdane
GROUP BY Ostatni_rok_mysli_samobojcze

-- dzieci
SELECT Mam_dzieci, COUNT(Mam_dzieci) AS Ilość
FROM samotni_czasami_czesto
GROUP BY Mam_dzieci
ORDER BY Ilość DESC;
