-- Trigger 1
-- Beim Anlegen einer Aufführung darf der Verkauf noch nicht starten, da noch keine Rollen besetzt wurden.
CREATE OR REPLACE FUNCTION check_auffuehrung () RETURNS TRIGGER AS $$
BEGIN
	IF NEW.verkauf = TRUE THEN
		RAISE EXCEPTION '(verkauf=true) Verkauf darf zu Beginn noch nicht gestartet sein, da keine Rollen besetzt wurden';
		RETURN NULL;
	END IF;

	RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_before_insert_auffuehrung ON Auffuehrung;
CREATE TRIGGER t_before_insert_auffuehrung
	BEFORE INSERT ON Auffuehrung
	FOR EACH ROW EXECUTE PROCEDURE check_auffuehrung();

-- Trigger 2
-- Pro Aufführung wird nur ein Werk gespielt.
-- Verhindert, dass zu einer Aufführung mehr als ein Werk zugeordnet sein kann.
CREATE OR REPLACE FUNCTION check_spielt() RETURNS TRIGGER AS $$
DECLARE
	existing_wid INTEGER;
BEGIN
	IF EXISTS
		(SELECT s.wid FROM spielt s
			WHERE s.aid = NEW.aid)
	THEN
		SELECT s.wid INTO existing_wid
		FROM spielt s
		WHERE s.aid = NEW.aid
		LIMIT 1;

		IF new.wid != existing_wid
		THEN
			RAISE EXCEPTION 'Dieser Aufführung ist bereits ein anderes Werk zugewiesen.';
			RETURN NULL;
		END IF;
	END IF;

	RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_before_insert_spielt ON spielt;
CREATE TRIGGER t_before_insert_spielt
	BEFORE INSERT ON spielt
	FOR EACH ROW EXECUTE PROCEDURE check_spielt();

-- Trigger 3
-- Wenn der Verkauf einer Aufführung startet (Beim Update von Aufführung ändert sich verkauf von false auf true), und:
--     es wird bereits ein Werk gespielt,
--     bei dem alle Rollen besetzt sind, dann
-- werden für diese Aufführung alle Tickets angelegt, sonst wird eine Fehlermeldung ausgegeben. Zum Anlegen der Tickets folgendes beachten:
--     Der Ticketpreis wird festgelegt als (Summe der Gagen + 50%) / Anzahl der Plätze des Saales in dem die Aufführung stattfindet.
--     Für jeden Platz wird ein Ticket angelegt, welches noch nicht verkauft ist (Kunde bleibt null). Verwenden Sie dazu einen Cursor der alle Plätze im Saal, in dem die Aufführung stattfindet, durchläuft.
CREATE OR REPLACE FUNCTION open_sale() RETURNS TRIGGER AS $$
DECLARE
	fplatzcur refcursor;
	fplatz Platz%ROWTYPE;
	existing_wid INTEGER;
	ticketprice NUMERIC(7,2);
	numseats INTEGER;
BEGIN
	SELECT s.wid INTO existing_wid
	FROM spielt s
	WHERE s.aid = NEW.aid
	LIMIT 1;

	IF OLD.verkauf = FALSE AND NEW.verkauf = TRUE
	THEN
		IF existing_wid IS NOT NULL
		THEN
			IF EXISTS
				(SELECT * FROM Rolle r
					LEFT JOIN spielt s
						ON r.wid = s.wid AND r.rid = s.rid
					WHERE r.wid = existing_wid AND s.pid IS NULL)
			THEN
				RAISE EXCEPTION 'Noch nicht alle Rollen wurden besetzt';
				RETURN NULL;
			ELSE
				SELECT COUNT(plid) INTO numseats FROM platz p WHERE p.sid = NEW.sid AND p.hid = NEW.hid;
				SELECT ROUND((SUM(gage)*1.5)/numseats, 2) INTO ticketprice FROM spielt s WHERE s.wid = existing_wid AND s.aid = NEW.aid;

				OPEN fplatzcur FOR SELECT * FROM Platz p WHERE p.sid = NEW.sid AND p.hid = NEW.hid;
				FETCH fplatzcur INTO fplatz;
				WHILE FOUND LOOP
					INSERT INTO Ticket (knr, aid, plid, sid, hid, preis) VALUES
					(NULL, NEW.aid, fplatz.plid, NEW.sid, NEW.hid, ticketprice);
					FETCH fplatzcur INTO fplatz;
				END LOOP;
				CLOSE fplatzcur;
			END IF;
		ELSE
			RAISE EXCEPTION 'Es wurde noch kein Werk zu dieser Aufführung zugewiesen';
		END IF;
	END IF;

	RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_open_sale ON Auffuehrung;
