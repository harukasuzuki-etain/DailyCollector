const { chromium } = require('playwright');

/**
 * Daily Collector - Web Scraper
 * 基本的なスクレイピングテンプレート
 */
async function scrapeData() {
    const browser = await chromium.launch({
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--disable-gpu'
        ]
    });

    try {
        const context = await browser.newContext();
        const page = await context.newPage();

        // 環境変数から設定を取得
        const targetUrl = process.env.TARGET_URL || 'https://example.com';
        const username = process.env.SCRAPE_USERNAME;
        const password = process.env.SCRAPE_PASSWORD;

        console.log(`Accessing: ${targetUrl}`);
        
        // ページにアクセス
        await page.goto(targetUrl, { waitUntil: 'networkidle' });

        // ログインが必要な場合の処理例
        if (username && password) {
            console.log('Attempting login...');
            // ログインフォームの例（実際のサイトに合わせて修正が必要）
            await page.fill('input[name="username"]', username);
            await page.fill('input[name="password"]', password);
            await page.click('button[type="submit"]');
            await page.waitForLoadState('networkidle');
        }

        // データ収集の例
        const scrapedData = {
            timestamp: new Date().toISOString(),
            url: targetUrl,
            title: await page.title(),
            // 実際のデータ収集ロジックをここに追加
            // 例: テーブルデータの取得
            // data: await page.$$eval('table tr', rows => 
            //     rows.map(row => Array.from(row.cells, cell => cell.textContent.trim()))
            // )
        };

        // JSON形式で出力（n8nで処理できる形式）
        console.log(JSON.stringify(scrapedData, null, 2));

        return scrapedData;

    } catch (error) {
        console.error('Scraping error:', error);
        process.exit(1);
    } finally {
        await browser.close();
    }
}

// スクリプト実行
if (require.main === module) {
    scrapeData().then(() => {
        console.log('Scraping completed successfully');
        process.exit(0);
    }).catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}

module.exports = { scrapeData };
