# Google Cloud Platform 設定情報

## プロジェクト情報
- **プロジェクトID**: daily-collector-2025
- **プロジェクト名**: Daily Collector Project
- **アカウント**: haruka@etain.site

## 有効化されたAPI
- Google Sheets API
- Google Drive API

## サービスアカウント
- **名前**: daily-collector-service
- **メール**: daily-collector-service@daily-collector-2025.iam.gserviceaccount.com
- **権限**: Editor role

## 認証方法
- Application Default Credentials (ADC) を使用
- WSL環境で `gcloud auth application-default login` で認証済み

## 次の手順
1. Google スプレッドシートの作成
2. サービスアカウントにスプレッドシートの編集権限を付与
3. n8nでGoogle Sheets連携の設定

## 重要な注意事項
- 本番環境では最小権限の原則に従ってロールを調整してください
- 認証情報の管理には十分注意してください
