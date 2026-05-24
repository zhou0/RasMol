const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const urls = [
    'http://localhost:3000/legacy/notice.html',
    'http://localhost:3000/legacy/rasmol.html',
    'http://localhost:3000/legacy/esrasmol2721.html'
  ];
  for (const url of urls) {
    await page.goto(url);
    const name = url.split('/').pop().replace('.html', '');
    await page.screenshot({ path: `/home/jules/verification/v2_${name}.png`, fullPage: false });
    console.log(`Saved screenshot for ${url}`);
  }
  await browser.close();
})();
