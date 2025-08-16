FROM mcr.microsoft.com/playwright:v1.45.0-jammy

# 作業ディレクトリの設定
WORKDIR /app

# package.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 依存関係のインストール
RUN npm ci --only=production

# アプリケーションファイルをコピー
COPY . .

# 実行ユーザーの設定（セキュリティ強化）
USER pwuser

# コンテナ起動時のコマンド
CMD ["node", "scrape.js"]
