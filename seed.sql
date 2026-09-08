-- Intern SQL Practice — seed data
-- Most names are fictional. Three real movies (ids 21-23) and their real actors
-- (ids 21-29) were added by request. The data is shaped so that filtered /
-- grouped / unioned queries return non-trivial result sets.
--
-- Tables:
--   movies(id, title, release_year, genre, director, runtime_min, rating, box_office_earnings)
--   actors(id, name, birth_country, birth_year)
--   movie_cast(movie_id, actor_id, character_name, is_lead)   -- junction table, renamed from "cast" (reserved word)

DROP TABLE IF EXISTS movie_cast;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS actors;

CREATE TABLE movies (
  id                  INTEGER PRIMARY KEY,
  title               TEXT    NOT NULL,
  release_year        INTEGER NOT NULL,
  genre               TEXT    NOT NULL,
  director            TEXT    NOT NULL,
  runtime_min         INTEGER NOT NULL,
  rating              REAL    NOT NULL,   -- 0.0 .. 10.0
  box_office_earnings INTEGER NOT NULL    -- in millions of USD
);

CREATE TABLE actors (
  id            INTEGER PRIMARY KEY,
  name          TEXT    NOT NULL,
  birth_country TEXT    NOT NULL,
  birth_year    INTEGER NOT NULL
);

CREATE TABLE movie_cast (
  movie_id       INTEGER NOT NULL REFERENCES movies(id),
  actor_id       INTEGER NOT NULL REFERENCES actors(id),
  character_name TEXT    NOT NULL,
  is_lead        INTEGER NOT NULL   -- 1 = lead role, 0 = supporting
);

INSERT INTO movies (id, title, release_year, genre, director, runtime_min, rating, box_office_earnings) VALUES
  (1,  'The Glass Meridian',   1988, 'Drama',    'Ava Renner',     132, 8.7,  84),
  (2,  'Neon Harbor',          2014, 'Sci-Fi',   'Marcus Vint',    141, 8.9, 540),
  (3,  'Paper Tigers',         2009, 'Comedy',   'Dahlia Fox',      98, 6.8,  45),
  (4,  'The Last Cartographer',2017, 'Drama',    'Ava Renner',     155, 9.1, 210),
  (5,  'Crimson Signal',       2012, 'Action',   'Marcus Vint',    128, 7.4, 320),
  (6,  'Hollow Lantern',       1995, 'Thriller', 'Piotr Salk',     117, 7.9,  66),
  (7,  'Sunflower Autopsy',    2019, 'Horror',   'Nina Corvo',     101, 6.2,  33),
  (8,  'Midnight Arithmetic',  2016, 'Drama',    'Dahlia Fox',     124, 8.2, 150),
  (9,  'The Velvet Circuit',   2021, 'Sci-Fi',   'Marcus Vint',    149, 8.6, 610),
  (10, 'Brass Monkey Blues',   2003, 'Comedy',   'Leo Marsh',       94, 7.1, 120),
  (11, 'Gravity''s Ledger',    2013, 'Sci-Fi',   'Ingrid Vale',    137, 7.7, 260),
  (12, 'The Quiet Fathom',     1979, 'Drama',    'Piotr Salk',     144, 9.3,  22),
  (13, 'Rust and Roses',       2018, 'Romance',  'Dahlia Fox',     108, 7.3,  95),
  (14, 'Ticker',               2011, 'Thriller', 'Ingrid Vale',    112, 8.4, 175),
  (15, 'Cardboard Empire',     2007, 'Comedy',   'Leo Marsh',       89, 6.5,  40),
  (16, 'The Salt Wife',        2022, 'Drama',    'Ava Renner',     158, 8.8, 130),
  (17, 'Ronin Frequency',      2015, 'Action',   'Marcus Vint',    133, 8.1, 430),
  (18, 'Little Vandals',       2020, 'Comedy',   'Nina Corvo',      96, 7.6, 180),
  (19, 'Ashfall Protocol',     2016, 'Action',   'Kaito Brenner',  151, 7.0, 305),
  (20, 'The Cobalt Hour',      2010, 'Thriller', 'Piotr Salk',     119, 7.8,  88),
  (21, 'Top Gun: Maverick',    2022, 'Action',   'Joseph Kosinski',131, 8.2, 1496),
  (22, 'Interstellar',         2014, 'Sci-Fi',   'Christopher Nolan', 169, 8.7, 731),
  (23, 'Silence',              2016, 'Drama',    'Martin Scorsese', 161, 7.2, 24);

