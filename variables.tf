variable "gcp_project_id" {
  type        = string
  description = "GCP project to provision infrastructure in"
}

variable "default_region" {
  type        = string
  description = "Default region all resources are put in"
}

variable "default_zone" {
  type        = string
  description = "Default zone all resources are put in"
}