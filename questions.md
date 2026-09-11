# Practice questions — interviewer reference

This file is for the interviewers. The site does not show these questions. Give
the questions to the candidate yourself, in the order that you choose.

The database has three tables. See `seed.sql` for the exact data.

- `movies(id, title, release_year, genre, director, runtime_min, rating, box_office_earnings)`
- `actors(id, name, birth_country, birth_year)`
- `movie_cast(movie_id, actor_id, character_name, is_lead)` — junction table, `is_lead` is 1 or 0

`box_office_earnings` is in millions of USD. `rating` runs from 0.0 to 10.0.

The site is a scratchpad. The site does not grade answers. The site only runs
SQL and shows the result table. Every question below has one reference query and
the row count that the reference query returns against the seed data. If a
candidate query returns the same rows as the reference query, then the answer is
correct.

---

## Baseline — SELECT, WHERE, JOIN (5)

### B1. Movies released before 1990
Show the title and release year of every movie released before 1990.

```sql
SELECT title, release_year
FROM movies
WHERE release_year < 1990;
```
Returns 2 rows: `The Glass Meridian`, `The Quiet Fathom`.

### B2. Highly rated movies, best first
Show the title, genre and rating of every movie with a rating of 8.0 or higher,
ordered by rating from high to low.

```sql
SELECT title, genre, rating
FROM movies
WHERE rating >= 8.0
ORDER BY rating DESC;
```
Returns 11 rows.

### B3. Actors from one country
Show the name and birth year of every actor born in India.

```sql
SELECT name, birth_year
FROM actors
WHERE birth_country = 'India';
```
Returns 3 rows: Mira Chandra, Ravi Kapoor, Priya Nandakumar.

### B4. Cast of one movie
Show the actor name and character name for every cast member of `Neon Harbor`.

```sql
SELECT a.name, mc.character_name, mc.is_lead
FROM movie_cast mc
JOIN actors a ON a.id = mc.actor_id
JOIN movies m ON m.id = mc.movie_id
WHERE m.title = 'Neon Harbor';
```
Returns 3 rows.

### B5. Lead actors for one director
Show the movie title and the lead actor name for every movie directed by
`Marcus Vint`.

```sql
SELECT m.title, a.name
FROM movies m
JOIN movie_cast mc ON mc.movie_id = m.id
JOIN actors a ON a.id = mc.actor_id
WHERE m.director = 'Marcus Vint' AND mc.is_lead = 1
ORDER BY m.title;
```
Returns 8 rows (4 movies, 2 leads each).

---

## GROUP BY (5)

### G1. Average rating per genre, recent movies only
For movies released after 2010, show each genre with its average rating, ordered
by average rating from high to low.

```sql
SELECT genre, AVG(rating) AS avg_rating
FROM movies
WHERE release_year > 2010
GROUP BY genre
ORDER BY avg_rating DESC;
```
Returns 7 rows. Sci-Fi is first, with an average rating near 8.48.

### G2. Total earnings per director, good movies only
Among movies with a rating above 7.0, show each director with the total box
office earnings of those movies, ordered from highest to lowest.

```sql
SELECT director, SUM(box_office_earnings) AS total_earnings
FROM movies
WHERE rating > 7.0
GROUP BY director
ORDER BY total_earnings DESC;
```
Returns 10 rows. Marcus Vint is first at 1900. Kaito Brenner does not appear. The
only movie by Kaito Brenner has a rating of exactly 7.0, and the filter needs a
rating above 7.0.

### G3. Movie count per younger actor
For actors born after 1970, count how many movies each has appeared in. Show
only actors with more than one movie.

```sql
SELECT a.name, COUNT(DISTINCT mc.movie_id) AS movie_count
FROM actors a
JOIN movie_cast mc ON mc.actor_id = a.id
WHERE a.birth_year > 1970
GROUP BY a.id
HAVING COUNT(DISTINCT mc.movie_id) > 1
ORDER BY movie_count DESC;
```
Returns 9 rows. Danil Roshkov and Aroha Ngata are born after 1970, but each of
the two actors appears in only one movie. The `HAVING` clause removes the two
actors.

### G4. Lead appearances per actor, this century
Among lead roles only (`is_lead = 1`), and only for movies released after 2000,
count the lead appearances per actor.

```sql
SELECT a.name, COUNT(*) AS lead_count
FROM movie_cast mc
JOIN actors a ON a.id = mc.actor_id
JOIN movies m ON m.id = mc.movie_id
WHERE mc.is_lead = 1 AND m.release_year > 2000
GROUP BY a.id
ORDER BY lead_count DESC, a.name;
```
Returns 23 rows.

### G5. Average runtime per genre, big earners only
For movies with earnings above 100 (million), show the average runtime per
genre, ordered by average runtime from high to low.

```sql
SELECT genre, AVG(runtime_min) AS avg_runtime
FROM movies
WHERE box_office_earnings > 100
GROUP BY genre
ORDER BY avg_runtime DESC;
```
Returns 5 rows. Sci-Fi is first at 149.0.

---

## UNION (5)

### U6. Two title lists into one set
Combine two lists into one distinct list of movie titles: titles with a rating
above 8.5, and titles with earnings above 500.

