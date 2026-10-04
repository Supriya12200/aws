#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

cd "${TF_DIR}"

if [[ ! -f "terraform.tfvars" ]]; then
  echo "ERROR: terraform/terraform.tfvars not found."
  echo "Copy terraform.tfvars.example to terraform.tfvars and configure it."
  exit 1
fi

terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars

echo
read -r -p "Apply the plan above? Type APPLY to continue: " CONFIRM

if [[ "${CONFIRM}" != "APPLY" ]]; then
  echo "Deployment cancelled."
  exit 0
fi

terraform apply -var-file=terraform.tfvars
