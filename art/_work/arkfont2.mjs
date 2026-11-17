const r = await fetch('https://api.github.com/repos/TakWolf/ark-pixel-font/releases/latest', {
  headers: { 'User-Agent': 'node' },
});
const j = await r.json();
console.log('tag:', j.tag_name);
for (const a of j.assets) {
  console.log(`${a.name}  ${Math.round(a.size / 1024)}KB`);
}
