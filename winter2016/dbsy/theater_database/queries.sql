-- Query 1 --
-- Erstellen Sie eine Query, die pro Haus den Namen und die Gesamtkapazität ausgibt (Summe der Plätze in jedem Saal). --
SELECT hname AS "Hausname", COUNT(plid) AS "Kapazitaet"
FROM Haus
LEFT JOIN Platz on Platz.hid = Haus.hid
GROUP BY hname;

-- Query 2
-- Erstellen Sie eine View WerkKat, die pro Werk (wid) alle zugeordneten Kategorien (kid) und deren übergeordneten Kategorien ausgibt. Hinweis: Die gesuchte Query verwendet WITH RECURSIVE.
CREATE OR REPLACE VIEW WerkKat AS
	WITH RECURSIVE kat_and_superkat (wid, kid) AS (
		SELECT w.wid, z.kid, z.superkat FROM Werk w
		NATURAL JOIN zugeordnet
		NATURAL JOIN kategorie z
		UNION ALL
		SELECT k.wid, s.kid, s.superkat FROM kat_and_superkat k
		JOIN Kategorie s ON s.kid = k.superkat
	)
	SELECT wid, kid FROM kat_and_superkat
	ORDER BY wid ASC, kid ASC;

SELECT * FROM WerkKat;
-- Alle Kategorien, denen das Werk mit der wid=x angehört:
-- SELECT wname, kname
-- FROM WerkKat
-- NATURAL JOIN Kategorie
-- NATURAL JOIN Werk  WHERE wid = 5;


-- Query 3
-- Erstellen Sie eine Query die Datum und Hausname von Aufführungen ausgibt, die ein Werk einer bestimmten Kategorie aufführen und nicht ausverkauft sind. Eine Aufführung ist nicht ausverkauft, falls Tickets vorhanden sind, die noch keinem Kunde gehören.
SELECT datum AS "Datum", hname AS "Haus"
FROM auffuehrung
NATURAL JOIN Haus
NATURAL JOIN spielt
NATURAL JOIN Werk
NATURAL JOIN zugeordnet
WHERE
	kid = 1
	AND
	aid IN (SELECT aid FROM Ticket WHERE knr IS NULL)
GROUP BY aid, datum, hname;

-- Query 4
-- Erstellen Sie eine Query, die den Schauspieler (Vor- und Nachname) ausgibt, der am meisten (öftersten) eine (die selbe) Rolle gespielt hat. Geben Sie auch den Rollennamen aus.
WITH rollenstatistik (pid, rid, wid, anzahl) AS (
	SELECT pid, rid, wid, COUNT(rid) AS anzahl
	FROM spielt
	GROUP BY rid, wid, pid
) SELECT vname AS "Vorname", nname AS "Nachname", rname AS "Rolle" , anzahl AS "Anzahl"
 	FROM rollenstatistik rs
	NATURAL JOIN Person
	JOIN Rolle ro ON rs.rid = ro.rid AND rs.wid = ro.wid
	WHERE anzahl = (SELECT MAX(anzahl) FROM rollenstatistik);
