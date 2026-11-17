// 打印页面中包含关键词的 HTML 片段，用于找下载按钮的真实链接
const url = process.argv[2];
const kw = process.argv[3] || 'Download';
const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
const html = await r.text();
let i = -1, n = 0;
while ((i = html.indexOf(kw, i + 1)) !== -1 && n < 6) {
  console.log(`--- @${i} ---`);
  console.log(html.slice(Math.max(0, i - 500), i + 500).replace(/\s+/g, ' '));
  n++;
}
if (n === 0) console.log('keyword not found');
