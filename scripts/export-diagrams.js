// Export Structurizr diagrams to SVG via Puppeteer
// Based on https://github.com/structurizr/puppeteer

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const IMAGE_VIEW_TYPE = 'Image';

if (process.argv.length < 3) {
  console.log("Usage: node export-diagrams.js <structurizrUrl> [outputDir]");
  console.log("Example: node export-diagrams.js http://structurizr:8080/workspace/diagrams /output");
  process.exit(1);
}

const url = process.argv[2];
const outputDir = process.argv[3] || '.';

// Ensure output directory exists
fs.mkdirSync(outputDir, { recursive: true });

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  console.log(" - Opening " + url);
  await page.goto(url, { waitUntil: 'domcontentloaded' });

  // Wait for Structurizr to fully render the diagram
  await page.waitForFunction(
    'structurizr.scripting && structurizr.scripting.isDiagramRendered() === true',
    { timeout: 30000 }
  );

  // Get list of all views
  const views = await page.evaluate(() => {
    return structurizr.scripting.getViews();
  });

  console.log(" - Views found: " + views.length);

  let exported = 0;

  for (const view of views) {
    await page.evaluate((key) => {
      structurizr.scripting.changeView(key);
    }, view.key);

    await page.waitForFunction(
      'structurizr.scripting.isDiagramRendered() === true',
      { timeout: 15000 }
    );

    // Export diagram
    const diagramFile = path.join(outputDir, view.key + '.svg');
    const svgDiagram = await page.evaluate(() => {
      return structurizr.scripting.exportCurrentDiagramToSVG({ includeMetadata: true });
    });
    fs.writeFileSync(diagramFile, svgDiagram);
    console.log(" - " + view.key + '.svg');
    exported++;

    // Export legend (for non-Image views)
    if (view.type !== IMAGE_VIEW_TYPE) {
      const keyFile = path.join(outputDir, view.key + '-key.svg');
      const svgKey = await page.evaluate(() => {
        return structurizr.scripting.exportCurrentDiagramKeyToSVG();
      });
      fs.writeFileSync(keyFile, svgKey);
      console.log(" - " + view.key + '-key.svg');
      exported++;
    }
  }

  console.log(" - Done! Files exported: " + exported);
  await browser.close();
})();
