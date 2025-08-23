# Observability Stack

Stack completo de observabilidade para Kubernetes usando Prometheus, Grafana e Thanos com integração ao External Secrets Operator.

## Componentes

### Core Stack
- **Prometheus** - Coleta e armazenamento de métricas
- **Grafana** - Visualização e dashboards
- **Loki** - Agregação e consulta de logs com armazenamento S3
- **Grafana Alloy** - Coleta de logs (substitui Promtail)
- **Thanos** - Armazenamento de longo prazo no S3
- **External Secrets Operator** - Gerenciamento seguro de credenciais

### Integrações
- **OCI Vault** - Armazenamento seguro de secrets
- **Reflector** - Replicação de secrets entre namespaces
- **Wasabi S3** - Storage para métricas históricas

## Estrutura do Projeto

```
├── files/
│   ├── alerts/          # Regras de alerting
│   ├── dashboards/      # Dashboards do Grafana
│   ├── monitors/        # ServiceMonitors
│   ├── grafana.yaml     # Configuração do Grafana
│   ├── loki.yaml        # Configuração do Loki
│   └── prometheus.yaml  # Configuração do Prometheus
├── templates/
│   └── oci-config.tpl   # Template de configuração OCI
├── eso-secrets.tf       # Configuração ESO
├── main.tf              # Recursos principais
├── providers.tf         # Providers Terraform
└── variables.tf         # Variáveis do projeto
```

## Pré-requisitos

- Kubernetes cluster
- Terraform >= 1.0
- OCI Vault configurado
- Bucket S3 (Wasabi)

## Variáveis Necessárias

```bash
export TF_VAR_oci_region="sa-saopaulo-1"
export TF_VAR_oci_vault_ocid="ocid1.vault..."
export TF_VAR_oci_user_ocid="ocid1.user..."
export TF_VAR_oci_tenancy_ocid="ocid1.tenancy..."
export TF_VAR_grafana_admin_password="sua_senha"
```

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Secrets Management

As configurações sensíveis são gerenciadas através do External Secrets Operator (ESO), que busca secrets do OCI Vault:

### Thanos Object Store
- **Secret**: `thanos-objstore-config`
- **Keys do Vault**: 
  - `thanos-monitoring-access-key` - Access key do S3
  - `thanos-monitoring-secret-key` - Secret key do S3

### Grafana Admin
- **Secret**: `grafana`
- **Keys do Vault**: 
  - `grafana-admin-password` - Senha do usuário admin
- **Keys fixas**: `admin-user: "admin"`, `ldap-toml: ""`

### Loki S3 Storage
- **Secret**: `loki-s3-config`
- **Keys do Vault** (compartilhadas com Thanos): 
  - `thanos-s3-endpoint` - Endpoint Wasabi (s3.ca-central-1.wasabisys.com)
  - `thanos-s3-region` - Região (ca-central-1)
  - `thanos-monitoring-access-key` - Access key Wasabi
  - `thanos-monitoring-secret-key` - Secret key Wasabi

## Features

- ✅ Coleta de métricas com Prometheus
- ✅ Dashboards customizados no Grafana
- ✅ Coleta e agregação de logs com Loki + Alloy
- ✅ Armazenamento de logs em S3
- ✅ Retenção de longo prazo com Thanos
- ✅ Gerenciamento seguro de credenciais via ESO
- ✅ Replicação automática de secrets
- ✅ Alerting configurável
- ✅ Monitoramento de aplicações customizadas
