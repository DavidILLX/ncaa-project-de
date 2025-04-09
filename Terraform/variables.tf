# Setting necessary variables for the project


/*
variable "credentials" {
  description = "Google credentials for Terraform"
  default     = $GOOGLE_APPLICATION_CREDENTIALS
  sensitive   = true
}
*/

variable "gcp_service_list" {
  type        = list(string)
  description = "The list of APIs necessary for the project"
  default     = [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "dataproc.googleapis.com",
    "servicenetworking.googleapis.com",
    # Add whichever API is necessary
  ]
}

variable "roles" {
  type        = list(string)
  description = "The roles that will be granted to the service account."
  default     = [
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/compute.admin",
    "roles/editor",
    "roles/logging.admin",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    # Add whichever role is necessary
  ]
}

variable "account" {
  description = "The service account ID"
  default     = "project-sa"
}

variable "description" {
  description = "The display name for the service account"
  default     = "managed-by-terraform"
}

variable "my_vpc" {
  description = "Name of the VPC network"
  default     = "my-private-vpc"
}

variable "project" {
  description = "Project"
  default     = "ncaa-project-455709" # TODO Rename based on the project ID from google cloud console
}

variable "project_name" {
  description = "Project name for creation"
  default     = "ncaa project"
}

variable "region" {
  description = "region"
  default     = "europe-west2"
}

variable "location" {
  description = "Project location"
  default     = "EU"
}

variable "zone" {
  description = "Specific zone in the region"
  default     = "europe-west2-a"
}

variable "bq_dataset_name" {
  description = "My Big Query Dataset Name"
  default     = "ncaa_dataset"
}

variable "gcs_bucket_name" {
  description = "My storage bucket name"
  default     = "ncaa-bucket-dump"
}

variable "gcs_bucket_kestra_name" {
  description = "My storage bucket name"
  default     = "kestra-bucket-dump"
}

variable "staging_bucket" {
  description = "Staging bucket for cluster"
  default     = "staging-ncaa-bucket-dump"
}

variable "temp_bucket" {
  description = "Temporary bucket for cluster"
  default     = "temp-ncaa-bucket-dump"
}

variable "gcs_storage_class" {
  description = "Bucket storage class"
  default     = "Standard"
}

variable "vm_instance" {
  description = "Name of the virtual machine"
  default     = "vm-instance-1"
}

variable "machine_type" {
  description = "Type of virtual machine" # e2-standard-4 (4 vCPUs, 16 GB Memory)
  default     = "e2-standard-4"
}

# TO DO Adjust default as needed
variable "ssh_public_key_path" {
  type        = string
  description = "Path to the created SSH key"
  default     = "C:/Users/tomas/.ssh/gpc.pub"
}

variable "startup_script_path" {
  type        = string
  description = "Path to the startup script"
  default     = "startup-script.sh"
}

variable "os_image" {
  description = "OS image used in the VM"
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "db_instance_name" {
  description = "Name of the database instance"
  default     = "kestra"
}

variable "db_tier" {
  description = "Tier of Enterprise plus database which will be used"
  default     = "db-perf-optimized-N-2" # 2vCPUs, 16GB, 375GB SSD
}

variable "db_edition" {
  description = "Edition of the Database"
  default     = "ENTERPRISE_PLUS"
}

variable "disk_size" {
  description = "Size of the DB storage"
  default     = "350"
}

variable "kestra_db" {
  description = "Name of the kestra PostgreSQL database"
  default     = "kestra-database"
}

variable "kestra_db_user" {
  description = "Name of the database user"
  default     = "kestra"
}

variable "kestra_db_pwd" {
  description = "Pasword for kestra database"
  default     = "k3str4"
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the cluster"
  default     = "spark-cluster"
}
