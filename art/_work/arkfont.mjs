// 列出 Ark Pixel Font 的 GitHub release 资产
const r = await fetch('https://api.github.com/repos/TakWolf/ark-pixel-font/releases/latest', {
  headers: { 'User-Agent': 'node' },
});
const j = await r.json();
console.log('tag:', j.tag_name, 'name:', j.name);
const assets = (j.assets || []).map(a => ({ name: a.name, size: Math.round(a.size / 1024) + 'KB', url: a.browser_download_url }));
console.log('assets:', assets.length);
for (const a of assets.filter(a => /16px/.test(a.name)).slice(0, 20)) console.log(a.name, a.size);
if (!assets.length) console.log(JSON.stringify(j).slice(0, 400));
