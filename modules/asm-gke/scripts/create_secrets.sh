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


# Setup variables
IFS=',' read -r -a CLUSTER_NAMES <<< "${CLUSTERS_STRING}"
IFS=',' read -r -a CLUSTER_TYPES <<< "${REGIONAL_STRING}"
IFS=',' read -r -a CLUSTER_LOCS <<< "${LOCATIONS_STRING}"

export _MINOR=$(echo ${ASM_VERSION} | cut -d "." -f 2)
export _POINT=$(echo ${ASM_VERSION} | cut -d "." -f 3 | cut -d "-" -f 1)
export _REV=$(echo ${ASM_VERSION} | cut -d "-" -f 2 | cut -d "." -f 2)

# pin to a specific installer - mcp installation inconsistencies
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.${_MINOR} > asmcli
chmod 755 asmcli

POINT=${_POINT} REV=${_REV} ./asmcli create-mesh \
  ${PROJECT_ID} \
  ${PROJECT_ID}/${CLUSTER_LOCS[0]}/${CLUSTER_NAMES[0]} \
  ${PROJECT_ID}/${CLUSTER_LOCS[1]}/${CLUSTER_NAMES[1]}