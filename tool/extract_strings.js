// Collects every translatable English string from lib/ into
// assets/i18n/_keys.json (the source list used to build the language files).
//   node tool/extract_strings.js
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const LIB = path.join(ROOT, 'lib');

function files(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    e.isDirectory() ? files(path.join(dir, e.name)) : e.name.endsWith('.dart') ? [path.join(dir, e.name)] : []);
}

// Decodes a run of adjacent Dart string literals ('a' 'b' or "a" "b").
function decode(run) {
  const parts = [...run.matchAll(/'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)"/g)];
  return parts.map((m) => (m[1] ?? m[2])
    .replace(/\\u\{?([0-9a-fA-F]+)\}?/g, (_, h) => String.fromCodePoint(parseInt(h, 16)))
    .replace(/\\n/g, '\n').replace(/\\(['"$\\])/g, '$1')).join('');
}

const LIT = String.raw`(?:'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*")`;
const RUN = `${LIT}(?:\\s*${LIT})*`;
const keys = new Set();
const add = (s) => { if (s && /[A-Za-z]/.test(s) && !s.includes('$')) keys.add(s); };

for (const f of files(LIB)) {
  const src = fs.readFileSync(f, 'utf8');
  for (const m of src.matchAll(new RegExp(`\\btr\\(\\s*(${RUN})\\s*,?\\s*\\)`, 'g'))) add(decode(m[1]));
  // Data tables whose fields are passed through tr() at runtime.
  if (/tool_catalog|onboarding_screen|water_level_info_screen|home_screen/.test(f)) {
    for (const m of src.matchAll(new RegExp(`\\b(?:label|description|title|body|category):\\s*(${RUN})`, 'g'))) add(decode(m[1]));
  }
  if (/tool_catalog/.test(f)) {
    const cats = src.match(/toolCategories = \[([^\]]*)\]/);
    if (cats) for (const m of cats[1].matchAll(new RegExp(LIT, 'g'))) add(decode(m[0]));
  }
  if (/other_apps_section/.test(f)) {
    // ('Name', 'Description', 'asset', 'package') tuples: keep the description.
    for (const m of src.matchAll(new RegExp(`\\(\\s*${LIT},\\s*(${LIT}),\\s*'assets/`, 'g'))) add(decode(m[1]));
  }
}
// Keep the existing order (the translation files are line-aligned to it)
// and append any new strings at the end.
const keyFile = path.join(ROOT, "tool", "i18n_keys.json");
const old = fs.existsSync(keyFile) ? JSON.parse(fs.readFileSync(keyFile, "utf8")) : [];
const removed = old.filter((k) => !keys.has(k));
if (removed.length) console.log("unused keys kept:", removed);
const list = [...old, ...[...keys].filter((k) => !old.includes(k)).sort()];
fs.writeFileSync(keyFile, JSON.stringify(list, null, 1));
console.log(list.length, 'keys');
