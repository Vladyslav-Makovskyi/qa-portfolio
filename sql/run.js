// Runs every query from queries.sql on a fresh in-memory database built from schema.sql
// and writes README.md with each task, query and real result.
// Usage: node sql/run.js   (Node 22.5+ with built-in node:sqlite)
const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

const db = new DatabaseSync(':memory:');
db.exec(fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8'));

const blocks = fs.readFileSync(path.join(__dirname, 'queries.sql'), 'utf8')
  .split(/^-- ### /m).slice(1);

let md = fs.readFileSync(path.join(__dirname, 'README.intro.md'), 'utf8');
for (const block of blocks) {
  const lines = block.split('\n');
  const title = lines.shift().trim();
  const notes = [];
  while (lines[0] && lines[0].startsWith('--')) notes.push(lines.shift().replace(/^--\s?/, ''));
  const sql = lines.join('\n').trim();
  const rows = db.prepare(sql).all();
  const cols = rows.length ? Object.keys(rows[0]) : [];
  const note = notes.length ? notes.join('\n') + '\n\n' : '';
  md += `\n### ${title}\n\n${note}\`\`\`sql\n${sql}\n\`\`\`\n\n`;
  if (!rows.length) { md += '_No rows._\n'; continue; }
  md += `| ${cols.join(' | ')} |\n|${cols.map(() => '---').join('|')}|\n`;
  for (const r of rows) md += `| ${cols.map(c => r[c] === null ? 'NULL' : r[c]).join(' | ')} |\n`;
}
fs.writeFileSync(path.join(__dirname, 'README.md'), md);
console.log('README.md written,', blocks.length, 'queries');
