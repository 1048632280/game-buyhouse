async function tree(repo, branch) {
  const r = await fetch(`https://api.github.com/repos/${repo}/git/trees/${branch}?recursive=1`, { headers: { 'User-Agent': 'node' } });
  const j = await r.json();
  if (!j.tree) { console.log(repo, 'ERR', JSON.stringify(j).slice(0, 200)); return; }
  const ttf = j.tree.filter(x => /\.(ttf|otf|woff2)$/i.test(x.path));
  console.log(`=== ${repo} (${j.tree.length} entries) ttf/otf: ${ttf.length}`);
  for (const f of ttf.slice(0, 15)) console.log('  ', f.path, Math.round((f.size || 0) / 1024) + 'KB');
}

await tree('ACh-K/Cubic-11', 'main');
await tree('TakWolf/fusion-pixel-font', 'main');
