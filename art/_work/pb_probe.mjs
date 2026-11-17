// 探测 pixel-buildings GitHub Pages 站点
const url = process.argv[2] || 'https://hoanglong256.github.io/pixel-buildings/';
const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
const html = await r.text();
console.log('status', r.status, 'len', html.length);
const imgs = [...new Set([...html.matchAll(/(?:src|href)="([^"]+\.(?:png|webp|jpg|json))"/g)].map(m => m[1]))];
console.log('images:', imgs.length);
console.log(imgs.slice(0, 15).join('\n'));
const text = html.replace(/<script[\s\S]*?<\/script>/gi, ' ').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ');
console.log('text:', text.slice(0, 800));
const scripts = [...new Set([...html.matchAll(/src="([^"]+\.js)"/g)].map(m => m[1]))];
console.log('scripts:', scripts.join('\n'));
