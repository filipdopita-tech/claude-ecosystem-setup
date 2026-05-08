#!/usr/bin/env node
// Render DEPO carousel HTML to PNG slides via Puppeteer headless Chrome.
// Usage: node render.mjs --html /tmp/carousel.html --out /tmp/out_dir [--slides N]

import puppeteer from 'puppeteer';
import { readFileSync, mkdirSync, existsSync } from 'fs';
import { dirname } from 'path';

function arg(name, def = null) {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 ? process.argv[i + 1] : def;
}

const HTML = arg('html');
const OUT = arg('out');
const FORCED = arg('slides');
if (!HTML || !OUT) { console.error('usage: render.mjs --html FILE --out DIR [--slides N]'); process.exit(1); }
if (!existsSync(HTML)) { console.error(`html not found: ${HTML}`); process.exit(1); }
mkdirSync(OUT, { recursive: true });

const browser = await puppeteer.launch({
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
  headless: 'new',
});
const page = await browser.newPage();
await page.setViewport({ width: 420, height: 525, deviceScaleFactor: 1080 / 420 });

await page.setContent(readFileSync(HTML, 'utf8'), { waitUntil: 'networkidle0' });
await page.evaluate(() => document.fonts.ready);
await new Promise(r => setTimeout(r, 1500));

const slideCount = FORCED ? parseInt(FORCED) : await page.evaluate(() => document.querySelectorAll('.track > div').length);
console.log(`rendering ${slideCount} slides → ${OUT}`);

await page.evaluate(() => {
  document.body.style.cssText = 'margin:0;padding:0;background:#000;';
  const w = document.querySelector('.wrap');
  if (w) w.style.cssText = 'width:420px;height:525px;border-radius:0;box-shadow:none;overflow:hidden;margin:0;';
  const v = document.querySelector('.vp');
  if (v) v.style.cssText = 'width:420px;height:525px;overflow:hidden;';
});

for (let i = 0; i < slideCount; i++) {
  await page.evaluate(i => {
    document.querySelector('.track').style.cssText =
      `display:flex;transition:none;transform:translateX(${-i * 420}px)`;
  }, i);
  await new Promise(r => setTimeout(r, 220));
  const fname = `slide_${String(i + 1).padStart(2, '0')}.png`;
  await page.screenshot({
    path: `${OUT}/${fname}`,
    clip: { x: 0, y: 0, width: 420, height: 525 },
  });
  console.log(`  ✓ ${i + 1}/${slideCount} ${fname}`);
}

await browser.close();
console.log(`done → ${OUT}`);
