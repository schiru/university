-- Die Tabelle kuenstler ändern
ALTER TABLE kuenstler
  ADD COLUMN abgbis DATE DEFAULT NULL,
  ADD COLUMN betrag NUMERIC(8,2) NOT NULL DEFAULT 0,
  ADD CONSTRAINT betragUnsigned CHECK (betrag >= 0);

-- Die Function Abrechnen erstellen
CREATE OR REPLACE FUNCTION Abrechnen(abpid INTEGER, abdatum DATE) RETURNS NUMERIC(8,2) AS $$
DECLARE
  currAbgDatum DATE;
  currBetrag NUMERIC(8,2);
  deltaSalaryChange NUMERIC(8,2);
BEGIN
  SELECT betrag INTO currBetrag FROM kuenstler WHERE pid = abpid;
  SELECT abgbis INTO currAbgDatum FROM kuenstler WHERE pid = abpid;

  IF abDatum <= currAbgDatum THEN
    RAISE EXCEPTION 'New abgbis must be after current abgbis';
  END IF;

  SELECT SUM(gage) INTO deltaSalaryChange FROM auffuehrung JOIN spielt ON auffuehrung.aid = spielt.aid
  where pid = abpid AND datum <= abdatum AND (currAbgDatum IS NULL OR datum > currAbgDatum);

  IF deltaSalaryChange IS NULL THEN
    deltaSalaryChange := 0;
  END IF;

  UPDATE kuenstler SET betrag = currBetrag + deltaSalaryChange, abgbis = abdatum WHERE pid = abpid;

  RETURN currBetrag + deltaSalaryChange;
END;
$$ LANGUAGE plpgsql;
