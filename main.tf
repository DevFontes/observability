resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "76.4.0"
  create_namespace = true
  values           = [file("${path.module}/files/prometheus.yaml")]
}

resource "helm_release" "grafana" {
  depends_on = [helm_release.prometheus]
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "9.3.3"
  values     = [file("${path.module}/files/grafana.yaml")]
}

resource "helm_release" "loki" {
  depends_on = [kubectl_manifest.loki_s3_external_secret]
  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.37.0"
  values = [templatefile("${path.module}/files/loki.yaml", {
    loki_s3_endpoint = var.s3_endpoint
    loki_s3_region   = var.s3_region
  })]

}

resource "helm_release" "alloy" {
  depends_on = [helm_release.loki]
  name       = "alloy"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "1.2.1"
  values     = [file("${path.module}/files/alloy.yaml")]
}

resource "kubectl_manifest" "servicemonitors" {
  depends_on = [helm_release.prometheus]
  yaml_body  = file("${path.module}/files/monitors/servicemonitors.yaml")
}

resource "kubectl_manifest" "alerting_rules" {
  depends_on = [helm_release.prometheus]
  yaml_body  = file("${path.module}/files/alerts/alerting-rules.yaml")
}
