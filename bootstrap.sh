#!/usr/bin/env bash

export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")
touch ${SCRIPT_DIR}/vars.sh

# ASM バージョンの指定
grep -q "export ASM_VERSION.*" ${SCRIPT_DIR}/vars.sh || echo -e "export ASM_VERSION=1.12.0-asm.3" >> ${SCRIPT_DIR}/vars.sh

# Project ID
if [[ ! ${GCLOUD_PROJECT_ID} ]]; then
    echo "You have not defined your project ID in the GCLOUD_PROJECT_ID variable."
    exit 1
fi
grep -q "export GCLOUD_PROJECT_ID.*" ${SCRIPT_DIR}/vars.sh || echo -e "export GCLOUD_PROJECT_ID=${GCLOUD_PROJECT_ID}" >> ${SCRIPT_DIR}/vars.sh
grep -q "gcloud config set project.*" ${SCRIPT_DIR}/vars.sh || echo -e "gcloud config set project ${GCLOUD_PROJECT_ID}" >> ${SCRIPT_DIR}/vars.sh

# ユーザ
export ACCOUNT=`gcloud config list account --format=json | jq -r .core.account`
grep -q "export GCLOUD_USER.*" ${SCRIPT_DIR}/vars.sh || echo -e "export GCLOUD_USER=${ACCOUNT}" >> ${SCRIPT_DIR}/vars.sh
source ${SCRIPT_DIR}/vars.sh

# API の有効化
if [[ ! $API_ENABLED ]]; then
  echo "Enabling APIs..."
  gcloud services enable cloudresourcemanager.googleapis.com \
    cloudbilling.googleapis.com \
    iam.googleapis.com \
    compute.googleapis.com \
    container.googleapis.com \
    serviceusage.googleapis.com \
    sourcerepo.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    cloudtrace.googleapis.com \
    meshca.googleapis.com \
    meshtelemetry.googleapis.com \
    meshconfig.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    cloudbuild.googleapis.com \
    servicemanagement.googleapis.com \
    secretmanager.googleapis.com \
    anthos.googleapis.com \
    multiclusteringress.googleapis.com

  gcloud services enable \
    cloudkms.googleapis.com \
    anthosconfigmanagement.googleapis.com \
    multiclusterservicediscovery.googleapis.com \
    cloudresourcemanager.googleapis.com \
    connectgateway.googleapis.com \
    iamcredentials.googleapis.com
  echo -e "export API_ENABLED=true" >> ${SCRIPT_DIR}/vars.sh
fi

# tfstate を持つバケットの作成
if [[ $(gsutil ls | grep "gs://${GCLOUD_PROJECT_ID}-tfstate/") ]]; then
    echo "Bucket gs://${GCLOUD_PROJECT_ID}-tfstate already exists."
else    
    echo "Creating a GCS bucket for terraform shared states..."
    gsutil mb -p ${GCLOUD_PROJECT_ID} gs://${GCLOUD_PROJECT_ID}-tfstate
fi

if [[ $(gsutil versioning get gs://$GCLOUD_PROJECT_ID-tfstate | grep Enabled) ]]; then
    echo "Versioning already enabled on bucket gs://${GCLOUD_PROJECT_ID}-tfstate"
else
    echo "Enabling versioning on the GCS bucket..."
    gsutil versioning set on gs://${GCLOUD_PROJECT_ID}-tfstate
fi
