--- Procedure 1 --- Anlegen von Saalplaetzen
CREATE OR REPLACE FUNCTION CreatePlatz(hid INTEGER, sid INTEGER, anzReihen INTEGER, anzSitze INTEGER) RETURNS void AS $$
DECLARE
    reihe INTEGER;
    sitz INTEGER;
    plid INTEGER;
BEGIN
    SELECT COUNT(*) INTO plid FROM Platz p WHERE p.hid = $1 AND p.sid = $2;
    IF plid > 0 THEN
       RAISE EXCEPTION 'Plaetze bereits erstellt!';
    END IF;

    plid := 1;
    reihe := 1;
    <<reiheLoop>>
    LOOP
       sitz := 1;
       <<sitzeLoop>>
       LOOP
          INSERT INTO platz VALUES (hid, sid, plid, reihe, sitz);
          plid := plid + 1;
          sitz := sitz + 1;
          EXIT sitzeLoop WHEN sitz > anzSitze;
       END LOOP;
       reihe := reihe + 1;
       EXIT reiheLoop WHEN reihe > anzReihen;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--- Trigger 1 --- Anlegen Auffuehrungen
CREATE OR REPLACE FUNCTION trAuffuehrungInsert() RETURNS TRIGGER AS $$
BEGIN
   IF NEW.verkauf = true THEN
       RAISE EXCEPTION 'Noch keine Rollen besetzt!';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trAuffuehrungInsert BEFORE INSERT
   ON Auffuehrung FOR EACH ROW EXECUTE PROCEDURE trAuffuehrungInsert();

--- Trigger 2 --- Auffuehrung ankuendigen/abbrechen
CREATE OR REPLACE FUNCTION trAuffuehrungUpdate() RETURNS TRIGGER AS $$
DECLARE
   cPlaetze CURSOR FOR SELECT * FROM platz p WHERE p.sid = NEW.sid;
   rPlatz Platz%ROWTYPE;
   cntPlaetze INTEGER;
   gage NUMERIC(7,2);
   preis NUMERIC(7,2);
BEGIN
   --- Wenn der Verkauf startet
   IF OLD.verkauf = FALSE AND NEW.verkauf = true THEN
      --- Check if Auffuehrung is complete
      IF EXISTS (SELECT * FROM spielt s WHERE s.aid = NEW.aid) THEN
         IF EXISTS (SELECT count(*) AS cnt
                    FROM spielt s
                    WHERE s.aid = NEW.aid
                    GROUP BY s.wid
                    HAVING count(*) = (SELECT COUNT(*) FROM rolle r WHERE r.wid = s.wid)) THEN
            --- Berechne Ticketpreis  = (Summe der gagen + 50%) / anzahl der Tickets
            SELECT COUNT(*) INTO cntPlaetze FROM platz p WHERE p.sid = NEW.sid;
            SELECT SUM(s.gage) INTO gage FROM spielt s WHERE s.aid = NEW.aid;
            preis = gage * 1.5 / cntPlaetze;

            --- Lege fuer jeden Platz ein Ticket an
            OPEN cPlaetze;
            FETCH cPlaetze INTO rPlatz;
            WHILE FOUND LOOP
               INSERT INTO Ticket(preis,auffuehrung,kunde,hid,sid,plid) VALUES (preis,NEW.aid, NULL, rPlatz.hid, rPlatz.sid, rPlatz.plid);
               FETCH cPlaetze INTO rPlatz;
            END LOOP;

         ELSE
            RAISE EXCEPTION 'Rollen noch nicht vollstaendig besetzt!';
         END IF;
      ELSE
         RAISE EXCEPTION 'Noch keine Rollen besetzt!';
      END IF;
   END IF;
   --- Verkauf kann nicht beendet werden wenn Tickets verkauft wurden
   IF OLD.verkauf = TRUE AND NEW.verkauf = FALSE THEN
      IF EXISTS (SELECT * FROM Ticket t WHERE t.auffuehrung = NEW.aid AND kunde IS NOT NULL) THEN
         RAISE EXCEPTION 'Verkauf kann nicht mehr beendet werden! Tickets bereits verkauft!';
      END IF;
      DELETE FROM Ticket WHERE auffuehrung = NEW.aid;
   END IF;

   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trAuffuehrungUpdate BEFORE UPDATE
   ON Auffuehrung FOR EACH ROW EXECUTE PROCEDURE trAuffuehrungUpdate();

--- Trigger 3 --- Pro Auffuehrung nur 1 Werk
CREATE OR REPLACE FUNCTION trSpielt() RETURNS TRIGGER AS $$
BEGIN
   IF EXISTS (SELECT * FROM spielt s WHERE s.aid = NEW.aid AND s.wid <> NEW.wid) THEN
      RAISE EXCEPTION 'Nur ein Werk pro Auffuehrung!';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trSpielt BEFORE INSERT OR UPDATE
   ON spielt FOR EACH ROW EXECUTE PROCEDURE trSpielt();
