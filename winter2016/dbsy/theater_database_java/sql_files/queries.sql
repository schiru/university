--- Query 1 ---
SELECT hname, COUNT(plid)
FROM platz p JOIN haus h ON p.hid = h.hid
GROUP BY hname;


--- Query 2 ---
CREATE OR REPLACE VIEW WerkKat AS
    WITH RECURSIVE temp(wid,kid) AS (
        SELECT w.wid, z.kid FROM werk w JOIN zugeordnet z ON w.wid = z.wid
      UNION ALL
        SELECT w.wid, u.superkat FROM temp w JOIN Kategorie u ON w.kid = u.kid
    ) SELECT * FROM temp WHERE kid IS NOT NULL ORDER BY wid, kid;

SELECT * FROM WerkKat;


--- Query 3 ---
SELECT DISTINCT a.datum, h.hname
FROM Auffuehrung a JOIN haus h ON a.hid = h.hid
                   JOIN spielt s ON a.aid = s.aid
	           JOIN zugeordnet wk ON s.wid = wk.wid
                   --JOIN WerkKat wk ON s.wid = wk.wid
                   JOIN Ticket t ON a.aid = t.auffuehrung
WHERE t.kunde IS NULL AND
      wk.kid = 1;

--- Query 4 ---
SELECT vname, nname, rname, cnt FROM (SELECT pid, wid, rid, count(*) AS cnt FROM spielt s GROUP BY s.pid, wid, rid
					     HAVING COUNT(*) = (SELECT MAX(cnt) FROM (SELECT pid, wid, rid, count(*) AS cnt FROM spielt GROUP BY pid, wid, rid) h)) s
                           JOIN person p ON s.pid = p.pid
                           JOIN rolle r ON s.wid = r.wid AND s.rid = r.rid;
