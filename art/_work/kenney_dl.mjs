// node kenney_dl.mjs <slug> [slug...]
// 走 kenney.nl 的 download-link 接口拿签名直链，下载 zip 到 raw/kenney/<slug>.zip，并解压到 raw/kenney/<slug>/
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\//, '')), 'raw/kenney');
const slugs = process.argv.slice(2);

for (const slug of slugs) {
  const id = Buffer.from(`assets/${slug}`).toString('hex');
  const dest = path.join(root, `${slug}.zip`);
  if (fs.existsSync(dest) && fs.statSync(dest).size > 1000) {
    console.log(`SKIP ${slug} (exists, ${fs.statSync(dest).size} bytes)`);
    continue;
  }
  try {
    const meta = await fetch(`https://kenney.nl/download-link/${id}`, {
      headers: { 'User-Agent': 'Mozilla/5.0', 'Referer': `https://kenney.nl/assets/${slug}` },
    });
    const j = await meta.json();
    if (!j.url) throw new Error('no url: ' + JSON.stringify(j).slice(0, 200));
    const file = await fetch(j.url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
    if (!file.ok) throw new Error('zip HTTP ' + file.status);
    const buf = Buffer.from(await file.arrayBuffer());
    fs.mkdirSync(root, { recursive: true });
    fs.writeFileSync(dest, buf);
    console.log(`OK   ${slug}  ${buf.length} bytes  <- ${j.url.split('/').pop()}`);
  } catch (e) {
    console.log(`FAIL ${slug}  ${e.message}`);
  }
}
