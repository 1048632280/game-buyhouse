// 从 freepixel.art 建筑合辑页提取直链清单并落盘
import fs from 'node:fs';
const url = process.argv[2] || 'https://freepixel.art/browse/urban-buildings/';
const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
const html = await r.text();
const pngs = [...new Set([...html.matchAll(/https:\/\/pub-[a-z0-9]+\.r2\.dev\/[^"'\s>]+\.png/g)].map(m => m[0]))];
const items = pngs.map(u => {
  const name = decodeURIComponent(u.split('/').pop());
  return { url: u, dest: `raw/freepixel/buildings/${name}` };
});
fs.writeFileSync('manifest_freepixel.json', JSON.stringify(items, null, 1));
console.log('collected', items.length, 'png urls');
