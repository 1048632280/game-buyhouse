const r = await fetch('https://api.github.com/repos/ACh-K/Cubic-11/releases/latest', { headers: { 'User-Agent': 'node' } });
const j = await r.json();
console.log('Cubic-11 tag:', j.tag_name, j.message || '');
for (const a of (j.assets || [])) console.log(' ', a.name, Math.round(a.size / 1024) + 'KB', a.browser_download_url);
