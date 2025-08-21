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
  version    = "9.3.1"
  values     = [file("${path.module}/files/grafana.yaml")]
}

resource "kubectl_manifest" "servicemonitors" {
  depends_on = [helm_release.prometheus]
  yaml_body  = file("${path.module}/files/monitors/servicemonitors.yaml")
}

resource "kubectl_manifest" "alerting_rules" {
  depends_on = [helm_release.prometheus]
  yaml_body  = file("${path.module}/files/alerts/alerting-rules.yaml")
}
