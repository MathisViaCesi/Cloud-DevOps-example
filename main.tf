terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
 
provider "google" {
  project = var.project_id
  region  = var.region
}
 
variable "projet2-450809" {}
variable "region" { default = "europe-west1" }
 

resource "google_storage_bucket" "terraform_state" {
  name          = "${var.projet2-450809}-terraform-state"
  location      = "EU"
  force_destroy = true
  versioning {
    enabled = true
  }
}
 
#Création du VPC et sous-réseaux 
resource "google_compute_network" "vpc" {
  name                    = "vpc-app"
  auto_create_subnetworks = false
}
 
resource "google_compute_subnetwork" "subnet_app" {
  name          = "subnet-app"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
}
 
resource "google_compute_subnetwork" "subnet_lb" {
  name          = "subnet-lb"
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "LOAD_BALANCER"
}
 
# Création d’un Instance Template pour MIG
resource "google_compute_instance_template" "app_template" {
  name         = "instance-template"
  machine_type = "e2-medium"
  disk {
    source_image = "mon-image-packer"
    auto_delete  = true
  }
  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet_app.id
  }
}
 
resource "google_compute_region_instance_group_manager" "mig" {
  name               = "mig-app"
  base_instance_name = "app-instance"
  region             = var.region
  version {
    instance_template = google_compute_instance_template.app_template.id
  }
}
 
# Configuration du Load Balance
resource "google_compute_backend_service" "backend" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.default.id]
}
 
resource "google_compute_url_map" "lb_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend.id
}
 
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.lb_map.id
}
 
resource "google_compute_global_forwarding_rule" "http_rule" {
  name                  = "http-rule"
  target                = google_compute_target_http_proxy.http_proxy.id
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
}
 
# Monitoring Cloud

                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
  EOF
}
