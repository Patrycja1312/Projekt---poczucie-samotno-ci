-- ** -- ** -- ** -- DO STRONY 1 -- ** -- ** -- ** --
-- zmiany w nazwach wartoœci dla lepszej wizualizacji --
UPDATE samotnoscdane
SET Stan_cywilny = 'W zwi¹zku nieformalnym'
WHERE Stan_cywilny LIKE 'Jestem w%';

UPDATE samotnoscdane
SET Miejscowosc = 'Wielkie miasto'
WHERE Miejscowosc LIKE '%Wielkie miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Du¿e miasto'
WHERE Miejscowosc LIKE '%Du¿e miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Œrednie miasto'
WHERE Miejscowosc LIKE '%Œrednie miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Ma³e miasto'
WHERE Miejscowosc LIKE '%Ma³e miasto%';

UPDATE samotnoscdane
SET Miejscowosc = 'Wieœ'
WHERE Miejscowosc LIKE '%wieœ%';

UPDATE samotnoscdane
SET Czy_mozna_ufac_ludziom_skala_do_10 = '10'
WHERE Czy_mozna_ufac_ludziom_skala_do_10 LIKE '10%';

UPDATE samotnoscdane
SET Czy_mozna_ufac_ludziom_skala_do_10 = '0'
WHERE Czy_mozna_ufac_ludziom_skala_do_10 LIKE '0%';


-- ** -- ** -- ** -- DO STRONY 2 -- ** -- ** -- ** --
-- Sprawdzenie jakie opcje by³y do wyboru jako odpowiedŸ na pytanie "Jak czêsto w ostatnim roku czu³eœ siê samotny?"
SELECT DISTINCT Ostatni_rok_poczucie_samotnosci
FROM samotnoscdane;
-- Odpowiedzi: Nigdy, Rzadko, Czasami, Czêsto

-- Ile osób da³o poszczególne odpowiedzi
SELECT Ostatni_rok_poczucie_samotnosci, COUNT(Ostatni_rok_poczucie_samotnosci) AS Iloœæ
FROM samotnoscdane
GROUP BY Ostatni_rok_poczucie_samotnosci
ORDER BY Iloœæ DESC;
GO

-- ** -- WIDOK - czy osoba ankietowana doœwiadczy³a poczucia samotnoœci w ostatnim roku -- ** -- 
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

-- ** -- WIDOK - osoby, które czasami lub czêsto w ostatnim roku doœwiadczy³y poczucia samotnoœci -- ** -- 
CREATE OR ALTER VIEW czy_doswiadczyl_czasami_lub_czesto_poczucia_samotnosci_w_ostatnim_roku AS
SELECT Nr_ankiety,
CASE
	WHEN Ostatni_rok_poczucie_samotnosci LIKE 'Czêsto' OR Ostatni_rok_poczucie_samotnosci LIKE 'Czasami' THEN 'Tak'
	ELSE 'Nie'
END AS Poczucie_samotnosci
FROM samotnoscdane;
GO

SELECT * FROM czy_doswiadczyl_czasami_lub_czesto_poczucia_samotnosci_w_ostatnim_roku;
GO

-- ** -- WIDOK - osoby, które kiedykolwiek w ostatnim roku doœwiadczy³y poczucia samotnoœci -- ** --
CREATE OR ALTER VIEW samotni AS
SELECT * 
FROM samotnoscdane
WHERE Ostatni_rok_poczucie_samotnosci NOT LIKE 'Nigdy'
GO

SELECT * FROM samotni

-- Procentowo z podzia³em na wiek i p³eæ - osoby, które kiedykolwiek w ostatnim roku doœwiadczy³y poczucia samotnoœci
SELECT sd.Wiek_przedzial, sd.P³eæ, 
COUNT(sd.Wiek_przedzial) AS ca³oœæ_wiek, 
COUNT(s.Wiek_przedzial) AS samotni_wiek, 
COUNT(s.Wiek_przedzial)/CAST(COUNT(sd.Wiek_przedzial) 
AS DECIMAL(7,2))*100 AS procent
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Wiek_przedzial, sd.P³eæ
ORDER BY Wiek_przedzial ASC, procent DESC
GO

-- ** -- WIDOK - osoby, które czasami lub czêsto w ostatnim roku doœwiadczy³y poczucia samotnoœci -- ** --
CREATE OR ALTER VIEW samotni_czasami_czesto AS
SELECT * 
FROM samotnoscdane
WHERE Ostatni_rok_poczucie_samotnosci LIKE 'Czêsto' OR Ostatni_rok_poczucie_samotnosci LIKE 'Czasami'
GO

