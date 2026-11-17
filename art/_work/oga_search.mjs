// 抓 OpenGameArt 搜索结果，列出条目
const q = process.argv[2];
const url = `https://opengameart.org/art-search-advanced?keys=${encodeURIComponent(q)}&field_art_type_tid%5B%5D=9&sort_by=count&sort_order=DESC`;
const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
const html = await r.text();
console.log('status', r.status, 'len', html.length, 'query:', q);
const items = [...html.matchAll(/<a href="(\/content\/[^"]+)"[^>]*>([^<]{2,80})<\/a>/g)]
  .map(m => ({ href: m[1], title: m[2].trim() }))
  .filter(x => !/^\/(content\/art-search|content\/tags)/.test(x.href));
const seen = new Set();
let n = 0;
for (const it of items) {
  if (seen.has(it.href) || n >= 25) continue;
  seen.add(it.href); n++;
  console.log(`${it.title}  ->  https://opengameart.org${it.href}`);
}
