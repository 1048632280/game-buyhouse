// 抓 pixel-buildings 仓库结构（CC0，600 栋）
const r = await fetch('https://api.github.com/repos/hoanglong256/pixel-buildings/git/trees/main?recursive=1', {
  headers: { 'User-Agent': 'node' },
});
const j = await r.json();
if (!j.tree) {
  console.log('ERR', JSON.stringify(j).slice(0, 300));
} else {
  const png = j.tree.filter(x => /\.(png|gif|webp)$/i.test(x.path));
  console.log('entries', j.tree.length, 'images', png.length);
  const dirs = [...new Set(png.map(p => p.path.split('/').slice(0, -1).join('/')))];
  console.log('dirs:', dirs.join('\n'));
  console.log('sample files:', png.slice(0, 12).map(p => p.path).join('\n'));
}
