CREATE SEQUENCE seq_person;
CREATE SEQUENCE seq_kunde MINVALUE 1000 NO CYCLE;
CREATE SEQUENCE seq_kategorie;
CREATE SEQUENCE seq_werk;
CREATE SEQUENCE seq_auffuehrung;
CREATE SEQUENCE seq_ticket;
CREATE SEQUENCE seq_haus;
CREATE SEQUENCE seq_platz;

CREATE TABLE Person (
	pid INTEGER PRIMARY KEY DEFAULT nextval('seq_person'),
	vname VARCHAR(40) NOT NULL,
	nname VARCHAR(40) NOT NULL,
	gebdatum DATE,
	adresse VARCHAR(80)
);

CREATE TABLE Mitarbeiter (
	pid INTEGER PRIMARY KEY REFERENCES Person(pid),
	lohn NUMERIC(7,2) NOT NULL CHECK (lohn >= 1),
	arbeitsplatz INTEGER NOT NULL
);

CREATE TABLE Kunde (
	pid INTEGER PRIMARY KEY REFERENCES Person(pid),
	knr INTEGER UNIQUE DEFAULT nextval('seq_kunde')
);

CREATE TABLE Kuenstler (
	pid INTEGER PRIMARY KEY REFERENCES Person(pid),
	instagram VARCHAR(40)
);

CREATE TABLE Kategorie (
	kid INTEGER PRIMARY KEY DEFAULT nextval('seq_kategorie'),
	superkat INTEGER NULL REFERENCES Kategorie(kid),
	kname VARCHAR(40) NOT NULL
);

CREATE TABLE Werk (
	wid INTEGER PRIMARY KEY DEFAULT nextval('seq_werk'),
	wname VARCHAR(40) NOT NULL
);

CREATE TABLE zugeordnet (
	wid INTEGER REFERENCES Werk(wid),
	kid INTEGER REFERENCES Kategorie(kid),

	PRIMARY KEY (wid, kid)
);

CREATE TABLE Rolle (
	rid INTEGER NOT NULL,
	wid INTEGER NOT NULL REFERENCES Werk(wid),
	rname VARCHAR(40) NOT NULL,

	PRIMARY KEY (rid, wid)
);

CREATE TABLE Auffuehrung (
	aid INTEGER PRIMARY KEY DEFAULT nextval('seq_auffuehrung'),
	verkauf BOOLEAN NOT NULL DEFAULT FALSE,
	datum DATE,
	sid INTEGER NOT NULL,
	hid INTEGER NOT NULL
);

CREATE TABLE spielt (
	pid INTEGER REFERENCES Kuenstler(pid),
	rid INTEGER,
	wid INTEGER,
	aid INTEGER REFERENCES Auffuehrung(aid),
	gage NUMERIC(7,2) NOT NULL CHECK(gage >= 1),

	FOREIGN KEY (rid, wid) REFERENCES Rolle (rid, wid),
	PRIMARY KEY (pid, rid, wid, aid, gage)
);

CREATE TABLE Haus (
	hid INTEGER PRIMARY KEY DEFAULT nextval('seq_haus'),
	hname VARCHAR(40) NOT NULL,
	adresse VARCHAR(80) NOT NULL,
	leiter INTEGER UNIQUE NOT NULL REFERENCES Mitarbeiter(pid) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE Saal (
	hid INTEGER REFERENCES Haus(hid),
	sid INTEGER,
	sname VARCHAR(40) NOT NULL,

	PRIMARY KEY (sid, hid)
);

ALTER TABLE Auffuehrung ADD CONSTRAINT fk_sid_hid FOREIGN KEY (sid, hid) REFERENCES Saal(sid, hid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE Mitarbeiter ADD CONSTRAINT fk_haus FOREIGN KEY (arbeitsplatz) REFERENCES Haus(hid) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE Platz (
	plid INTEGER DEFAULT nextval('seq_platz'),
	sid INTEGER,
	hid INTEGER,
	reihe INTEGER,
	sitz INTEGER,

	FOREIGN KEY (sid, hid) REFERENCES Saal(sid, hid),
	PRIMARY KEY (plid, sid, hid),
	UNIQUE (sid, reihe, sitz)
);

CREATE TABLE Ticket (
	tid INTEGER PRIMARY KEY DEFAULT nextval('seq_ticket'),
	knr INTEGER NULL REFERENCES Kunde(knr),

	aid INTEGER NOT NULL REFERENCES Auffuehrung(aid),
	plid INTEGER,
	sid INTEGER,
	hid INTEGER,

	preis NUMERIC(7,2) NOT NULL CHECK (preis >= 1),

	FOREIGN KEY (plid, sid, hid) REFERENCES Platz(plid, sid, hid) DEFERRABLE INITIALLY DEFERRED,

	UNIQUE (aid, plid, sid, hid)
);
