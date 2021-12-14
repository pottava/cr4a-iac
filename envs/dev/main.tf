module "dev_vpc_01" {
  source       = "../../modules/vpc/"
  project_id   = var.project_id
  network_name = var.network_name
  subnets      = var.subnets
}

# create firewall rules to allow-all inernally and SSH from external
module "dev_net_firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = module.dev_vpc_01.project_id
  network                 = module.dev_vpc_01.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/8"]
  internal_allow = [
    { "protocol" : "all" },
  ]
}

module "gke_dev" {
  source = "../../modules/gke/"
  subnet = module.dev_vpc_01.subnets["${var.gke_subnet_name}"]
  suffix = var.gke_suffix
  zone   = var.gke_zone
  env    = var.env
}

# module "dev-asm" {
#   source         = "../../modules/asm-gke/"
#   project_id     = var.project_id
#   clusters       = {
#     "${module.gke_dev.name}" = {
#       name     = "${module.gke_dev.name}"
#       location = "${module.gke_dev.location}"
#       endpoint = "${module.gke_dev.endpoint}"
#       asm_dir  = "${module.gke_dev.name}"
#       regional = false
#     }
#   }
#   asm_properties = var.asm_properties
# }

# module "dev_bucket" {
#   source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
#   version = "~> 1.3"

#   name       = "${var.project_id}-${var.env}"
#   project_id = var.project_id
#   location   = var.region
# }

# module "dev_spanner" {
# }

# module "dev_pubsub" {
# }

# module "dev_eventarc" {
# }

# module "dev_schedular" {
# }
