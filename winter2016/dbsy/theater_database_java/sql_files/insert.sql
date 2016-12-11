BEGIN;

DELETE FROM spielt;
DELETE FROM Rolle;
DELETE FROM zugeordnet;
DELETE FROM Werk;
DELETE FROM Kategorie;
DELETE FROM Ticket;
DELETE FROM Auffuehrung;
DELETE FROM Platz;
DELETE FROM Saal;
DELETE FROM Haus;
DELETE FROM Kuenstler;
DELETE FROM Mitarbeiter;
DELETE FROM Kunde;
DELETE FROM Person;
SELECT setval('seq_person',1,false);
SELECT setval('seq_kunde',1000,false);

COMMIT;

INSERT INTO Person(vname,nname,gebdatum,adresse) VALUES
	('Max', 'Mustermann', '1976-10-12', 'Kantorweg 67' ),
	('Werner', 'Gruber', '1965-09-20', 'Weinweg 3/a'),
	('Ines', 'Bach', '1973-10-07', 'Linke Wulkazeile 5'),
	('Martin', 'Huber', '1982-11-12', 'Markusgasse 77'),
	('Petra', 'Grasich', '1943-12-03', 'Axerweg 56'),
	('Verena', 'Schubasich', '1979-12-30', 'Patentstraße 56'),
	('Hubert', 'Mueller', '1980-03-14', 'Am Entenweg 4'),
	('Erika', 'Gustaffson', '1967-02-28', 'Axerweg 56');

SELECT * FROM Person;

INSERT INTO Kuenstler VALUES (4,'hubma');
INSERT INTO Kuenstler VALUES (7,'muehub');
INSERT INTO Kuenstler VALUES (8,'gustafferi');

INSERT INTO Kunde (pid) VALUES (5),(6);

BEGIN;

INSERT INTO Mitarbeiter VALUES (1,2500,1), (2,800,1), (3,3000,2), (4,1500,2);

INSERT INTO Haus VALUES (1,'Theater an der Wien', 'Linke Wienzeile 6', 1),
                        (2,'Musikverein', 'Musikvereinspl. 1', 3);

COMMIT;

INSERT INTO Saal VALUES (1,1,'Zuschauerraum'),
                        (2,1,'Groser Saal'),
                        (2,2,'Brahms Saal'),
                        (2,3,'Gläsener Saal');

SELECT CreatePlatz(1,1,10,20);
SELECT CreatePlatz(2,1,60,30);
SELECT CreatePlatz(2,2,10,15);
SELECT CreatePlatz(2,3,10,25);


INSERT INTO Kategorie VALUES (1, 'Bühnenwerk', NULL),
                             (2, 'Schauspiel', 1),
                             (3, 'Tragödie', 2),
                             (4, 'Komödie', 2),
                             (5, 'Musiktheater', 1),
                             (6, 'Oper', 5),
                             (7, 'Musical', 5),
                             (8, 'Ballett', 1),
                             (9, 'Instrumentalwerk', NULL),
                             (10, 'Sinfonie', 9);

INSERT INTO Werk VALUES (1, 'König Ödipus'),
                        (2, 'Die Zauberflöte'),
                        (3, '5. Sinfonie');

INSERT INTO zugeordnet VALUES (1, 3), (1,2), (2,6), (3,10);

INSERT INTO Rolle VALUES (1, 1, 'Ödipus'),
                         (1, 2, 'Iokaste'),
                         (1, 3, 'Laios'),
                         (2, 1, 'Sarastro'),
                         (2, 2, 'Tamino'),
                         (2, 3, 'Königin der Nacht'),
                         (3, 1, '1. Violine'),
                         (3, 2, '2. Violine'),
                         (3, 3, 'Violoncello'),
                         (3, 4, 'Kontrabass');

INSERT INTO Auffuehrung VALUES (1, '2016-10-23', false, 1, 1);

INSERT INTO spielt VALUES (1, 1, 4, 1, 10000);
INSERT INTO spielt VALUES (1, 2, 8, 1, 20000);
INSERT INTO spielt VALUES (1, 3, 7, 1, 15000);

UPDATE Auffuehrung SET verkauf = true WHERE aid = 1;

INSERT INTO Auffuehrung VALUES (2, '2016-10-24', false, 1, 1);
INSERT INTO Auffuehrung VALUES (3, '2016-10-25', false, 1, 1);

INSERT INTO spielt VALUES (1, 1, 7, 2, 10000);
INSERT INTO spielt VALUES (1, 2, 8, 2, 20000);
