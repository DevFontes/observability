# Observability Stack

Stack completo de observabilidade para Kubernetes usando Prometheus, Grafana e Thanos com integração ao External Secrets Operator.

## Componentes

### Core Stack
- **Prometheus** - Coleta e armazenamento de métricas
- **Grafana** - Visualização e dashboards
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

## Features

- ✅ Coleta de métricas com Prometheus
- ✅ Dashboards customizados no Grafana
- ✅ Retenção de longo prazo com Thanos
- ✅ Gerenciamento seguro de credenciais via ESO
- ✅ Replicação automática de secrets
- ✅ Alerting configurável
- ✅ Monitoramento de aplicações customizadas
