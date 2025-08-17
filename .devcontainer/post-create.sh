#!/bin/bash

# Devcontainer起動後の初期化スクリプト

echo "🚀 Daily Collector Devcontainer の初期設定を開始..."

# 作業ディレクトリに移動
cd /workspace

# Node.jsパッケージのインストール（scraperディレクトリ）
if [ -d "scraper" ]; then
    echo "📦 Scraperの依存関係をインストール中..."
    cd scraper
    npm install
    
    # Playwrightブラウザのインストール
    echo "🌐 Playwrightブラウザをインストール中..."
    npx playwright install
    cd ..
fi

# Gitの設定確認
if [ ! -f ~/.gitconfig ]; then
    echo "⚙️  Git設定を初期化..."
    git config --global user.name "Daily Collector Developer"
    git config --global user.email "developer@dailycollector.local"
    git config --global init.defaultBranch main
fi

# Docker Composeサービスの起動（Devcontainer内のn8n）
echo "🐳 Devcontainer内でn8nサービスを起動中..."
cd /workspace
docker-compose up -d

# サービスの起動確認
echo "🔍 サービス状態確認..."
docker-compose ps

# 環境情報の表示
echo ""
echo "✅ 開発環境の準備が完了しました！"
echo ""
echo "📋 利用可能なサービス:"
echo "   • n8n: http://localhost:5678"
echo "   • VS Code Devcontainer環境"
echo ""
echo "🛠️  利用可能なツール:"
echo "   • Node.js: $(node --version)"
echo "   • npm: $(npm --version)"
echo "   • Docker: $(docker --version)"
echo "   • Google Cloud CLI: $(gcloud --version | head -1)"
echo "   • GitHub CLI: $(gh --version | head -1)"
echo ""
echo "🔧 次のステップ:"
echo "   1. Google Cloud認証: gcloud auth login"
echo "   2. GitHub認証: gh auth login"
echo "   3. n8nワークフローの設定"
echo ""

# 権限設定
sudo chown -R vscode:vscode /workspace

echo "🎉 すべての設定が完了しました！"
