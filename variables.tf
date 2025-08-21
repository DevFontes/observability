# OCI Configuration for ESO
variable "oci_region" {
  description = "OCI Region"
  type        = string
}

variable "oci_vault_ocid" {
  description = "OCI Vault OCID"
  type        = string
}

variable "oci_user_ocid" {
  description = "OCI User OCID"
  type        = string
}

variable "oci_tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

# Thanos S3 Configuration (non-sensitive)
variable "thanos_s3_endpoint" {
  description = "Wasabi S3 Endpoint"
  type        = string
  default     = "s3.ca-central-1.wasabisys.com"
}

variable "thanos_s3_region" {
  description = "Wasabi S3 Region"
  type        = string
  default     = "ca-central-1"
}

variable "thanos_metrics_bucket" {
  description = "S3 bucket for Thanos metrics"
  type        = string
  default     = "k3s-thanos-metrics"
}

variable "thanos_ruler_bucket" {
  description = "S3 bucket for Thanos ruler"
  type        = string
  default     = "k3s-thanos-ruler"
}