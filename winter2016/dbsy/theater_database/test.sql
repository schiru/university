-- Haus 1, kleiner Saal
SELECT CreatePlatz(1,1,2,4);
-- Haus 1, großer Saal
SELECT CreatePlatz(1,2,4, 8);

-- Negativ-Tests:
SELECT CreatePlatz(1,0,2,4);
SELECT CreatePlatz(1,1,10,10);
SELECT CreatePlatz(1,1,-1,2);

-- Trigger t_before_insert_auffuehrung
-- Eine neue Aufführung erstellen, bei der Verkauf bereits TRUE ist
INSERT INTO Auffuehrung VALUES
	(10, TRUE, '2015-10-10', 1,1);

-- Trigger t_before_insert_spielt
-- Eine weitere Zeite in spielt einfügen, die ein anderes Werk zusätzlich mit dieser Aufführung verknüpfen würde.
-- aid 1 bereits mit wid 3 verküpft
INSERT INTO spielt (pid, rid, wid, aid, gage)
	VALUES (3, 1, 2, 1, 100);

-- Trigger t_open_sale testen:
UPDATE Auffuehrung SET verkauf = TRUE WHERE aid = 1;
-- Verkauf oeffnen, obwohl noch nicht alle Rollen belegt sind
UPDATE Auffuehrung SET verkauf = TRUE WHERE aid = 3;

-- Trigger t_close_sale testen:
-- Verkauf schließen, obwohl schon Tickets verkauft wurden
UPDATE Ticket SET knr = 1500 WHERE aid = 1 AND plid = 1;
UPDATE Auffuehrung SET verkauf = FALSE WHERE aid = 1;

-- Ticket entfernen, schließen jetzt möglich
UPDATE Ticket SET knr = NULL WHERE aid = 1;
UPDATE Auffuehrung SET verkauf = FALSE WHERE aid = 1;

-- Vorbereitung für queries.sql
UPDATE Auffuehrung SET verkauf = TRUE WHERE aid = 1;