```sql
SELECT title FROM movies WHERE rating > 8.5
UNION
SELECT title FROM movies WHERE box_office_earnings > 500;
```
Returns 8 rows. `Neon Harbor`, `The Velvet Circuit`, and `Interstellar` match
both filters, but each title appears one time, because `UNION` removes duplicate
rows.

### U7. Names from two sources
List names as one column: actors born before 1960, and directors of movies with
a rating above 9.0.

```sql
SELECT name FROM actors WHERE birth_year < 1960
UNION
SELECT director FROM movies WHERE rating > 9.0;
```
Returns 8 rows: 6 actor names, plus directors Ava Renner and Piotr Salk.

### U8. Labeled result set
Build one result set with a category column: movies where genre is `Drama`
labeled `Drama`, unioned with movies where genre is `Comedy` labeled `Comedy`.

```sql
SELECT title, 'Drama' AS category FROM movies WHERE genre = 'Drama'
UNION
SELECT title, 'Comedy' AS category FROM movies WHERE genre = 'Comedy'
ORDER BY category, title;
```
Returns 10 rows: 6 Drama, 4 Comedy.

### U9. Lead actors from two filters
Combine actor names who played a lead role in a movie released after 2015, with
actor names who played a lead role in a movie with a rating above 8. Return one list with no
duplicate names.

```sql
SELECT a.name
FROM movie_cast mc JOIN actors a ON a.id = mc.actor_id JOIN movies m ON m.id = mc.movie_id
WHERE mc.is_lead = 1 AND m.release_year > 2015
UNION
SELECT a.name
FROM movie_cast mc JOIN actors a ON a.id = mc.actor_id JOIN movies m ON m.id = mc.movie_id
WHERE mc.is_lead = 1 AND m.rating > 8;
```
Returns 20 rows.

### U10. Two movie subsets, title and genre
Union two filtered subsets of movies: those with a runtime above 150 minutes,
and those with earnings above 300. Return the title and genre for each, with no
duplicates.

```sql
SELECT title, genre FROM movies WHERE runtime_min > 150
UNION
SELECT title, genre FROM movies WHERE box_office_earnings > 300;
```
Returns 10 rows. `Ashfall Protocol`, `Interstellar`, `Silence`, `The Last
Cartographer`, and `The Salt Wife` have a runtime above 150 minutes. The other
movies match the earnings filter.

---

## Subqueries (5)

### S1. Movies above average rating
Show the title and rating of every movie with a rating above the overall
average rating.

```sql
SELECT title, rating FROM movies
WHERE rating > (SELECT AVG(rating) FROM movies);
```
Returns 12 rows. The average rating across all movies is near 7.89.

### S2. Actors who never had a lead role
Show the name of every actor who appears in `movie_cast`, but never with
`is_lead = 1`.

```sql
SELECT name FROM actors a
WHERE a.id NOT IN (SELECT actor_id FROM movie_cast WHERE is_lead = 1);
```
Returns 4 rows: Danil Roshkov, Jon Hamm, Jessica Chastain, Liam Neeson.

### S3. Directors whose every movie rates above 7
Show the name of every director where every movie by that director has a
rating above 7.0. Use `NOT EXISTS`, not `GROUP BY` with `HAVING`.

```sql
SELECT DISTINCT director FROM movies m1
WHERE NOT EXISTS (
  SELECT 1 FROM movies m2
  WHERE m2.director = m1.director AND m2.rating <= 7.0
);
```
Returns 7 rows: Ava Renner, Marcus Vint, Piotr Salk, Ingrid Vale, Joseph
Kosinski, Christopher Nolan, Martin Scorsese. Kaito Brenner does not appear,
because the only movie by Kaito Brenner has a rating of exactly 7.0. Dahlia
Fox, Leo Marsh, and Nina Corvo do not appear, because each has at least one
movie rated 7.0 or below.

### S4. Highest-earning movie per genre
Show the title, genre, and earnings of the movie with the highest earnings
inside each genre. Use a correlated subquery, not a `JOIN` on a grouped
subquery.

```sql
SELECT title, genre, box_office_earnings FROM movies m
WHERE box_office_earnings = (
  SELECT MAX(box_office_earnings) FROM movies m2 WHERE m2.genre = m.genre
);
```
Returns 7 rows, one per genre: `Top Gun: Maverick` (Action), `Little
Vandals` (Comedy), `The Last Cartographer` (Drama), `Sunflower Autopsy`
(Horror), `Rust and Roses` (Romance), `Interstellar` (Sci-Fi), `Ticker`
(Thriller).

### S5. Actors who share a movie with Tom Cruise
Show the distinct name of every actor who appeared in the same movie as
`Tom Cruise`, excluding Tom Cruise.

```sql
SELECT DISTINCT a.name FROM actors a
JOIN movie_cast mc ON mc.actor_id = a.id
WHERE mc.movie_id IN (
  SELECT movie_id FROM movie_cast mc2
  JOIN actors a2 ON a2.id = mc2.actor_id
  WHERE a2.name = 'Tom Cruise'
) AND a.name != 'Tom Cruise';
```
Returns 2 rows: Miles Teller, Jon Hamm.
