# External Secrets Configuration for Observability Stack

# Add ESO label to monitoring namespace for secret reflection
resource "kubernetes_labels" "monitoring_namespace_labels" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "monitoring"
  }
  labels = {
    "eso-enabled" = "monitoring"
  }
  force = true
}

# OCI SecretStore for monitoring namespace
resource "kubectl_manifest" "oci_secret_store_monitoring" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = "oci-vault"
      namespace = "monitoring"
    }
    spec = {
      provider = {
        oracle = {
          region        = var.oci_region
          vault         = var.oci_vault_ocid
          principalType = "UserPrincipal"
          auth = {
            user    = var.oci_user_ocid
            tenancy = var.oci_tenancy_ocid
            secretRef = {
              privatekey = {
                name = "oracle-secret"
                key  = "privateKey"
              }
              fingerprint = {
                name = "oracle-secret"
                key  = "fingerprint"
              }
            }
          }
        }
      }
    }
  })

  depends_on = [
    kubernetes_labels.monitoring_namespace_labels
  ]
}

# External Secret for Thanos Object Store Configuration
resource "kubectl_manifest" "thanos_objstore_external_secret" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "thanos-objstore-config"
      namespace = "monitoring"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = kubectl_manifest.oci_secret_store_monitoring.name
        kind = "SecretStore"
      }
      target = {
        name           = "thanos-objstore-config"
        creationPolicy = "Owner"
        template = {
          type = "Opaque"
          data = {
            "objstore.yml" = <<EOF
type: S3
config:
  bucket: ${var.thanos_metrics_bucket}
  endpoint: ${var.s3_endpoint}
  region: ${var.s3_region}
  access_key: {{ .thanosAccessKey }}
  secret_key: {{ .thanosSecretKey }}
  insecure: false
  signature_version2: false
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
EOF
          }
        }
      }
      data = [
        {
          secretKey = "thanosAccessKey"
          remoteRef = {
            key = "thanos-monitoring-access-key"
          }
        },
        {
          secretKey = "thanosSecretKey"
          remoteRef = {
            key = "thanos-monitoring-secret-key"
          }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.oci_secret_store_monitoring
  ]
}

# External Secret for Grafana Admin Password
resource "kubectl_manifest" "grafana_admin_password_external_secret" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "grafana"
      namespace = "monitoring"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = kubectl_manifest.oci_secret_store_monitoring.name
        kind = "SecretStore"
      }
      target = {
        name           = "grafana"
        creationPolicy = "Owner"
        type           = "Opaque"
        template = {
          data = {
            "admin-password" = "{{ .adminPassword }}"
            "admin-user"     = "admin"
            "ldap-toml"      = ""
          }
        }
      }
      data = [
        {
          secretKey = "adminPassword"
          remoteRef = {
            key = "grafana-admin-password"
          }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.oci_secret_store_monitoring
  ]
}
# External Secret for Loki S3 Configuration
resource "kubectl_manifest" "loki_s3_external_secret" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "loki-s3-config"
      namespace = "monitoring"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = kubectl_manifest.oci_secret_store_monitoring.name
        kind = "SecretStore"
      }
      target = {
        name           = "loki-s3-config"
        creationPolicy = "Owner"
        type           = "Opaque"
        template = {
          data = {
            "AWS_ACCESS_KEY_ID"     = "{{ .thanosAccessKey }}"
            "AWS_SECRET_ACCESS_KEY" = "{{ .thanosSecretKey }}"
          }
        }
      }
      data = [
        {
          secretKey = "thanosAccessKey"
          remoteRef = {
            key = "thanos-monitoring-access-key"
          }
        },
        {
          secretKey = "thanosSecretKey"
          remoteRef = {
            key = "thanos-monitoring-secret-key"
          }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.oci_secret_store_monitoring
  ]
}
