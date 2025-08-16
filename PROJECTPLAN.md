# Daily Collector — 開発プラン (Windows ローカル構築)

このドキュメントは、データ収集自動化ツール「Daily Collector」をWindowsローカルで Docker を利用して構築するための開発プランです。

## 概要

- 目的: 毎日手作業で行っている部署のデータ収集・集計作業を自動化し、Google スプレッドシートに自動保存する。
- 名称: Daily Collector
- 技術スタック: n8n, Playwright, Docker, Node.js, Git, Google Cloud Platform (GCP) API
- 実行環境: Windows + Docker Desktop（WSL 2 推奨）
- データ出力先: Google スプレッドシート

## 前提・必須ソフトウェア

ローカルPC に次のソフトウェアをインストールしてください。

| ソフトウェア | 目的 | 備考 |
|---|---|---|
| WSL 2 | Windows 上で Linux 環境を動かすための基盤。Docker Desktop のパフォーマンス向上に必須 | PowerShell: `wsl --install` を参照 |
| Docker Desktop | n8n やスクレイパーをコンテナで実行 | WSL 2 バックエンドを利用する設定にしてください |
| Visual Studio Code | コード編集 | — |
| Git | バージョン管理 | — |
| Node.js (LTS) | スクレイピングスクリプトのローカル実行・テスト | — |

## リポジトリ構成（例）

```
daily-collector/
├── .gitignore            # 管理対象外の設定
├── docker-compose.yml    # n8n とサービス定義
├── n8n-data/             # n8n の永続化データ（Git 管理外）
│   └── .keep
├── scraper/              # スクレイパー関連
│   ├── .dockerignore
│   ├── Dockerfile
│   ├── package.json
│   └── scrape.js
└── README.md
```

## 開発手順（フェーズ別）

### フェーズ1: 環境構築とプロジェクト初期化

1. 必要ソフトウェアをインストール（上記参照）。
2. プロジェクトフォルダを作成し、VS Code で開く。
3. Git リポジトリ初期化: `git init`。
4. ディレクトリ・初期ファイルを作成（`scraper/`, `n8n-data/`, `README.md` など）。
5. ルートに `.gitignore` を作成（例）：

```gitignore
# Node.js
node_modules/

# n8n
n8n-data/

# OS
.DS_Store

# 環境変数ファイル
.env
```

### フェーズ2: Google Cloud Platform (GCP) セットアップ

