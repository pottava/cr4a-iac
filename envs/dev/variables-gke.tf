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

variable "gke_subnet_name" {
  type    = string
  default = "asia-northeast1/dev-vpc-01-asia-northeast1-subnet-01"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "gke_suffix" {
  type    = number
  default = 1
}

variable "gke_zone" {
  type    = string
  default = "b"
}

variable "env" {
  type    = string
  default = "dev"
}
