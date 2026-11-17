// 抓 kenney.nl 资产列表，打印 slug 与下载直链
const listUrl = process.argv[2] || 'https://kenney.nl/assets';
const filter = process.argv[3] ? new RegExp(process.argv[3], 'i') : null;

function uniq(a) { return [...new Set(a)]; }

const r = await fetch(listUrl, { headers: { 'User-Agent': 'Mozilla/5.0' } });
const html = await r.text();
console.log('status', r.status, 'len', html.length);

const slugs = uniq([...html.matchAll(/href="(\/assets\/[a-z0-9\-]+)"/g)].map(m => m[1].replace('/assets/', '')));
const picked = filter ? slugs.filter(s => filter.test(s)) : slugs;
console.log(`packs: ${slugs.length}, matched: ${picked.length}`);
console.log(picked.join('\n'));

// 顺便看看有没有 zip 直链
const zips = uniq([...html.matchAll(/https?:\/\/[^"'\s>]+\.zip/g)].map(m => m[0]));
console.log('zip links:', zips.slice(0, 5).join('\n') || 'none');
