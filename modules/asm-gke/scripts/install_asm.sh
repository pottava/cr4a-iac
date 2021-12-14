#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Setup variables
IFS=',' read -r -a CLUSTER_NAMES <<< "${CLUSTERS_STRING}"
IFS=',' read -r -a CLUSTER_TYPES <<< "${REGIONAL_STRING}"
IFS=',' read -r -a CLUSTER_LOCS <<< "${LOCATIONS_STRING}"

# Extract Version
export _MINOR=$(echo ${ASM_VERSION} | cut -d "." -f 2)
export _POINT=$(echo ${ASM_VERSION} | cut -d "." -f 3 | cut -d "-" -f 1)
export _REV=$(echo ${ASM_VERSION} | cut -d "-" -f 2 | cut -d "." -f 2)

# pin to a specific installer - mcp installation inconsistencies
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.${_MINOR} > asmcli
chmod 755 asmcli

git clone -b ${ASM_BRANCH} https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages.git

for i in "${!CLUSTER_NAMES[@]}";
do
  # Set up envioronment
  gcloud config set project "${PROJECT_ID}"

  # Get GKE credentials
  CMD_ARG=$([ "${CLUSTER_TYPES[$i]}" = true ] && echo "--region" || echo "--zone")
  gcloud container clusters get-credentials "${CLUSTER_NAMES[$i]}" $CMD_ARG "${CLUSTER_LOCS[$i]}" --project ${PROJECT_ID}
  GKE_CTX=gke_${PROJECT_ID}_${CLUSTER_LOCS[$i]}_${CLUSTER_NAMES[$i]}

  # Install ASM
  # Pin ASM version
  POINT=${_POINT} REV=${_REV} ./asmcli \
    install \
    --managed \
    --option cni-managed \
    --project_id ${PROJECT_ID} \
    --fleet_id ${PROJECT_ID} \
    --cluster_location ${CLUSTER_LOCS[$i]} \
    --cluster_name ${CLUSTER_NAMES[$i]} \
    --ca mesh_ca \
    --verbose \
    --output_dir ${CLUSTER_NAMES[$i]} \
    --enable_all

  kubectl --context ${GKE_CTX} create ns istio-ingress-general --dry-run=client -o yaml > ${GKE_CTX}_ns.yaml
  kubectl --context ${GKE_CTX} apply -f ${GKE_CTX}_ns.yaml
  kubectl --context ${GKE_CTX} label ns istio-ingress-general istio.io/rev=asm-managed-rapid --overwrite
  kubectl --context ${GKE_CTX} apply -n istio-ingress-general -f anthos-service-mesh-packages/samples/gateways/istio-ingressgateway
done