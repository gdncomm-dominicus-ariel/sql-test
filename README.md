# Intern SQL Practice

This project is a single static web page. A candidate writes a SELECT query on
the page and runs the query against a small SQLite database. The database runs
inside the browser. There is no backend, no login, and no stored data. A page
reload restores the original data.

The SQL engine is [sql.js](https://github.com/sql-js/sql.js). sql.js is SQLite
compiled to WebAssembly. The page loads sql.js from the cdnjs CDN at runtime.

## Read-only

The database is read-only. After the seed runs, `app.js` sends
`PRAGMA query_only = true`, so SQLite rejects every write: INSERT, UPDATE,
DELETE, CREATE, DROP, and ALTER. `app.js` also checks the input box before the
engine runs, and it rejects any statement that does not start with SELECT, WITH,
EXPLAIN, or VALUES. So there is no reset control. A page reload is the only way
to rebuild the database, and a reload is never needed for a read-only query.

## Files

| File           | Purpose                                                              |
|----------------|--------------------------------------------------------------------|
| `index.html`   | The page. It holds the schema panel, the SQL editor, and the results table. |
| `styles.css`   | The styling. The page follows the browser light or dark setting.    |
| `config.js`    | The runtime configuration. Edit this file to change the editor or the starter query. |
| `app.js`       | The logic. It loads sql.js, seeds the database, runs queries, and renders output. |
| `seed.sql`     | The `CREATE TABLE` and `INSERT` statements. This file is the single source of the data. |
| `questions.md` | The practice questions. This file is for interviewers. The page does not show the questions. |

## Run the site on your machine

The page fetches `seed.sql`, so you need a static file server. If you open
`index.html` directly from the file system, then the fetch fails and the page
does not work.

```sh
# from the repo root
uv run python -m http.server 8000
```

Then open `http://localhost:8000`.

Any static server works. `python3 -m http.server 8000` and `npx serve` are both
fine.

## Configuration

Edit `config.js`. There is no build step.

- `editor`: Set `"codemirror"` for a SQL editor with syntax highlighting. Set
  `"textarea"` for a plain text box with no extra dependency. If CodeMirror does
  not load, then the page uses a plain text box instead.
- `sqlJsVersion` and `codeMirrorVersion`: The pinned CDN versions. Change these
  values only after you confirm that the new asset paths still work on cdnjs.
- `starterQuery`: The SQL that the editor shows on first load.

## Deploy to GitHub Pages

1. Push this repo to GitHub. If your GitHub account is a free account, then the
   repo must be public for GitHub Pages.
2. Open **Settings**, then **Pages**.
3. Under **Build and deployment**, set **Source** to **Deploy from a branch**.
4. Set the branch to `main` and the folder to `/ (root)`. Save.
5. Wait for the first deploy to finish. The site address is
   `https://<username>.github.io/<repo-name>/`.
6. Open the site address in a private browser window. Confirm that the page loads
   with no login prompt. Then send the address to a candidate.

## The database

There are three tables. Most names are fictional. Three real movies and their
real actors were added by request.

**movies**

| column                | type    | notes                    |
|-----------------------|---------|--------------------------|
| id                    | INTEGER | primary key              |
| title                 | TEXT    |                          |
| release_year          | INTEGER |                          |
| genre                 | TEXT    | Drama, Comedy, Action, Sci-Fi, Thriller, Horror, Romance |
| director              | TEXT    | some directors have two or more movies |
| runtime_min           | INTEGER | minutes                  |
| rating                | REAL    | 0.0 to 10.0              |
| box_office_earnings   | INTEGER | millions of USD          |

**actors**

| column        | type    | notes       |
|---------------|---------|-------------|
| id            | INTEGER | primary key |
| name          | TEXT    |             |
| birth_country | TEXT    |             |
| birth_year    | INTEGER |             |

**movie_cast**

| column         | type    | notes                                       |
|----------------|---------|---------------------------------------------|
| movie_id       | INTEGER | refers to `movies.id`                       |
| actor_id       | INTEGER | refers to `actors.id`                       |
| character_name | TEXT    |                                             |
| is_lead        | INTEGER | 1 for a lead role, 0 for a supporting role  |

The junction table is named `movie_cast`, not `cast`. SQLite reserves the word
`cast` for the `CAST(...)` expression. If a table is named `cast`, then every
query must quote the name. The name `movie_cast` does not need a quote.

Row counts: 23 movies, 29 actors, 69 cast rows. The data is deliberately uneven.
Some actors appear in one movie. Some actors appear in four movies. Some
directors have one movie. Some directors have three movies. Ratings, years, and
earnings are spread out, so a filtered query returns a result set that is not
trivial.
