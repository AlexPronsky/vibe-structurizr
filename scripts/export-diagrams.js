// Экспорт диаграмм Structurizr в SVG через Puppeteer
// Основан на https://github.com/structurizr/puppeteer

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const IMAGE_VIEW_TYPE = 'Image';

if (process.argv.length < 3) {
  console.log("Использование: node export-diagrams.js <structurizrUrl> [outputDir]");
  console.log("Пример:        node export-diagrams.js http://structurizr:8080/workspace/diagrams /output");
  process.exit(1);
}

const url = process.argv[2];
const outputDir = process.argv[3] || '.';

// Убедиться, что каталог вывода существует
fs.mkdirSync(outputDir, { recursive: true });

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  console.log(" - Открываю " + url);
  await page.goto(url, { waitUntil: 'domcontentloaded' });

  // Ждём, пока Structurizr полностью отрендерит диаграмму
  await page.waitForFunction(
    'structurizr.scripting && structurizr.scripting.isDiagramRendered() === true',
    { timeout: 30000 }
  );

  // Получаем список всех представлений
  const views = await page.evaluate(() => {
    return structurizr.scripting.getViews();
  });

  console.log(" - Найдено представлений: " + views.length);

  let exported = 0;

  for (const view of views) {
    await page.evaluate((key) => {
      structurizr.scripting.changeView(key);
    }, view.key);

    await page.waitForFunction(
      'structurizr.scripting.isDiagramRendered() === true',
      { timeout: 15000 }
    );

    // Экспорт диаграммы
    const diagramFile = path.join(outputDir, view.key + '.svg');
    const svgDiagram = await page.evaluate(() => {
      return structurizr.scripting.exportCurrentDiagramToSVG({ includeMetadata: true });
    });
    fs.writeFileSync(diagramFile, svgDiagram);
    console.log(" - " + view.key + '.svg');
    exported++;

    // Экспорт легенды (для не-Image представлений)
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

  console.log(" - Готово! Экспортировано файлов: " + exported);
  await browser.close();
})();