1. **Google Cloud プロジェクト作成**:
   - [Google Cloud Console](https://console.cloud.google.com/) にアクセス
   - 新しいプロジェクトを作成（例: `daily-collector-project`）

2. **Google Sheets API の有効化**:
   - プロジェクトで「APIs & Services」→「Library」を選択
   - 「Google Sheets API」を検索し、有効化
   - 「Google Drive API」も有効化（ファイルアクセスに必要）

3. **サービスアカウント作成**:
   - 「APIs & Services」→「Credentials」を選択
   - 「CREATE CREDENTIALS」→「Service account」を選択
   - サービスアカウント名を入力（例: `daily-collector-service`）
   - ロールに「Google Sheets API」の最小権限を設定

4. **認証方法の設定（推奨: Workload Identity）**:
   - **ローカル開発環境**: `gcloud auth application-default login` を使用
   - **本番環境**: Workload Identity または環境変数 `GOOGLE_APPLICATION_CREDENTIALS` 
   - JSON キーファイルは可能な限り避け、代替手段を利用

5. **Google スプレッドシート準備**:
   - 新しいスプレッドシートを作成
   - サービスアカウントのメールアドレス（JSON内の `client_email`）に「編集者」権限を付与
   - スプレッドシートIDをメモ（URL中の長い文字列）

### フェーズ3: スクレイパーの開発と Docker 化

1. `scraper` ディレクトリへ移動し、Node.js プロジェクト初期化: `npm init -y`。
2. Playwright をインストール: `npm install playwright`。
3. `scrape.js` を作成して、ログイン→データ取得→JSON 出力 のロジックを実装。
   - まずローカルで `node scrape.js` を実行して動作確認。
4. `Dockerfile`（例）:

```dockerfile
FROM mcr.microsoft.com/playwright:v1.45.0-jammy
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD [ "node", "scrape.js" ]
```

5. イメージビルド確認: `docker build -t daily-collector-scraper .` を実行。

### フェーズ4: n8n のセットアップと起動

1. ルートに `docker-compose.yml` を作成（n8n + Google Cloud SDK を含む設定）：

```yaml
version: '3.7'
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    volumes:
      - ./n8n-data:/home/node/.n8n
    environment:
      - GENERIC_TIMEZONE=Asia/Tokyo
      - GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-credentials.json
    # ローカル開発用: gcloud auth application-default login の結果を使用
```

2. 起動: `docker-compose up -d`。
3. ブラウザで `http://localhost:5678` にアクセスし、n8n の初期設定を行う。

### フェーズ5: n8n とスクレイパー、Google Sheets の連携

### フェーズ5: n8n とスクレイパー、Google Sheets の連携

1. **n8n ワークフロー作成**:
   - Manual トリガー（または Cron トリガー）を配置
   - `Execute Command` ノードでスクレイパーを実行
   - `JSON Parse` ノードでスクレイパーの出力を解析
   - `Google Sheets` ノードでデータをスプレッドシートに追記

2. **Google Sheets ノードの設定**:
   - n8n の「Credentials」で Google Service Account を設定
   - 認証情報に先ほど作成したサービスアカウントの JSON を使用
   - スプレッドシートIDとシート名を指定
   - 操作を「Append」に設定してデータを追記

3. **スクレイパー実行の設定**:
   - 例: `docker run --rm --network host -e LOGIN_URL="..." -e SCRAPE_USERNAME="..." -e SCRAPE_PASSWORD="..." daily-collector-scraper`
   - 注意: Windows の Docker Desktop 環境では `--network host` や `/var/run/docker.sock` のマウントが扱いにくいため、問題があれば同一 Docker ネットワーク内でサービスを構成する方法に切り替えてください。

4. **データフロー確認**:
   - ワークフローを実行し、Execute Command ノードの出力（stdout）にスクレイパーから取得したJSONデータが表示されることを確認
   - JSON Parse ノードでデータが正しく解析されることを確認
   - Google Sheets ノードでスプレッドシートにデータが正しく追記されることを確認

5. **データ整形（必要に応じて）**:
   - `Set` ノードや `Function` ノードを使用してデータを整形
   - 日付、タイムスタンプの追加
   - 不要なフィールドの除去

### フェーズ6: バージョン管理とデプロイ準備

1. 動作確認ごとにコミット:

```powershell
git add .; git commit -m "feat: n8nとスクレイパーの連携を実装"
```

2. GitHub にリポジトリを作成し、リモート登録・push:

```powershell
git remote add origin <GitHubリポジトリのURL>;
git branch -M main;
git push -u origin main
```

## Google Sheets 連携の詳細設定

### n8n での Google Sheets 認証設定

1. **Credentials 作成**:
   - n8n 管理画面で「Settings」→「Credentials」を選択
   - 「Add Credential」→「Google Service Account」を選択
   - **推奨**: Application Default Credentials を使用
   - または環境変数 `GOOGLE_APPLICATION_CREDENTIALS` でサービスアカウントキーのパスを指定

2. **Google Sheets ノードの設定項目**:
   - **Authentication**: 作成した Google Service Account を選択
   - **Operation**: `Append` （データ追記）
   - **Spreadsheet ID**: Google スプレッドシートのID
   - **Sheet**: シート名（通常は「Sheet1」）
   - **Data**: スクレイパーから取得したJSONデータ

3. **データマッピング例**:
```json
[
  {
    "日付": "{{ $json.date }}",
    "項目A": "{{ $json.itemA }}",
    "項目B": "{{ $json.itemB }}",
    "取得時刻": "{{ $now }}"
  }
]
```

### スプレッドシートの列構成例

| A列 | B列 | C列 | D列 |
|-----|-----|-----|-----|
| 日付 | 項目A | 項目B | 取得時刻 |
| 2025/08/17 | データ1 | データ2 | 2025/08/17 10:30:00 |

## 本番移行（次のステップ）

ローカルでの安定稼働を確認後、VPS など本番環境へ移行を検討します。主な手順:

- VPS の契約と初期設定（SSH、ファイアウォール）
- Docker / Docker Compose のインストール
- GitHub からクローン、`.env` による本番用環境変数の管理
- GCP サービスアカウントキーの安全な配置
- `docker-compose up -d` で本番起動
- n8n の Cron ノード等でスケジューリング設定

## 注意事項

- Windows 環境特有の制約（`/var/run/docker.sock` のマウント、`--network host` の扱いなど）があるため、Docker Desktop（WSL 2）での動作確認を推奨します。
- 機密情報（GCP認証情報、ログイン情報など）は直接コマンドやリポジトリに書かず、環境変数や n8n の Credentials、`.env` を利用してください。
- Google Cloud Platform の使用量に応じて課金が発生する可能性があります。Google Sheets API は通常の使用範囲では無料ですが、上限を確認してください。
- サービスアカウントの権限は本番環境では最小限に設定し、定期的にローテーションすることを推奨します。

## セキュリティ考慮事項

- JSON キーファイルの使用は避け、Application Default Credentials または Workload Identity を使用
- 本番環境では環境変数やシークレット管理サービスを使用
- スプレッドシートの共有設定を適切に管理
- 定期的なアクセスログの確認
- サービスアカウントには最小限の権限のみを付与