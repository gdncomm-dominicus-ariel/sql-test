/*
 * Intern SQL Practice — client-side app.
 * Loads sql.js (SQLite compiled to WebAssembly), seeds an in-memory database
 * from seed.sql, and runs whatever SQL the candidate types.
 * Nothing is stored. A page reload resets everything.
 */
(function () {
  "use strict";

  var CONFIG = window.SQL_PRACTICE_CONFIG || {};
  var SQLJS_VERSION = CONFIG.sqlJsVersion || "1.13.0";
  var CM_VERSION = CONFIG.codeMirrorVersion || "5.65.16";
  var EDITOR_KIND = CONFIG.editor === "textarea" ? "textarea" : "codemirror";
  var CDN = "https://cdnjs.cloudflare.com/ajax/libs";

  var els = {
    editorHost: document.getElementById("editor-host"),
    run: document.getElementById("run-btn"),
    reset: document.getElementById("reset-btn"),
    status: document.getElementById("status"),
    results: document.getElementById("results"),
    runHint: document.getElementById("run-hint")
  };

  var db = null;          // the sql.js Database
  var SQLModule = null;   // the initialised sql.js module, kept for "Reset DB"
  var seedSql = "";       // text of seed.sql, kept for "Reset DB"
  var getQuery = null;    // function -> current editor text
  var setQuery = null;    // function(text) -> set editor text

  // ---- small helpers ------------------------------------------------------

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement("script");
      s.src = src;
      s.onload = resolve;
      s.onerror = function () { reject(new Error("Failed to load script: " + src)); };
      document.head.appendChild(s);
    });
  }

  function loadStyle(href) {
    return new Promise(function (resolve, reject) {
      var l = document.createElement("link");
      l.rel = "stylesheet";
      l.href = href;
      l.onload = resolve;
      l.onerror = function () { reject(new Error("Failed to load stylesheet: " + href)); };
      document.head.appendChild(l);
    });
  }

  function showError(message) {
    els.status.className = "error";
    els.status.textContent = message;
    els.results.innerHTML = "";
  }

  function showOk(message) {
    els.status.className = "ok";
    els.status.textContent = message;
  }

  function clearStatus() {
    els.status.className = "";
    els.status.textContent = "";
  }

  var isMac = /Mac|iPhone|iPad/.test(navigator.platform);
  var runComboLabel = (isMac ? "Cmd" : "Ctrl") + "+Enter to run";

  // ---- editor setup -----------------------------------------------------

  function buildTextareaEditor() {
    var ta = document.createElement("textarea");
    ta.id = "sql-textarea";
    ta.spellcheck = false;
    ta.value = CONFIG.starterQuery || "";
    els.editorHost.appendChild(ta);
    getQuery = function () { return ta.value; };
    setQuery = function (t) { ta.value = t; };
    ta.addEventListener("keydown", function (e) {
      if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
        e.preventDefault();
        runQuery();
      }
    });
  }

  function buildCodeMirrorEditor() {
    return loadStyle(CDN + "/codemirror/" + CM_VERSION + "/codemirror.min.css")
      .then(function () { return loadScript(CDN + "/codemirror/" + CM_VERSION + "/codemirror.min.js"); })
      .then(function () { return loadScript(CDN + "/codemirror/" + CM_VERSION + "/mode/sql/sql.min.js"); })
      .then(function () {
        var ta = document.createElement("textarea");
        els.editorHost.appendChild(ta);
        var cm = window.CodeMirror.fromTextArea(ta, {
          mode: "text/x-sqlite",
          lineNumbers: true,
          lineWrapping: true,
          autofocus: true,
          extraKeys: {
            "Cmd-Enter": runQuery,
            "Ctrl-Enter": runQuery
          }
        });
        cm.setValue(CONFIG.starterQuery || "");
        getQuery = function () { return cm.getValue(); };
        setQuery = function (t) { cm.setValue(t); };
      });
  }

  function setupEditor() {
    if (EDITOR_KIND === "textarea") {
      buildTextareaEditor();
      return Promise.resolve();
    }
    return buildCodeMirrorEditor().catch(function (err) {
      // If CodeMirror fails to load, fall back to a plain textarea so the
      // site still works offline or on a blocked CDN.
      console.warn("CodeMirror load failed, falling back to textarea.", err);
      buildTextareaEditor();
    });
  }

  // ---- database -------------------------------------------------------

  function seedDatabase() {
    if (!SQLModule) { throw new Error("sql.js module is not loaded yet."); }
    if (db) { db.close(); }
    db = new SQLModule.Database();
    db.run(seedSql);
  }

  function runQuery() {
    if (!db) {
      showError("Database is not ready yet. Wait a moment and try again.");
      return;
    }
    var sql = (getQuery() || "").trim();
    clearStatus();
    els.results.innerHTML = "";
    if (!sql) {
      showError("Type a SQL query first.");
      return;
    }

    var started = performance.now();
    var resultSets;
    try {
      resultSets = db.exec(sql);
    } catch (err) {
      showError("SQL error: " + err.message);
      return;
    }
    var elapsed = (performance.now() - started).toFixed(1);

    if (!resultSets || resultSets.length === 0) {
      showOk("Statement ran in " + elapsed + " ms. No rows returned.");
      return;
    }

    // db.exec returns one entry per statement that produced a result set.
    // Render the last one, and note if earlier statements also returned rows.
    var last = resultSets[resultSets.length - 1];
    renderTable(last);
    var extra = resultSets.length > 1
      ? " (" + resultSets.length + " statements returned rows; showing the last)"
      : "";
    showOk(last.values.length + " row" + (last.values.length === 1 ? "" : "s")
      + " in " + elapsed + " ms" + extra);
  }

  function renderTable(resultSet) {
    var wrap = document.createElement("div");
    wrap.className = "result-scroll";
    var table = document.createElement("table");
    table.className = "result";

    var thead = document.createElement("thead");
    var htr = document.createElement("tr");
    resultSet.columns.forEach(function (col) {
      var th = document.createElement("th");
      th.textContent = col;
      htr.appendChild(th);
    });
    thead.appendChild(htr);
    table.appendChild(thead);

    var tbody = document.createElement("tbody");
    if (resultSet.values.length === 0) {
      var note = document.createElement("p");
      note.className = "empty-note";
      note.textContent = "Query is valid but matched zero rows.";
      wrap.appendChild(table);
      table.appendChild(tbody);
      els.results.appendChild(wrap);
      els.results.appendChild(note);
      return;
    }
    resultSet.values.forEach(function (row) {
      var tr = document.createElement("tr");
      row.forEach(function (cell) {
        var td = document.createElement("td");
        if (cell === null) {
          td.textContent = "NULL";
          td.className = "null-cell";
        } else {
          td.textContent = String(cell);
        }
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    wrap.appendChild(table);
    els.results.appendChild(wrap);
  }

  function describeSeed() {
    try {
      var q = "SELECT (SELECT COUNT(*) FROM movies), (SELECT COUNT(*) FROM actors), (SELECT COUNT(*) FROM movie_cast)";
      var row = db.exec(q)[0].values[0];
      return row[0] + " movies, " + row[1] + " actors, " + row[2] + " cast rows loaded.";
    } catch (err) {
      return "Database loaded.";
    }
  }

  function resetDatabase() {
    try {
      seedDatabase();
      showOk("Database reset to the original seed data.");
      els.results.innerHTML = "";
    } catch (err) {
      showError("Could not reset the database: " + err.message);
    }
  }

  // ---- boot ------------------------------------------------------------

  function boot() {
    els.run.disabled = true;
    els.reset.disabled = true;
    els.runHint.textContent = runComboLabel;

    var editorReady = setupEditor();

    var seedReady = fetch("seed.sql").then(function (r) {
      if (!r.ok) { throw new Error("HTTP " + r.status + " fetching seed.sql"); }
      return r.text();
    }).then(function (text) { seedSql = text; });

    var sqlReady = loadScript(CDN + "/sql.js/" + SQLJS_VERSION + "/sql-wasm.js")
      .then(function () {
        return window.initSqlJs({
          locateFile: function (file) {
            return CDN + "/sql.js/" + SQLJS_VERSION + "/" + file;
          }
        });
      });

    Promise.all([editorReady, seedReady, sqlReady]).then(function (values) {
      SQLModule = values[2];
      seedDatabase();
      els.run.disabled = false;
      els.reset.disabled = false;
      els.run.addEventListener("click", runQuery);
      els.reset.addEventListener("click", resetDatabase);
      showOk("Ready. " + describeSeed() + " " + runComboLabel + ".");
    }).catch(function (err) {
      showError("Startup failed: " + err.message
        + "\nCheck the network tab. The site needs cdnjs.cloudflare.com and a static server (not file://).");
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
