# ===================================================================
# Service account: email, name. unique_id
# ===================================================================

output "email" {
  value       = google_service_account.terraform_sa.email
  description = "The e-mail address of the service account"
}

output "name" {
  value       = google_service_account.terraform_sa.name
  description = "The fully-qualified name of the service account"
}

output "unique_id" {
  value       = google_service_account.terraform_sa.unique_id
  description = "The unique id of the service account"
}

# ===================================================================
# Private key
# ===================================================================

output "private_key" {
  value     = google_service_account_key.sa_key.private_key
  sensitive = true
}

output "decoded_private_key" {
  value     = base64decode(google_service_account_key.sa_key.private_key)
  sensitive = true
}

# ===================================================================
# SQL Instance
# ===================================================================

output "sql_instance_ip_address" {
  description = "The public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgresql_instance.ip_address
}