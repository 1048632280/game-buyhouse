// 探测 freepixel.art 的城市建筑合辑页：找 PNG 直链与打包下载
const url = process.argv[2] || 'https://freepixel.art/browse/urban-buildings/';
const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
const html = await r.text();
console.log('status', r.status, 'len', html.length);
const pngs = [...new Set([...html.matchAll(/[^"'\s>]+\.png/g)].map(m => m[0]))];
console.log('png links:', pngs.length);
console.log(pngs.slice(0, 10).join('\n'));
const zips = [...new Set([...html.matchAll(/[^"'\s>]+\.zip/g)].map(m => m[0]))];
console.log('zips:', zips.slice(0, 5).join('\n') || 'none');
const links = [...new Set([...html.matchAll(/href="([^"]+)"/g)].map(m => m[1]))].filter(x => /asset|download|pack/i.test(x));
console.log('related:', links.slice(0, 15).join('\n'));
