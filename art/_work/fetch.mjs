// 用法: node fetch.mjs <manifest.json>
// manifest: [{ "url": "...", "dest": "相对本文件所在目录的路径" }]
import fs from 'node:fs';
import path from 'node:path';

const manifestPath = process.argv[2];
const base = path.dirname(path.resolve(manifestPath));
const items = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

let ok = 0, fail = 0;
for (const it of items) {
  const dest = path.join(base, it.dest);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  if (fs.existsSync(dest) && fs.statSync(dest).size > 0) { ok++; continue; }
  let done = false;
  for (let attempt = 1; attempt <= 4 && !done; attempt++) {
    try {
      const r = await fetch(it.url, { redirect: 'follow', headers: { 'User-Agent': 'node-fetch' } });
      if (!r.ok) throw new Error('HTTP ' + r.status);
      const buf = Buffer.from(await r.arrayBuffer());
      if (buf.length < 100) throw new Error('too small: ' + buf.length);
      fs.writeFileSync(dest, buf);
      ok++;
      done = true;
      console.log(`OK   ${(buf.length + '').padStart(8)}  ${it.dest}`);
    } catch (e) {
      const cause = e.cause && e.cause.code ? ` (${e.cause.code})` : '';
      if (attempt === 4) {
        fail++;
        console.log(`FAIL ${it.dest}  ${e.message}${cause}`);
      } else {
        await new Promise(r => setTimeout(r, 1500 * attempt));
      }
    }
  }
}
console.log(`\n${ok} ok, ${fail} failed`);
