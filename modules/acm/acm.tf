
resource "google_gke_hub_membership" "membership" {
  provider      = google-beta
  project       = var.project_id
  membership_id = "membership-hub-${var.gke_cluster_name}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${var.gke_cluster_id}"
    }
  }
}

resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  name     = "configmanagement"
  project  = var.project_id
  location = "global"
  provider = google-beta
}

resource "google_gke_hub_feature_membership" "feature_member" {
  provider   = google-beta
  project    = var.project_id
  location   = "global"
  feature    = "configmanagement"
  membership = google_gke_hub_membership.membership.membership_id
  configmanagement {
    version = "1.11.1"
    config_sync {
      source_format = "unstructured"
      git {
        sync_repo = "https://${var.git_user}:GITHUB_TOKEN@github.com/${var.git_org}/${var.acm_repo}.git"
        sync_branch = var.env
        policy_dir  = "env/${var.env}"
        secret_type = "none"
      }
    }
    policy_controller {
      enabled = true
      template_library_installed = true
      referential_rules_enabled = true
    }
  }

  depends_on = [
    google_gke_hub_feature.configmanagement_acm_feature
  ]
}
