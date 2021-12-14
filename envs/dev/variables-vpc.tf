# VPC
variable "network_name" {
  type    = string
  default = "dev-vpc-01"
}
variable "subnets" {
  default = [
    {
      subnet_name   = "dev-vpc-01-asia-northeast1-subnet-01"
      subnet_ip     = "10.4.0.0/22"
      subnet_region = "asia-northeast1"
      secondary_ranges = [
        {
          range_name    = "dev-vpc-01-asia-northeast1-subnet-01-secondary-range-01-pod"
          ip_cidr_range = "10.0.0.0/14"
        },
        {
          range_name    = "dev-vpc-01-asia-northeast1-subnet-01-secondary-range-02-svc"
          ip_cidr_range = "10.5.0.0/20"
        },
        {
          range_name    = "dev-vpc-01-asia-northeast1-subnet-01-secondary-range-03-svc"
          ip_cidr_range = "10.5.16.0/20"
        },
        {
          range_name    = "dev-vpc-01-asia-northeast1-subnet-01-secondary-range-04-svc"
          ip_cidr_range = "10.5.32.0/20"
        },
        {
          range_name    = "dev-vpc-01-asia-northeast1-subnet-01-secondary-range-05-svc"
          ip_cidr_range = "10.5.48.0/20"
        },
      ]
    },
  ]
}
