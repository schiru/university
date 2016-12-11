UPDATE Auffuehrung SET verkauf = true WHERE aid = 2;
UPDATE Auffuehrung SET verkauf = true WHERE aid = 3;

SELECT count(*) FROM Ticket;
UPDATE Auffuehrung SET verkauf = false WHERE aid = 1;
SELECT count(*) FROM Ticket;
UPDATE Auffuehrung SET verkauf = true WHERE aid = 1;
SELECT count(*) FROM Ticket;

INSERT INTO spielt VALUES (2, 1, 8, 2, 1500.0)

INSERT INTO Kunde VALUES (1, 1001);

UPDATE Ticket SET kunde = 1;
UPDATE Ticket SET kunde = 5;

UPDATE Auffuehrung SET verkauf = false WHERE aid = 1;
