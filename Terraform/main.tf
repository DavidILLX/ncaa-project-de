terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~>5"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~>4"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "ncaa_project" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_storage_bucket" "dataproc_staging_bucket" {
  name          = var.staging_bucket
  location      = var.location
  force_destroy = true
}

resource "google_storage_bucket" "dataproc_temp_bucket" {
  name          = var.temp_bucket
  location      = var.location
  force_destroy = true
}

resource "google_bigquery_dataset" "ncaa_dataset" {
  dataset_id = var.bq_dataset_name
  project    = var.project
  location   = var.location
}

resource "google_compute_network" "my_vpc" {
  name                    = var.my_vpc
  auto_create_subnetworks = false

  depends_on = [google_project_service.enabled_apis]
}

resource "google_compute_subnetwork" "my_subnet" {
    name          = "my-subnet"
    ip_cidr_range = "10.10.0.0/24"
    network       = google_compute_network.my_vpc.self_link
    region        = var.region
}


resource "google_compute_instance" "virtual_machine_instance" {
  name             = var.vm_instance
  zone             = var.zone
  machine_type     = var.machine_type

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = 30
    }
  }
  network_interface {
    network = google_compute_network.my_vpc.self_link
    subnetwork = google_compute_subnetwork.my_subnet.self_link

    access_config {} 
  }

  # Adding the SSH key for connecting
  metadata = {
    ssh-keys       = "tomas:${file(var.ssh_public_key_path)}"
    enable-oslogin = "FALSE"
  }

  # Script for downloading anaconda for VM
  metadata_startup_script = file(var.startup_script_path)

  tags = ["web"]
}

# Adding firewall rule to support HTTPS comunication
resource "google_compute_firewall" "allow_https" {
  name    = "allow-ports"
  network = google_compute_network.my_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["443", "8080", "22"] #HTTPS, Kestra, SSH
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["web"]

  depends_on = [google_project_service.enabled_apis]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.my_vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  provider                = google-beta 
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
  depends_on              = [google_compute_network.my_vpc]
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range" 
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.my_vpc.self_link
}

resource "google_sql_database_instance" "postgresql_instance" {
  project             = var.project
  name                = var.db_instance_name
  region              = var.region
  database_version    = "POSTGRES_15" #Kestra does not run on v16 
  deletion_protection = false
  
  settings {
    tier      = var.db_tier
    edition   = var.db_edition
    disk_size = var.disk_size

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.my_vpc.self_link
    }

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }
  }
  depends_on = [
    google_service_account.terraform_sa, 
    google_service_networking_connection.private_vpc_connection,
    google_project_service.enabled_apis,
  ]
}

resource "google_sql_database" "my_database" {
  name     = var.kestra_db
  instance = google_sql_database_instance.postgresql_instance.name
}

resource "google_sql_user" "db_user" {
  name        = var.kestra_db_user
  instance    = google_sql_database_instance.postgresql_instance.name
  password    = var.kestra_db_pwd
}

resource "google_dataproc_cluster" "default" {
  project = var.project
  region  = var.region
  name    = var.cluster_name

  cluster_config {
    temp_bucket    = google_storage_bucket.dataproc_temp_bucket.name
    staging_bucket = google_storage_bucket.dataproc_staging_bucket.name

    gce_cluster_config {
      service_account = google_service_account.terraform_sa.email
      zone            = var.zone
    }
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"
    }
    worker_config { 
      num_instances = 2
      machine_type  = "n1-standard-2"
    }
  }
  depends_on = [
    google_service_account.terraform_sa, 
    google_project_service.enabled_apis,
    google_project_iam_member.dataproc_worker,
    google_project_iam_member.dataproc_editor,
    google_storage_bucket_iam_member.staging_bucket_admin,
    google_storage_bucket_iam_member.temp_bucket_admin,
  ]
}