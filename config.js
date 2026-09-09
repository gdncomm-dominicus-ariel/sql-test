/*
 * Runtime configuration for the Intern SQL Practice site.
 * There is no build step. Edit the values below, commit, and redeploy.
 */
window.SQL_PRACTICE_CONFIG = {
  // Which SQL editor to load:
  //   "codemirror" -> CodeMirror 5 with SQL syntax highlighting (loads from cdnjs)
  //   "textarea"   -> plain <textarea>, zero extra dependencies
  editor: "codemirror",

  // Pinned CDN versions. Change only if you know the asset paths still resolve.
  sqlJsVersion: "1.13.0",
  codeMirrorVersion: "5.65.16",

  // SQL shown in the editor on first load.
  starterQuery: ""
};
