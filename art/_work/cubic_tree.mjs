const r = await fetch('https://api.github.com/repos/ACh-K/Cubic-11/git/trees/main', { headers: { 'User-Agent': 'node' } });
const j = await r.json();
for (const f of (j.tree || [])) console.log(f.path, f.type);
