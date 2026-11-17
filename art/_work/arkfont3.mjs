const r = await fetch('https://api.github.com/repos/TakWolf/ark-pixel-font/releases?per_page=20', {
  headers: { 'User-Agent': 'node' },
});
const j = await r.json();
for (const rel of j) {
  const names = (rel.assets || []).map(a => a.name);
  const has16 = names.filter(n => n.includes('16px'));
  console.log(rel.tag_name, 'assets:', names.length, '16px:', has16.length, has16.slice(0, 3).join(','));
}