SELECT * FROM samotni_czasami_czesto

--- Procentowo z podzia³em na wiek i p³eæ - osoby, które czasami lub czêsto w ostatnim roku doœwiadczy³y poczucia samotnoœci
SELECT sd.Wiek_przedzial, sd.P³eæ, COUNT(sd.Wiek_przedzial) AS ca³oœæ_wiek, COUNT(scc.Wiek_przedzial) AS samotni_czasami_czesto_wiek, COUNT(scc.Wiek_przedzial)/CAST(COUNT(sd.Wiek_przedzial) AS DECIMAL(7,2))*100 AS procent
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Wiek_przedzial, sd.P³eæ
ORDER BY Wiek_przedzial ASC, procent DESC

-- ** DZIA£ANIA NA WIDOKU samotni_czasami_czesto ** --
-- wykszta³cenie
SELECT sd.Wyksztalcenie, COUNT(sd.Wyksztalcenie) AS ca³oœæ_wykszta³cenie, COUNT(scc.Wyksztalcenie) AS samotni_czas_czes_wyksztalcenie, 
ROUND(COUNT(scc.Wyksztalcenie)/CAST(COUNT(sd.Wyksztalcenie) AS DECIMAL(7,2))*100,2) AS procent_wykszta³cenie
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Wyksztalcenie
ORDER BY procent_wykszta³cenie DESC

