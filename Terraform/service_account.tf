# Setting up the service accounts
resource "google_service_account" "terraform_sa" {
  project      = var.project
  account_id   = var.account
  display_name = var.description

}

resource "google_project_iam_member" "sa_iam" {
  for_each = toset(var.roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_service_account_key" "sa_key" {
  service_account_id = google_service_account.terraform_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Creates JSON file with credentials for the GCS
resource "local_file" "sa_key_json" {
  content  = base64decode(google_service_account_key.sa_key.private_key)
  filename = "${path.module}/gcp_credentials.json"
}

# Adding Resource level roles
resource "google_project_iam_binding" "cloud_sql_user" {
  project = var.project
  role    = "roles/cloudsql.instanceUser"
  members = ["serviceAccount:${google_service_account.terraform_sa.email}"]
}

resource "google_project_iam_binding" "cloud_sql_client" {
  project = var.project
  role    = "roles/cloudsql.client"
  members = ["serviceAccount:${google_service_account.terraform_sa.email}"]
}

resource "google_project_iam_member" "dataproc_worker" {
  project  = var.project
  role     = "roles/dataproc.worker"
  member   = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_project_iam_member" "dataproc_editor" {
  project    = var.project
  role       = "roles/dataproc.editor"
  member     = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Adding specific role to bucket 
# These roles are bucket specific not account specific
resource "google_project_iam_binding" "storage_admin" {
  project = var.project
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.terraform_sa.email}"]
}

resource "google_storage_bucket_iam_member" "staging_bucket_admin" {
  bucket = google_storage_bucket.dataproc_staging_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_storage_bucket_iam_member" "temp_bucket_admin" {
  bucket = google_storage_bucket.dataproc_temp_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
}