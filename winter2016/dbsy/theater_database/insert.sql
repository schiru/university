BEGIN;

DELETE FROM Ticket;
DELETE FROM Platz;
DELETE FROM Saal;
DELETE FROM Haus;
DELETE FROM spielt;
DELETE FROM Auffuehrung;
DELETE FROM Rolle;
DELETE FROM zugeordnet;
DELETE FROM Werk;
DELETE FROM Kategorie;
DELETE FROM Kuenstler;
DELETE FROM Kunde;
DELETE FROM Mitarbeiter;
DELETE FROM Person;

ALTER SEQUENCE seq_person RESTART;
ALTER SEQUENCE seq_kunde RESTART;
ALTER SEQUENCE seq_kategorie RESTART;
ALTER SEQUENCE seq_werk RESTART;
ALTER SEQUENCE seq_auffuehrung RESTART;
ALTER SEQUENCE seq_ticket RESTART;
ALTER SEQUENCE seq_haus RESTART;
ALTER SEQUENCE seq_platz RESTART;

COMMIT;

INSERT INTO Person VALUES
	(1, 'Max', 'Mustermann', '2013-01-15', '1030 Wien'),
	(2, 'Anna', 'Mustermann', '2013-01-15', '1030 Wien'),
	(3, 'Jane', 'Doe', '2013-01-15', '1030 Wien'),
	(4, 'Emanuel', 'Schikaneder', '2013-01-15', '1040 Wien'),
	(5, 'Eleonore', 'Schickaneder', '2013-01-15', '1040 Wien');

INSERT INTO Kunde (knr, pid) VALUES
	(1500, 1),
	(1501, 2),
	(1502, 4);

BEGIN;

INSERT INTO Haus VALUES
	(1, 'Theater in der Wieden', '1040 Wien', 4);

INSERT INTO Mitarbeiter VALUES
	(4, 1000, 1),
	(5, 1000, 1);

COMMIT;

INSERT INTO Kuenstler (pid, instagram) VALUES
 	(3, 'janedoe'),
	(4, 'emanuel'),
	(5, 'eleonore');

INSERT INTO Saal (hid, sid, sname) VALUES
	(1, 1, 'Großer Saal'),
	(1, 2, 'Kabinett');

INSERT INTO Kategorie (kid, kname, superkat) VALUES
	(1, 'Drama', NULL),
	(2, 'Musical', NULL),
	(3, 'Oper', NULL),
	(4, 'Wiener Oper', 3),
	(5, 'Internationale Oper', 3),
	(6, 'Hollywood Musical', 2);

INSERT INTO Werk (wid, wname) VALUES
	(1, 'Evita'),
	(2, 'Der König der Löwen'),
	(3, 'Schickaneder'),
	(4, 'Mary Poppins'),
	(5, 'Die Zauberflöte');

INSERT INTO zugeordnet (wid, kid) VALUES
	(1, 2),
	(2, 6),
	(3, 1),
	(4, 6),
	(5, 4);

BEGIN;

INSERT INTO Rolle (wid, rid, rname) VALUES
	(3, 1, 'Schauspieler'),
	(3, 2, 'Reserve'),
	(2, 1, 'Schauspieler'),
	(2, 2, 'Dompteur');

INSERT INTO Auffuehrung (aid, datum, hid, sid) VALUES
	(1, '2016-10-31', 1, 1),
	(2, '2016-10-30', 1, 2),
	(3, '2016-01-01', 1, 2);

INSERT INTO spielt (aid, wid, rid, pid, gage) VALUES
	(1, 3, 1, 5, 100),
	(2, 3, 1, 3, 75),
	(1, 3, 2, 4, 25),
	(2, 3, 2, 4, 25),
	(2, 3, 2, 5, 25),
	(3, 2, 1, 3, 100);

COMMIT;
