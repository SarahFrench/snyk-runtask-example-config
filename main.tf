terraform {
  cloud {
    organization = "put-your-org-here"

    workspaces {
      name = "put-your-workspaces-here"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.default_region
  zone    = var.default_zone
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.default_region
  network       = google_compute_network.vpc_network.id
}

# This in particular makes the Synk RunTask angry
resource "google_compute_firewall" "allow_ssh_any_ip" {
  name    = "ssh-from-any-ip"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_service_account" "default" {
  account_id   = "gce-instance"
  display_name = "GCE Instance Service Account"
}

resource "google_compute_instance" "default" {
  name         = "terraform-test"
  machine_type = "e2-micro"

  tags = ["terraform"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.id

    access_config {
      // Leaving this blank allows an ephemeral public IP to be used
    }
  }

  metadata = {
    terraform = "true"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope here
    # and you grant permissions to the SA via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
