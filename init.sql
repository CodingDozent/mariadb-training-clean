CREATE DATABASE IF NOT EXISTS schule;
USE schule;

-- Personen
CREATE TABLE personen (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  ort VARCHAR(100),
  email VARCHAR(150)
);

INSERT INTO personen (name, ort, email) VALUES
('Anna Müller', 'Berlin', 'anna@example.com'),
('Ben Schneider', 'Hamburg', 'ben@example.com'),
('Clara König', 'München', 'clara@example.com'),
('David Roth', 'Berlin', 'david@example.com');

-- Lehrer
CREATE TABLE lehrer (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  fach VARCHAR(100)
);

INSERT INTO lehrer (name, fach) VALUES
('Herr Weber', 'Mathematik'),
('Frau Schulz', 'Informatik'),
('Herr Braun', 'Englisch');

-- Räume
CREATE TABLE raeume (
  id INT AUTO_INCREMENT PRIMARY KEY,
  bezeichnung VARCHAR(50),
  kapazitaet INT
);

INSERT INTO raeume (bezeichnung, kapazitaet) VALUES
('Raum 101', 20),
('Raum 202', 15),
('Labor 1', 12);

-- Kurse
CREATE TABLE kurse (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titel VARCHAR(100) NOT NULL,
  lehrer_id INT,
  raum_id INT,
  FOREIGN KEY (lehrer_id) REFERENCES lehrer(id),
  FOREIGN KEY (raum_id) REFERENCES raeume(id)
);

INSERT INTO kurse (titel, lehrer_id, raum_id) VALUES
('Grundkurs Informatik', 2, 3),
('Mathe für Einsteiger', 1, 1),
('Englisch Konversation', 3, 2);

-- Teilnahmen (N:M)
CREATE TABLE teilnahmen (
  person_id INT,
  kurs_id INT,
  PRIMARY KEY (person_id, kurs_id),
  FOREIGN KEY (person_id) REFERENCES personen(id),
  FOREIGN KEY (kurs_id) REFERENCES kurse(id)
);

INSERT INTO teilnahmen (person_id, kurs_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 3),
(4, 2);
