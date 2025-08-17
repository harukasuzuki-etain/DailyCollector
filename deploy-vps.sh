#!/bin/bash

# Daily Collector VPS デプロイスクリプト

set -e

echo "🚀 Daily Collector VPSデプロイを開始..."

# 設定確認
if [ ! -f ".env" ]; then
    echo "❌ .envファイルが見つかりません"
    echo "💡 .env.exampleをコピーして.envを作成し、設定を行ってください"
    echo "   cp .env.example .env"
    echo "   nano .env"
    exit 1
fi

# Docker環境確認
if ! command -v docker &> /dev/null; then
    echo "❌ Dockerがインストールされていません"
    echo "💡 Dockerをインストールしてください: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Composeがインストールされていません"
    echo "💡 Docker Composeをインストールしてください"
    exit 1
fi

# 必要なディレクトリを作成
echo "📁 ディレクトリ構造を確認中..."
mkdir -p n8n-data
mkdir -p logs
mkdir -p nginx/ssl

# n8n-dataの権限設定
sudo chown -R 1000:1000 n8n-data

# 既存のコンテナを停止
echo "🛑 既存のサービスを停止中..."
docker-compose -f docker-compose.prod.yml down

# イメージの最新化
echo "📦 Dockerイメージを更新中..."
docker-compose -f docker-compose.prod.yml pull

# スクレイパーイメージのビルド
echo "🔨 スクレイパーイメージをビルド中..."
docker-compose -f docker-compose.prod.yml build scraper

# サービス起動
echo "🐳 サービスを起動中..."
docker-compose -f docker-compose.prod.yml up -d

# 起動確認
echo "⏳ サービスの起動を待機中..."
sleep 30

# ヘルスチェック
echo "🔍 サービス状態を確認中..."
docker-compose -f docker-compose.prod.yml ps

# n8nの起動確認
if curl -f http://localhost:5678/healthz &> /dev/null; then
    echo "✅ n8nが正常に起動しました"
else
    echo "⚠️  n8nの起動に時間がかかっています。しばらく待ってから確認してください"
fi

echo ""
echo "🎉 デプロイが完了しました！"
echo ""
echo "📋 サービス情報:"
echo "   • n8n: http://$(hostname -I | awk '{print $1}'):5678"
echo "   • ログ確認: docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🔧 次のステップ:"
echo "   1. ブラウザでn8nにアクセス"
echo "   2. 初期設定とワークフロー作成"
echo "   3. Google Cloud認証の設定"
echo ""

# ログ監視オプション
read -p "ログを監視しますか？ (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose -f docker-compose.prod.yml logs -f
fi
