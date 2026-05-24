const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  try {
    console.log('Navigating to homepage...');
    await page.goto('http://localhost:3000/');
    await page.screenshot({ path: 'homepage.png' });
    const content = await page.textContent('body');
    console.log('Homepage content length:', content.length);
    if (content.includes('About RasMol')) {
      console.log('Homepage summary found.');
    }

    console.log('Navigating to download page...');
    await page.goto('http://localhost:3000/download');
    await page.waitForTimeout(5000); // Wait for API fetch
    await page.screenshot({ path: 'download.png' });
    const downloadContent = await page.textContent('body');
    if (downloadContent.includes('Downloads')) {
      console.log('Download page title found.');
    }

    console.log('Checking legacy link...');
    const legacyLink = await page.$('a[href*="legacy"]');
    if (legacyLink) {
      console.log('Legacy link exists.');
    }

  } catch (error) {
    console.error('Verification failed:', error);
  } finally {
    await browser.close();
  }
})();
