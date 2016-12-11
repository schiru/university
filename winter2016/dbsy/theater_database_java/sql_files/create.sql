CREATE SEQUENCE seq_person;
CREATE SEQUENCE seq_kunde INCREMENT BY 1 MINVALUE 1000 NO CYCLE;
CREATE SEQUENCE seq_ticket;

CREATE TABLE Person (
    pid INTEGER PRIMARY KEY DEFAULT nextval('seq_person'),
	vname VARCHAR(40) NOT NULL,
	nname VARCHAR(40) NOT NULL,
	gebdatum DATE NOT NULL,
	adresse VARCHAR(200) NOT NULL
);

CREATE TABLE Kunde(
    pid INTEGER PRIMARY KEY REFERENCES Person(pid),
    knr INTEGER UNIQUE DEFAULT nextval('seq_kunde')
);

CREATE TABLE Mitarbeiter (
    pid INTEGER PRIMARY KEY REFERENCES Person(pid),
	lohn NUMERIC(7,2) NOT NULL CHECK (lohn > 0),
	arbeitet INTEGER NOT NULL
);

CREATE TABLE Kuenstler (
    pid INTEGER PRIMARY KEY REFERENCES Person(pid),
	instagram VARCHAR(20)
);

CREATE TABLE Haus (
    hid INTEGER PRIMARY KEY,
	hname VARCHAR(40) NOT NULL,
	adresse VARCHAR(200) NOT NULL,
	leitet INTEGER REFERENCES Mitarbeiter(pid)
);

ALTER TABLE Mitarbeiter ADD CONSTRAINT fk_arbeitet FOREIGN KEY (arbeitet) REFERENCES Haus(hid) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE Saal (
    hid INTEGER REFERENCES Haus(hid),
	sid INTEGER,
	sname VARCHAR(40) NOT NULL,
	PRIMARY KEY (hid, sid)
);

CREATE TABLE Platz (
	hid INTEGER,
	sid INTEGER,
	plid INTEGER,
	reihe INTEGER NOT NULL,
	sitz INTEGER NOT NULL,
	FOREIGN KEY (hid,sid) REFERENCES Saal(hid,sid),
	PRIMARY KEY (hid,sid,plid),
	UNIQUE (hid, sid, reihe, sitz)
);

CREATE TABLE Auffuehrung (
	aid INTEGER PRIMARY KEY,
	datum DATE NOT NULL,
	verkauf BOOLEAN NOT NULL DEFAULT false,
	hid INTEGER NOT NULL,
	sid INTEGER NOT NULL,
	FOREIGN KEY (hid, sid) REFERENCES Saal(hid,sid)
);

CREATE TABLE Ticket (
    tid INTEGER PRIMARY KEY DEFAULT nextval('seq_ticket'),
    preis NUMERIC(7,2) NOT NULL DEFAULT 0.0,
	auffuehrung INTEGER NOT NULL REFERENCES Auffuehrung(aid),
	kunde INTEGER REFERENCES Kunde(pid),
	hid INTEGER NOT NULL,
	sid INTEGER NOT NULL,
	plid INTEGER NOT NULL,
	FOREIGN KEY (hid,sid,plid) REFERENCES Platz(hid,sid,plid)
);

CREATE TABLE Kategorie (
   kid INTEGER PRIMARY KEY,
   kname VARCHAR(20) NOT NULL,
   superkat INTEGER REFERENCES Kategorie(kid)
);

CREATE TABLE Werk (
   wid INTEGER PRIMARY KEY,
   wname VARCHAR(20) NOT NULL
);

CREATE TABLE zugeordnet (
   wid INTEGER REFERENCES Werk(wid),
   kid INTEGER REFERENCES Kategorie(kid),
   PRIMARY KEY (wid,kid)
);

CREATE TABLE Rolle (
   wid INTEGER REFERENCES Werk(wid),
   rid INTEGER,
   rname VARCHAR(20) NOT NULL,
   PRIMARY KEY (wid,rid)
);

CREATE TABLE spielt (
   wid INTEGER,
   rid INTEGER,
   pid INTEGER NOT NULL REFERENCES Kuenstler(pid),
   aid INTEGER NOT NULL REFERENCES Auffuehrung(aid),
   gage NUMERIC(7,2) CHECK (gage > 0),
   FOREIGN KEY (wid,rid) REFERENCES Rolle(wid,rid),
   PRIMARY KEY (wid,rid,pid,aid)
);