INSERT INTO actors (id, name, birth_country, birth_year) VALUES
  (1,  'Corvin Blake',      'Ireland',     1954),
  (2,  'Selma Ortega',      'Mexico',      1968),
  (3,  'Danil Roshkov',     'Russia',      1971),
  (4,  'Mira Chandra',      'India',       1983),
  (5,  'Theo Lindqvist',    'Sweden',      1959),
  (6,  'Gwen Ashby',        'Wales',       1975),
  (7,  'Kofi Mensah',       'Ghana',       1980),
  (8,  'Bianca Feld',       'Austria',     1949),
  (9,  'Ravi Kapoor',       'India',       1965),
  (10, 'Noa Halvorsen',     'Norway',      1988),
  (11, 'Imani Cole',        'USA',         1979),
  (12, 'Lars Bergman',      'Sweden',      1962),
  (13, 'Priya Nandakumar',  'India',       1990),
  (14, 'Hugo Marchetti',    'Italy',       1957),
  (15, 'Yuki Tanaka',       'Japan',       1972),
  (16, 'Etta Rowe',         'USA',         1945),
  (17, 'Sami Haddad',       'Lebanon',     1985),
  (18, 'Fenna de Vries',    'Netherlands', 1978),
  (19, 'Grigor Petrov',     'Bulgaria',    1966),
  (20, 'Aroha Ngata',       'New Zealand', 1992),
  (21, 'Tom Cruise',          'USA',       1962),
  (22, 'Miles Teller',        'USA',       1987),
  (23, 'Matthew McConaughey', 'USA',       1969),
  (24, 'Anne Hathaway',       'USA',       1982),
  (25, 'Andrew Garfield',     'USA',       1983),
  (26, 'Adam Driver',         'USA',       1983),
  (27, 'Jon Hamm',            'USA',       1971),
  (28, 'Jessica Chastain',    'USA',       1977),
  (29, 'Liam Neeson',         'Ireland',   1952);

-- Appearance counts are deliberately uneven. Danil Roshkov (id 3) and Aroha Ngata
-- (id 20) appear in exactly one movie, so a "HAVING COUNT(...) > 1" filter has an
-- effect. Corvin Blake, Ravi Kapoor, Mira Chandra, Kofi Mensah and Noa Halvorsen
-- appear in four each.
INSERT INTO movie_cast (movie_id, actor_id, character_name, is_lead) VALUES
  (1,  1,  'Judge Hale',              1),
  (1,  16, 'Marla Hale',              1),
  (1,  14, 'Father Bruno',            0),
  (2,  4,  'Captain Dey',             1),
  (2,  7,  'Engineer Osei',           1),
  (2,  3,  'Dockmaster Volkov',       0),
  (3,  2,  'Rosa',                    1),
  (3,  9,  'Uncle Vik',               1),
  (3,  6,  'The Neighbour',           0),
  (4,  5,  'Anders',                  1),
  (4,  10, 'Sigrid',                  1),
  (4,  12, 'Guild Head Holt',         0),
  (5,  15, 'Lieutenant Sato',         1),
  (5,  19, 'Colonel Petrov',          1),
  (5,  9,  'Munitions Chief Vik',     0),
  (6,  8,  'Doctor Adler',            1),
  (6,  14, 'Inspector Bruno',         1),
  (6,  1,  'The Coroner',             0),
  (7,  11, 'Dana',                    1),
  (7,  17, 'Marcus',                  1),
  (7,  13, 'The Intern',              0),
  (8,  9,  'Professor Menon',         1),
  (8,  13, 'Anjali',                  1),
  (8,  4,  'Dean Chandra',            0),
  (9,  4,  'Archivist Dey',           1),
  (9,  7,  'Runner Osei',             1),
  (9,  18, 'Broker Katje',            0),
  (10, 2,  'Lola',                    1),
  (10, 19, 'Sal',                     1),
  (10, 11, 'The Bartender',           0),
  (11, 6,  'Commander Pryce',         1),
  (11, 12, 'Doctor Holt',             1),
  (11, 10, 'Pilot Halvorsen',         0),
  (12, 16, 'Vera',                    1),
  (12, 1,  'Thomas',                  1),
  (12, 8,  'Sister Agnes',            0),
  (13, 18, 'Katje',                   1),
  (13, 17, 'Elias',                   1),
  (13, 2,  'The Florist',             0),
  (14, 15, 'Detective Sato',          1),
  (14, 11, 'Agent Cole',              1),
  (14, 7,  'Wire Analyst Osei',       0),
  (15, 9,  'Boss Vik',                1),
  (15, 6,  'Reporter Ashby',          1),
  (15, 5,  'The Accountant',          0),
  (16, 10, 'Marit',                   1),
  (16, 5,  'Old Jonas',               1),
  (16, 13, 'The Daughter',            0),
  (17, 15, 'The Ronin',               1),
  (17, 20, 'Signalwoman Ngata',       1),
  (17, 19, 'The Warlord',             0),
  (18, 7,  'Coach Osei',              1),
  (18, 4,  'Miss Chandra',            1),
  (18, 10, 'Student Halvorsen',       0),
  (19, 18, 'Doctor de Vries',         1),
  (19, 12, 'Governor Holt',           1),
  (19, 16, 'The Archivist',           0),
  (20, 14, 'Inspector Bruno',         1),
  (20, 8,  'Doctor Adler',            1),
  (20, 1,  'The Night Guard',         0),
  (21, 21, 'Captain Pete Mitchell',   1),
  (21, 22, 'Lieutenant Bradshaw',     1),
  (21, 27, 'Admiral Cyclone',         0),
  (22, 23, 'Joseph Cooper',           1),
  (22, 24, 'Doctor Brand',            1),
  (22, 28, 'Murph Cooper',            0),
  (23, 25, 'Father Rodrigues',        1),
  (23, 26, 'Father Garupe',           1),
  (23, 29, 'Father Ferreira',         0);
