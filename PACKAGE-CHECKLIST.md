# Package Verification

Expected core files:

- README.md
- .gitignore
- .env.example
- LICENSE
- route53-failover.code-workspace
- .vscode/extensions.json
- .github/workflows/terraform.yml
- iam/terraform-least-privilege-policy.json
- iam/github-actions-trust-policy.json
- scripts/deploy.sh
- scripts/destroy.sh
- terraform/providers.tf
- terraform/backend.tf.example
- terraform/main.tf
- terraform/variables.tf
- terraform/outputs.tf
- terraform/terraform.tfvars.example
- terraform/modules/route53-failover/main.tf
- terraform/modules/route53-failover/variables.tf
- terraform/modules/route53-failover/outputs.tf

Security checks:

- No AWS credentials
- No private keys
- No real .tfvars
- No Terraform state
- No .terraform directory
