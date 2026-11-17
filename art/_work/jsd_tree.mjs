// 用 jsDelivr 的包目录 API 列出 GitHub 仓库文件（绕开 GitHub API 限流）
const repo = process.argv[2];
const r = await fetch(`https://data.jsdelivr.com/v1/packages/gh/${repo}`, { headers: { 'User-Agent': 'node' } });
const j = await r.json();
if (!j.versions) { console.log('ERR', JSON.stringify(j).slice(0, 300)); process.exit(0); }
const ver = (j.versions.find(v => v.version === (j.tags && j.tags.latest)) || j.versions[0]).version;
const r2 = await fetch(`https://data.jsdelivr.com/v1/packages/gh/${repo}@${ver}?structure=flat`, { headers: { 'User-Agent': 'node' } });
const j2 = await r2.json();
const files = j2.files || [];
const imgs = files.filter(f => /\.(png|webp|gif)$/i.test(f.name));
console.log('version', ver, 'files', files.length, 'images', imgs.length);
const dirs = {};
for (const f of imgs) {
  const d = f.name.split('/').slice(0, -1).join('/');
  dirs[d] = (dirs[d] || 0) + 1;
}
console.log('image dirs:');
for (const [d, n] of Object.entries(dirs).slice(0, 25)) console.log(' ', d, n);
console.log('sample:', imgs.slice(0, 10).map(f => f.name).join('\n'));
