// 探测单个页面：状态、标题、zip/media 直链
const url = process.argv[2];
const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' } });
const html = await r.text();
console.log('status', r.status, 'len', html.length, 'ctype', r.headers.get('content-type'));
const title = html.match(/<title>([^<]*)<\/title>/i);
console.log('title:', title ? title[1].trim() : '(none)');
const zips = [...new Set([...html.matchAll(/[^"'\s>]+\.zip/g)].map(m => m[0]))];
console.log('zip:', zips.slice(0, 8).join('\n') || 'none');
const media = [...new Set([...html.matchAll(/\/media\/pages\/[^"'\s>]+/g)].map(m => m[0]))];
console.log('media:', media.slice(0, 8).join('\n') || 'none');
const text = html.replace(/<script[\s\S]*?<\/script>/gi, ' ').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
console.log('text head:', text.slice(0, 600));
