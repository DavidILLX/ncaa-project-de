# Enabling neccesary APIs for the project and destroing it on terraform destroy
# serviceusage.googleapis.com, iam.googleapis.com are automatically on

resource "google_project_service" "enabled_apis" {
  project  = var.project
  for_each = toset(var.gcp_service_list)
  service  = each.key

  disable_on_destroy = false
  
  lifecycle {
    create_before_destroy = true
  }
}