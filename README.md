# IaC for Cloud Run for Anthos

## インフラの構築

1. 環境変数をセットし、ログインします

  ```sh
  export GCLOUD_PROJECT_ID=
  gcloud auth login
  ```

2. Terraform の状態保存用にバケットを作ります

  ```sh
  ./infra/bootstrap.sh
  ```

3. dev 環境のベースを作ります

  ```sh
  cd ../environments/dev 
  terraform init -backend-config="bucket=${GCLOUD_PROJECT_ID}-tfstate"
  terraform plan -var "project_id=${GCLOUD_PROJECT_ID}"
  terraform apply -var "project_id=${GCLOUD_PROJECT_ID}" -auto-approve
  ```

## CI/CD セットアップ

1. サービスアカウントとその鍵を生成します

  ```sh
  gcloud iam service-accounts create terraform \
    --display-name "Terraform admin account"
  SA_EMAIL="$( gcloud iam service-accounts list \
    --filter 'email ~ terraform@.*'  --format='value(email)' )"
  gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT_ID}" \
    --member "serviceAccount:${SA_EMAIL}" \
    --role roles/editor
  gcloud iam service-accounts keys create terraform-creds.json \
    --iam-account "${SA_EMAIL}"
  ```

2. Circle CI の環境変数 `GOOGLE_CREDENTIALS` に以下の値を設定

  ```sh
  cat terraform-creds.json
  ```
