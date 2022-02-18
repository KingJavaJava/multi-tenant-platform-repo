resource "google_secret_manager_secret" "secret" {
  secret_id = var.secret_id
  replication {
    automatic = true
  }
  project = var.project_id
}

resource "google_secret_manager_secret_version" "secret-value" {
  provider = google
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret
}

resource "google_secret_manager_secret_iam_member" "secret-access-1" {
  provider = google

  secret_id = google_secret_manager_secret.secret.id
  role = "roles/secretmanager.secretAccessor"
  member =  format("%s:%s","group",var.group)
}

resource "google_secret_manager_secret_iam_member" "secret-access-2" {
  provider = google

  secret_id = google_secret_manager_secret.secret.id
  role = "roles/secretmanager.viewer"
  member = format("%s:%s","group",var.group)
}
