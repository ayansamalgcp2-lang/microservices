# GCP Cloud Run Microservices — Terraform Stack

This repository provisions a secure, multi-environment (dev/stg/prod) microservices platform on **Google Cloud** with:
- Cloud Run (per-service SAs, least-privilege)
- API Gateway (auth/quotas/routing) and optional Global HTTPS LB
- Cloud SQL for PostgreSQL (private IP)
- Memorystore (Redis)
- VPC, Private Google Access, PSC (private service connect to Google APIs)
- Remote Terraform state in GCS (versioning & concurrency-safe)
- Envs via workspaces + tfvars
- Observability with **Managed Service for Prometheus (GMP)** + **Managed Grafana**

> This is a reference. Adjust IAM and sizing for your org’s guardrails.

## Quick start

1) **Bootstrap remote state (one-time)**

```bash
cd bootstrap
# Copy bootstrap.tfvars.example to bootstrap.tfvars and fill values
cp bootstrap.tfvars.example bootstrap.tfvars

terraform init
terraform apply -var-file=bootstrap.tfvars
```

2) **Point Terraform to the GCS backend**

```bash
cd global
# Update backend.tf bucket name to match the bucket created by bootstrap
# (or pass -backend-config on init)
```

3) **Deploy an environment**

```bash
cd envs/dev

# Choose workspace (dev/stg/prod). First time, create it:
terraform workspace new dev || true
terraform workspace select dev

# Copy example tfvars and fill your values
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform apply -var-file=terraform.tfvars
```

Do the same for `envs/stg` and `envs/prod` (with their own workspaces/tfvars).

## Structure

```
modules/            # Reusable infra modules
envs/               # Per-env roots: dev, stg, prod
global/             # Providers & backend
bootstrap/          # One-time state bucket creation
```

## Notes
- API Gateway uses OpenAPI specs under `envs/*/specs`. Update backends & domains.
- Add Cloud Armor and VPC SC at org level as needed.
- For observability, expose `/metrics` in services. Integrate via Otel or native SDKs.
- Secrets (DB password) are in **Secrets Manager** (sample wiring included).

## License
MIT (modify to your needs)
