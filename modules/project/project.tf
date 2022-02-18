module "gcp-project" {
  source              = "terraform-google-modules/project-factory/google"
  version             = "10.1.0"
  random_project_id   = true
  billing_account     = var.billing_account
  name                = format("%s-%s",var.host_project_name,var.env)
  org_id              = var.org_id
  default_service_account = "keep"
  folder_id           = var.folder_id
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",

  ]
}