CREATE TRIGGER t_open_sale
	BEFORE UPDATE ON Auffuehrung
	FOR EACH ROW EXECUTE PROCEDURE open_sale();

-- Trigger 4
-- Wenn der Verkauf einer Aufführung beendet wird (Beim Update von Aufführung ändert sich verkauf von true auf false) und noch keine Tickets verkauft wurden (Es gibt kein Ticket bei dem der Kunde nicht null ist), dann werden auch alle Tickets dieser Aufführung gelöscht. Sonst wird dass Update verweigert und eine Fehlermeldung ausgegeben.
CREATE OR REPLACE FUNCTION close_sale() RETURNS TRIGGER AS $$
DECLARE
	fplatzcur refcursor;
	fplatz Platz%ROWTYPE;
	existing_wid INTEGER;
	ticketprice NUMERIC(7,2);
	numseats INTEGER;
BEGIN
	SELECT s.wid INTO existing_wid
	FROM spielt s
	WHERE s.aid = NEW.aid
	LIMIT 1;

	IF OLD.verkauf = TRUE AND NEW.verkauf = FALSE
	THEN
		IF EXISTS
			(SELECT * FROM Ticket t
			WHERE t.aid = NEW.aid AND knr IS NOT NULL)
		THEN
			RAISE EXCEPTION 'Verkauf kann nicht beendet bzw. Tickets können nicht gelöscht werden werden, da es bereits Kunden gibt.';
			RETURN NULL;
		ELSE
			DELETE FROM Ticket t WHERE t.aid = NEW.aid;
		END IF;
	END IF;

	RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_close_sale ON Auffuehrung;
CREATE TRIGGER t_close_sale
	BEFORE UPDATE ON Auffuehrung
	FOR EACH ROW EXECUTE PROCEDURE close_sale();

-- Funktion 1
-- Schreiben Sie eine Funktion CreatePlatz, welche als Parameter die Hausnummer, die Saalnummer, eine Anzahl von Reihen und eine Anzahl von Sitzen pro Reihe erhält.
-- Die Funktion CreatePlatz soll für den übergebenen Saal, falls noch keine Plätze in diesem Saal vorhanden sind, mit Hilfe von Schleifen für die übergebene Anzahl der Reihen, pro Reihe die übergebene Anzahl von Sitzen in der Tabelle Platz anlegen.
CREATE OR REPLACE FUNCTION CreatePlatz (fhid INTEGER, fsid INTEGER, reihen INTEGER, sitze INTEGER) RETURNS INTEGER AS $$
DECLARE
BEGIN
	IF reihen < 0 OR sitze < 0 THEN
		RAISE EXCEPTION 'Ungültiger Aufruf von CreatePlatz';
	END IF;

	IF EXISTS
		(SELECT * FROM Saal WHERE hid = fhid AND sid = fsid)
	THEN
		IF NOT EXISTS
			(SELECT * FROM Platz WHERE hid = fhid AND sid = fsid)
		THEN
			FOR i IN 1 .. reihen LOOP
				FOR j IN 1 .. sitze  LOOP
					INSERT INTO Platz (sid, hid, reihe, sitz) VALUES
						(fsid, fhid, i, j);
				END LOOP;
			END LOOP;
		ELSE
			RAISE EXCEPTION 'Plätze in Saal bereits angelegt';
		END IF;
	ELSE
		RAISE EXCEPTION 'Saal oder/und Haus nicht vorhanden';
	END IF;

	RETURN reihen*sitze;
END;
$$ LANGUAGE plpgsql;
