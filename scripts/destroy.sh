#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

cd "${TF_DIR}"

if [[ ! -f "terraform.tfvars" ]]; then
  echo "ERROR: terraform/terraform.tfvars not found."
  exit 1
fi

terraform init
terraform plan -destroy -var-file=terraform.tfvars

echo
read -r -p "DESTROY ALL RESOURCES IN THIS TERRAFORM STATE? Type DESTROY to continue: " CONFIRM

if [[ "${CONFIRM}" != "DESTROY" ]]; then
  echo "Destroy cancelled."
  exit 0
fi

terraform destroy -var-file=terraform.tfvars