-- dzieci
SELECT sd.Mam_dzieci, COUNT(sd.Mam_dzieci) AS ca³oœæ_dzieci, COUNT(scc.Mam_dzieci) AS samotni_czas_czes_dzieci, (COUNT(sd.Mam_dzieci) - COUNT(scc.Mam_dzieci)) AS roznica_dzieci,
ROUND(COUNT(scc.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_dzieci,
100 - ROUND(COUNT(scc.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_roznica_dzieci
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Mam_dzieci
ORDER BY procent_dzieci DESC

-- stan_cywilny
SELECT sd.Stan_cywilny, COUNT(sd.Stan_cywilny) AS ca³oœæ_stan_cywilny, COUNT(scc.Stan_cywilny) AS samotni_czas_czes_stan_cywilny, 
ROUND(COUNT(scc.Stan_cywilny)/CAST(COUNT(sd.Stan_cywilny) AS DECIMAL(7,2))*100,2) AS procent_stan_cywilny
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Stan_cywilny
ORDER BY procent_stan_cywilny DESC

-- miejscowoœæ
SELECT sd.Miejscowosc, COUNT(sd.Miejscowosc) AS ca³oœæ_miejscowosc, COUNT(scc.Miejscowosc) AS samotni_czas_czes_miejscowosc, 
ROUND(COUNT(scc.Miejscowosc)/CAST(COUNT(sd.Miejscowosc) AS DECIMAL(7,2))*100,2) AS procent_miejscowosc
FROM samotnoscdane sd
LEFT JOIN samotni_czasami_czesto scc ON sd.Nr_ankiety = scc.Nr_ankiety
GROUP BY sd.Miejscowosc
ORDER BY procent_miejscowosc DESC

-- ** DZIA£ANIA NA WIDOKU samotni ** --
-- wykszta³cenie
SELECT sd.Wyksztalcenie, COUNT(sd.Wyksztalcenie) AS ca³oœæ_wykszta³cenie, COUNT(s.Wyksztalcenie) AS samotni_wyksztalcenie, 
ROUND(COUNT(s.Wyksztalcenie)/CAST(COUNT(sd.Wyksztalcenie) AS DECIMAL(7,2))*100,2) AS procent_wykszta³cenie
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Wyksztalcenie
ORDER BY procent_wykszta³cenie DESC

-- dzieci
SELECT sd.Mam_dzieci, COUNT(sd.Mam_dzieci) AS ca³oœæ_dzieci, COUNT(s.Mam_dzieci) AS samotni_dzieci, 
ROUND(COUNT(s.Mam_dzieci)/CAST(COUNT(sd.Mam_dzieci) AS DECIMAL(7,2))*100,2) AS procent_dzieci
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Mam_dzieci
ORDER BY procent_dzieci DESC

-- stan_cywilny
SELECT sd.Stan_cywilny, COUNT(sd.Stan_cywilny) AS ca³oœæ_stan_cywilny, COUNT(s.Stan_cywilny) AS samotni_stan_cywilny, 
ROUND(COUNT(s.Stan_cywilny)/CAST(COUNT(sd.Stan_cywilny) AS DECIMAL(7,2))*100,2) AS procent_stan_cywilny
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Stan_cywilny
ORDER BY procent_stan_cywilny DESC

-- miejscowoœæ
SELECT sd.Miejscowosc, COUNT(sd.Miejscowosc) AS ca³oœæ_miejscowosc, COUNT(s.Miejscowosc) AS samotni_miejscowosc, 
ROUND(COUNT(s.Miejscowosc)/CAST(COUNT(sd.Miejscowosc) AS DECIMAL(7,2))*100,2) AS procent_miejscowosc
FROM samotnoscdane sd
LEFT JOIN samotni s ON sd.Nr_ankiety = s.Nr_ankiety
GROUP BY sd.Miejscowosc
ORDER BY procent_miejscowosc DESC


-- ** -- ** -- ** -- DO STRONY 3 -- ** -- ** -- ** -
-- poczucie atrakcyjnoœci
SELECT Czy_jestem_atrakcyjny_skala_do_5, COUNT(Czy_jestem_atrakcyjny_skala_do_5) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Czy_jestem_atrakcyjny_skala_do_5
ORDER BY Iloœæ DESC;

-- poczucie szczêœcia
SELECT Jak_bardzo_jestem_szczesliwy_skala_do_5, COUNT(Jak_bardzo_jestem_szczesliwy_skala_do_5) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Jak_bardzo_jestem_szczesliwy_skala_do_5
ORDER BY Iloœæ DESC;

-- aktywnoœæ 7 dni
SELECT Ostatnie_7_dni_aktywnosc_powyzej_30min, COUNT(Ostatnie_7_dni_aktywnosc_powyzej_30min) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Ostatnie_7_dni_aktywnosc_powyzej_30min
ORDER BY Iloœæ DESC;

-- poczucie opuszczenia
SELECT Czujê_siê_opuszczony, COUNT(Czujê_siê_opuszczony) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Czujê_siê_opuszczony
ORDER BY Iloœæ DESC;

-- jestem zupe³nie do niczego
SELECT Czasami_myœlê_¿e_jestem_zupe³nie_do_niczego, COUNT(Czasami_myœlê_¿e_jestem_zupe³nie_do_niczego) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Czasami_myœlê_¿e_jestem_zupe³nie_do_niczego
ORDER BY Iloœæ DESC;

-- zdrowie psychiczne
SELECT COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi') AS Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, COUNT(COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi')) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY COALESCE(Czasami_niepokoje_sie_o_moje_zdrowie_psychiczne, 'Brak odpowiedzi')
ORDER BY Iloœæ DESC;

-- ludzie postepuja uczciwie
SELECT Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10, 
COUNT(Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10) AS Iloœæ,
CASE 
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('10%','9','8') THEN '8-10'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('0%','1','2') THEN '0-2'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 IN ('3','4') THEN '3-4'
	WHEN Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10 LIKE '5' THEN '5'
	ELSE '6-7'
END AS uczciwosc
FROM samotni_czasami_czesto
GROUP BY Czy_wiekszosc_ludzi_postepuje_uczciwie_skala_do_10
ORDER BY Iloœæ DESC;

-- mozna ufaæ ludziom
SELECT CAST(Czy_mozna_ufac_ludziom_skala_do_10 AS Int) AS Czy_mozna_ufac_ludziom_skala_do_10, COUNT(Czy_mozna_ufac_ludziom_skala_do_10) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Czy_mozna_ufac_ludziom_skala_do_10
ORDER BY Czy_mozna_ufac_ludziom_skala_do_10 ASC;

-- myœli samobójcze
SELECT Ostatni_rok_mysli_samobojcze, 
COUNT(Ostatni_rok_mysli_samobojcze) AS Iloœæ,
CASE Ostatni_rok_mysli_samobojcze
	WHEN 'Nigdy' THEN 'Nie'
	ELSE 'Tak'
END AS Mysli_samobojcze_ost_rok
FROM samotni_czasami_czesto
GROUP BY Ostatni_rok_mysli_samobojcze
ORDER BY Iloœæ DESC;

SELECT Ostatni_rok_mysli_samobojcze, COUNT(Ostatni_rok_mysli_samobojcze)
FROM samotnoscdane
GROUP BY Ostatni_rok_mysli_samobojcze

SELECT Mam_dzieci, COUNT(Mam_dzieci) AS Iloœæ
FROM samotni_czasami_czesto
GROUP BY Mam_dzieci
ORDER BY Iloœæ DESC;