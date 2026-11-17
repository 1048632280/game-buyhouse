const r1 = await fetch('https://api.github.com/repos/TakWolf/ark-pixel-font/releases/tags/2026.05.07', { headers: { 'User-Agent': 'node' } });
const j1 = await r1.json();
for (const a of (j1.assets || []).filter(a => /16px-monospaced-ttf-v/.test(a.name))) console.log('ARK', a.name, Math.round(a.size / 1024) + 'KB', a.browser_download_url);

const r2 = await fetch('https://api.github.com/repos/SolidZORO/zpix-pixel-font/releases/latest', { headers: { 'User-Agent': 'node' } });
const j2 = await r2.json();
console.log('ZPIX tag', j2.tag_name);
for (const a of (j2.assets || [])) console.log('ZPIX', a.name, Math.round(a.size / 1024) + 'KB', a.browser_download_url);
