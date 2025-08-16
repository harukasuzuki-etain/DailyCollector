# Daily Collector

データ収集自動化ツール。毎日のデータ収集・集計作業を自動化し、Google スプレッドシートに保存します。

## 技術スタック

- **n8n**: ワークフロー自動化
- **Playwright**: Webスクレイピング
- **Docker**: コンテナ化
- **Google Sheets API**: データ保存

## セットアップ

詳細な手順は `PROJECTPLAN.md` を参照してください。

### 前提条件

- Docker Desktop (WSL 2 対応)
- Node.js (LTS)
- Git
- Google Cloud Platform アカウント

### クイックスタート

1. リポジトリのクローン
2. Google Cloud Platform の設定
3. Docker Compose で起動

```bash
docker-compose up -d
```

4. http://localhost:5678 で n8n にアクセス

## 設定ファイル

- `docker-compose.yml`: Docker サービス定義
- `scraper/scrape.js`: スクレイピングロジック
- `scraper/Dockerfile`: スクレイパーコンテナ定義

## 注意事項

- 認証情報は環境変数で管理
- Google Cloud Platform の利用料金に注意
- 対象サイトの利用規約を遵守
