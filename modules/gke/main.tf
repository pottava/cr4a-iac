/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# GKE
locals {
  # The following locals are derived from the subnet object
  node_subnet = var.subnet.name
  pod_subnet  = var.subnet.secondary_ip_range[0].range_name
  svc_subnet  = var.subnet.secondary_ip_range[local.suffix].range_name
  region      = var.subnet.region
  network     = split("/", var.subnet.network)[length(split("/", var.subnet.network)) - 1]
  project     = var.subnet.project
  suffix      = var.suffix
  env         = var.env
  zone        = var.zone
}

data "google_project" "project" {
  project_id = var.subnet.project
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "17.3.0"
  
  project_id              = local.project
  name                    = "gke-${local.env}-${local.region}${local.zone}-${local.suffix}"
  regional                = false
  region                  = local.region
  zones                   = ["${local.region}-${local.zone}"]
  release_channel         = "REGULAR"
  network                 = local.network
  subnetwork              = local.node_subnet
  ip_range_pods           = local.pod_subnet
  ip_range_services       = local.svc_subnet
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false
  cluster_resource_labels    = { "mesh_id" : "proj-${data.google_project.project.number}", "environ" : "${local.env}", "infra" : "gcp" }
  node_pools = [
    {
      name         = "node-pool-01"
      autoscaling  = false
      auto_upgrade = true
      auto_repair  = true
      node_count   = 2
      min_count    = 1
      max_count    = 100
      machine_type = "e2-standard-4"
      image_type   = "COS"
      local_ssd_count = 0
      disk_size_gb    = 100
      disk_type       = "pd-standard"
    },
  ]
}

# module "hub" {
#   source  = "terraform-google-modules/kubernetes-engine/google"
#   version = "17.3.0"

#   project_id              = local.project
#   name                    = "gke-${local.env}-${local.region}${local.zone}-${local.suffix}"
#   network                 = local.network
#   subnetwork              = local.node_subnet
#   ip_range_pods           = local.pod_subnet
#   ip_range_services       = local.svc_subnet
# }
