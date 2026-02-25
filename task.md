# Azure デプロイ・タスクリスト

このドキュメントは、現在のプロダクトを Azure 上で最適に運用するためのインフラ構築タスクをまとめたものです。

## 1. 準備フェーズ
- [ ] **Azure サブスクリプションの確認**: リソース作成権限の確認。
- [ ] **Terraform 実行環境のセットアップ**: 
  - [ ] `main.tf`, `variables.tf`, `outputs.tf` の作成。
  - [ ] Azure 認証（Azure CLI `az login`）の完了。
  - [ ] tfstate 管理用の Storage Account 作成（推奨）。

## 2. インフラ構築フェーズ (Terraform / IaC)
- [ ] **リソースグループの定義**: 関連リソースをまとめるグループを作成。
- [ ] **Azure Container Registry (ACR) の作成**: 
  - [ ] バックエンド Docker イメージ保存用。
- [ ] **Azure Database for PostgreSQL (Flexible Server) の作成**:
  - [ ] ネットワーク（VNet）の設定。
  - [ ] データベース名、管理者ユーザーの設定。
- [ ] **Azure Key Vault の作成**:
  - [ ] DB接続文字列、セッションシークレット等の機密情報保存用。
- [ ] **Azure Container Apps (ACA) の作成**:
  - [ ] コンテナアプリ環境の構築。
  - [ ] バックエンド実行用の定義（ポート 8080）。
  - [ ] マネージド ID の有効化（Key Vault 参照用）。
- [ ] **Azure Static Web Apps (SWA) の作成**:
  - [ ] フロントエンド配信用の定義。

## 3. バックエンド・デプロイ準備
- [ ] **GitHub Actions ワークワークフロー作成 (`.github/workflows/deploy-backend.yml`)**:
  - [ ] Docker ビルド & ACR へのプッシュ。
  - [ ] ACA への最新イメージのデプロイ。

## 4. フロントエンド・デプロイ準備
- [ ] **GitHub Actions ワークフロー作成 (`.github/workflows/deploy-frontend.yml`)**:
  - [ ] SWA へのビルド & デプロイ設定。

## 5. セキュリティ & 最適化
- [ ] **マネージド ID による認証**: ACR からのイメージプル権限を ACA に付与。
- [ ] **診断設定**: Azure Monitor / Log Analytics へのログ転送設定。
- [ ] **スケーリング設定**: ACA の最小レプリカ数を 0 または 1 に設定（コスト最適化）。

---

## 補足：具体的なセットアップ手順

### A. Azure 認証情報の作成
1. まず、権限の割り当て先となるリソースグループを作成します。
```bash
az group create --name rg-friends --location japaneast
```

2. GitHub Actions 用のサービスプリンシパルを作成します。
```bash
# YOUR_SUBSCRIPTION_ID を自身のものに置き換えて実行
az ad sp create-for-rbac --name "friends-app-deployer" --role contributor \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-friends" \
  --sdk-auth
```

### B. GitHub Secrets の登録
リポジトリの `Settings > Secrets and variables > Actions` に以下を登録してください。
- `AZURE_CREDENTIALS`: 上記コマンドで出力された JSON 全体
- `ACR_NAME`: `acrfriendsunique` (Terraformで定義した名前)
- `AZURE_STATIC_WEB_APPS_API_TOKEN`: SWA作成後にポータルから取得

### C. インフラ構築 (Terraform)
```bash
cd terraform
terraform init
terraform apply -var="db_admin_password=YourSecurePassword123yes"
```

### D. SWA と ACA のリンク (CORS回避)
インフラ構築・初回デプロイ後に実行します。
```bash
# ACA のリソース ID を取得
ACA_ID=$(az containerapp show --name friends-app-backend --resource-group rg-friends --query id -o tsv)

# SWA にリンク
az staticwebapp backends link --backend-resource-id $ACA_ID \
  --name friends-app-frontend \
  --resource-group rg-friends \
  --backend-region "Japan East"
```

---
## アーキテクチャ構成のポイント
- **CORS回避**: SWA のリンク機能（Backend APIs）を使うことで、フロントとバックを同一オリジンとして扱えるため、コード側の CORS 設定を弄る必要がありません。
- **秘密情報の分離**: `godotenv` に頼らず、Azure のプラットフォーム機能（Key Vault 参照）で環境変数を注入します。
