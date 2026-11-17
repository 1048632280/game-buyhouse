// 取 2026.09.01 的 16px monospaced ttf
const r = await fetch('https://api.github.com/repos/TakWolf/ark-pixel-font/releases/tags/2026.09.01', {
  headers: { 'User-Agent': 'node' },
});
const j = await r.json();
const want = (j.assets || []).filter(a => /16px-monospaced-ttf-v/.test(a.name));
for (const a of want) console.log(a.name, Math.round(a.size / 1024) + 'KB', a.browser_download_url);
