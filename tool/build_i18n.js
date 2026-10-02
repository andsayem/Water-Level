// Builds assets/i18n/<code>.json from tool/i18n/<code>.txt.
// Each .txt line is "<n>|<translation>" where n is the 1-based index of the
// English key in tool/i18n_keys.json
// (run tool/extract_strings.js first). A literal "\n" means a line break.
//   node tool/build_i18n.js
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const keys = JSON.parse(fs.readFileSync(path.join(__dirname, 'i18n_keys.json'), 'utf8'));
const SRC = path.join(__dirname, 'i18n');
const OUT = path.join(ROOT, 'assets', 'i18n');
fs.mkdirSync(OUT, { recursive: true });

let failed = false;
for (const file of fs.readdirSync(SRC).filter((f) => f.endsWith('.txt')).sort()) {
  const code = path.basename(file, '.txt');
  const lines = fs.readFileSync(path.join(SRC, file), 'utf8').replace(/\r\n/g, '\n').replace(/\n+$/, '').split('\n');
  if (lines.length !== keys.length) {
    console.error(`${code}: ${lines.length} lines, expected ${keys.length}`);
    failed = true;
    continue;
  }
  const map = {};
  keys.forEach((k, i) => {
    const m = lines[i].match(/^(\d+)\|(.*)$/);
    if (!m || +m[1] !== i + 1) {
      console.error(`${code}: line ${i + 1} is numbered "${lines[i].slice(0, 12)}"`);
      failed = true;
      return;
    }
    const v = m[2].trim().replace(/\\n/g, '\n');
    // Keep numbers / symbols that must survive translation.
    for (const token of ['30', '54', '0.1', '±1', '13', 'CSV', 'dB']) {
      if (k.includes(token) && !v.includes(token)) console.warn(`${code} #${i + 1}: missing "${token}"`);
    }
    if (v && v !== k) map[k] = v;
  });
  fs.writeFileSync(path.join(OUT, `${code}.json`), JSON.stringify(map, null, 1));
  console.log(`${code}: ${Object.keys(map).length} strings`);
}
if (failed) process.exit(1);
