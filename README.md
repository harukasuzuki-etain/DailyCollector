# Daily Collector

データ収集自動化ツール。毎日のデータ収集・集計作業を自動化し、Google スプレッドシートに保存します。

## 技術スタック

- **n8n**: ワークフロー自動化
- **Playwright**: Webスクレイピング
- **Docker**: コンテナ化
- **Google Sheets API**: データ保存

## セットアップ

### 開発環境（VS Code Devcontainer）

**推奨**: 一貫した開発環境のためにDevcontainerを使用してください。

1. VS Codeで本プロジェクトを開く
2. 右下の通知から「Reopen in Container」を選択
3. 初期化スクリプトが自動実行されます

```bash
# コンテナ内で追加の認証設定
gcloud auth login
gh auth login
```

### ローカル開発（手動セットアップ）

詳細な手順は `PROJECTPLAN.md` を参照してください。

### 前提条件

- Docker Desktop (WSL 2 対応)
- Node.js (LTS)
- Git
- Google Cloud Platform アカウント

### クイックスタート（開発環境）

```bash
# Devcontainer使用時は自動実行されます
docker-compose up -d
```

### VPS本番環境デプロイ

1. VPSにDocker、Docker Composeをインストール
2. リポジトリをクローン
3. 環境設定ファイルを作成

```bash
# 環境設定
cp .env.example .env
nano .env  # 設定を編集

# デプロイ実行
./deploy-vps.sh
```

4. http://your-vps-ip:5678 で n8n にアクセス

## 設定ファイル

- `docker-compose.yml`: 開発環境用Docker設定
- `docker-compose.prod.yml`: VPS本番環境用Docker設定
- `.devcontainer/`: VS Code Devcontainer設定
- `scraper/scrape.js`: スクレイピングロジック
- `scraper/Dockerfile`: スクレイパーコンテナ定義
- `deploy-vps.sh`: VPS自動デプロイスクリプト

## 環境

### 開発環境
- VS Code Devcontainer（推奨）
- または ローカルDocker環境

### 本番環境
- VPS（Ubuntu/CentOS推奨）
- Docker + Docker Compose
- 推奨スペック: 2GB RAM以上

## 注意事項

- 認証情報は環境変数で管理
- Google Cloud Platform の利用料金に注意
- 対象サイトの利用規約を遵守
