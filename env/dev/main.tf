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


locals {
  description = [for item in module.create-vpc.network.subnets : item.description]
  gateway_address = [for item in module.create-vpc.network.subnets : item.gateway_address]
  id = [for item in module.create-vpc.network.subnets : item.id]
  ip_cidr_range = [for item in module.create-vpc.network.subnets : item.ip_cidr_range]
  name = [for item in module.create-vpc.network.subnets : item.name]
  network = [for item in module.create-vpc.network.subnets : item.network]
  private_ip_google_access = [for item in module.create-vpc.network.subnets : item.private_ip_google_access]
  project = [for item in module.create-vpc.network.subnets : item.project]
  region = [for item in module.create-vpc.network.subnets : item.region]
  secondary_ip_range =  [for item in module.create-vpc.network.subnets : [ for i in item.secondary_ip_range : { ip_cidr_range =  i.ip_cidr_range  , range_name =  i.range_name } ] ]
  self_link = [for item in module.create-vpc.network.subnets : item.self_link]
  subnet1 = {description = local.description[0] , gateway_address = local.gateway_address[0], id = local.id[0] ,ip_cidr_range = local.ip_cidr_range[0], name = local.name[0] , network = local.network[0] , private_ip_google_access = local.private_ip_google_access[0] , project = local.project[0] , region = local.region[0] , self_link = local.self_link[0] , secondary_ip_range = local.secondary_ip_range[0]  }
  subnet2 = {description = local.description[1] , gateway_address = local.gateway_address[1], id = local.id[1] ,ip_cidr_range = local.ip_cidr_range[1], name = local.name[1] , network = local.network[1] , private_ip_google_access = local.private_ip_google_access[1] , project = local.project[1] , region = local.region[1] , self_link = local.self_link[1] , secondary_ip_range = local.secondary_ip_range[1]  }
  gke_cluster_id = format("projects/%s/locations/%s/clusters/%s",module.create-gcp-project.project.project_id,module.create_gke_1.cluster_name.location,module.create_gke_1.cluster_name.name)
}


module "create-gcp-project" {
  source = "../../modules/project/"
  host_project_name = var.host_project_name
  billing_account = var.billing_account
  org_id = var.org_id
  folder_id = var.folder_id
  env = var.env
}


module "create-vpc" {
  source = "../../modules/vpc/"
  //project_id = module.create-gcp-project.project_id
  project_id   = module.create-gcp-project.project.project_id
  network_name    = var.network_name
  routing_mode    = var.routing_mode
  //shared_vpc_host = true
  subnet_01_name      = var.subnet_01_name
  subnet_01_ip        = var.subnet_01_ip
  subnet_01_region    = var.subnet_01_region
  subnet_01_description      = var.subnet_01_description
  subnet_02_name      = var.subnet_02_name
  subnet_02_ip        = var.subnet_02_ip
  subnet_02_region    = var.subnet_02_region
  subnet_02_description      = var.subnet_02_description
  subnet_01_secondary_svc_1_name    = var.subnet_01_secondary_svc_1_name
  subnet_01_secondary_svc_1_range = var.subnet_01_secondary_svc_1_range
  subnet_01_secondary_svc_2_name    = var.subnet_01_secondary_svc_2_name
  subnet_01_secondary_svc_2_range = var.subnet_01_secondary_svc_2_range
  subnet_01_secondary_pod_name    = var.subnet_01_secondary_pod_name
  subnet_01_secondary_pod_range = var.subnet_01_secondary_pod_range
  subnet_02_secondary_svc_1_name    = var.subnet_02_secondary_svc_1_name
  subnet_02_secondary_svc_1_range = var.subnet_02_secondary_svc_1_range
  subnet_02_secondary_svc_2_name    = var.subnet_02_secondary_svc_2_name
  subnet_02_secondary_svc_2_range = var.subnet_02_secondary_svc_2_range
  subnet_02_secondary_pod_name    = var.subnet_02_secondary_pod_name
  subnet_02_secondary_pod_range = var.subnet_02_secondary_pod_range

}

# Create GKE zonal cluster in platform_admin project using subnet-01 zone a
module "create_gke_1" {
  source            = "../../modules/gke/"
  subnet            = local.subnet1
  project_id        = module.create-gcp-project.project.project_id
  suffix            = "1"
  zone              = ["a","b","f"]
  env               = var.env
  project_number    = module.create-gcp-project.project.project_number
  depends_on        = [ module.create-vpc ]
}

module "secret-gke-name" {
  source            = "../../modules/secrets/"
  //secret            = module.create_gke_1.name.name
  secret            =  local.gke_cluster_id
  secret_id         = "${var.env}-gke-cluster-1"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-gke-sa" {
  source            = "../../modules/secrets/"
  secret            =  module.create_gke_1.cluster_name.service_account
  secret_id         = "${var.env}-gke-sa"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-github-user" {
  source            = "../../modules/secrets/"
  secret            =  var.github_user
  secret_id         = "github-user"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-github-email" {
  source            = "../../modules/secrets/"
  secret            =  var.github_email
  secret_id         = "github-email"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-billing-account" {
  source            = "../../modules/secrets/"
  secret            =  var.billing_account
  secret_id         = "gcp-billingac"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-github-org" {
  source            = "../../modules/secrets/"
  secret            =  var.github_org
  secret_id         = "github-org"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-gcp-org" {
  source            = "../../modules/secrets/"
  secret            =  var.org_id
  secret_id         = "gcp-org"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-gcp-folder" {
  source            = "../../modules/secrets/"
  secret            =  var.folder_id
  secret_id         = "gcp-folder"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-group-id" {
  source            = "../../modules/secrets/"
  secret            =  var.group_id
  secret_id         = "group-id"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-infra-project-id" {
  source            = "../../modules/secrets/"
  secret            =  var.project_id
  secret_id         = "infra-project-id"
  project_id        =  var.project_id
  group             =  var.group
}
