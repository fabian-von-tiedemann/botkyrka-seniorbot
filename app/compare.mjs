import { chromium } from 'playwright';

const browser = await chromium.launch();

// Screenshot our page
const page1 = await browser.newPage({ viewport: { width: 1280, height: 900 } });
await page1.goto('http://localhost:3099', { waitUntil: 'domcontentloaded', timeout: 10000 });
await new Promise(r => setTimeout(r, 1000));
await page1.screenshot({ path: '/tmp/compare-ours-top.png' });
await page1.screenshot({ path: '/tmp/compare-ours-full.png', fullPage: true });

// Screenshot original HTML file
const page2 = await browser.newPage({ viewport: { width: 1280, height: 900 } });
await page2.goto('file:///Users/fabianvontiedemann/kod/_Botkyrka/seniorbot/webbsida/Äldreomsorg - Botkyrka kommun.html', { waitUntil: 'domcontentloaded', timeout: 10000 });
await new Promise(r => setTimeout(r, 1000));
await page2.screenshot({ path: '/tmp/compare-orig-top.png' });
await page2.screenshot({ path: '/tmp/compare-orig-full.png', fullPage: true });

console.log('Screenshots taken');
await browser.close();
