# AWS Route 53 DNS Failover — Terraform

Production-oriented starter repository for an active/passive Route 53 failover setup.

## What this repository creates

- Route 53 health checks for primary and secondary endpoints.
- Route 53 `PRIMARY` and `SECONDARY` failover records.
- Configurable TTL and health-check settings.
- Optional CloudWatch alarms for Route 53 health-check status.
- Optional SNS notifications for those alarms.
- Terraform module structure.
- Deployment and destruction scripts.
- GitHub Actions example for `terraform fmt`, `validate`, and `plan`.
- Least-privilege IAM policy examples.
- Remote-state guidance using S3 + DynamoDB locking.
- VS Code workspace and recommended extensions.
- Safe secret-handling examples.

> This repository does **not** contain AWS credentials, private keys, Terraform state, or real secrets.

## Architecture

```text
                         DNS query
                            |
                            v
                    +---------------+
                    | Amazon Route53|
                    | Failover      |
                    | PRIMARY       |
                    +-------+-------+
                            |
                  health check passes?
                     /             \
                   yes              no
                   /                 \
                  v                   v
          PRIMARY endpoint     SECONDARY record
                                      |
                                      v
                              secondary endpoint

Route 53 health-check status
          |
          v
CloudWatch alarm (optional)
          |
          v
SNS topic (optional)
```

Route 53 failover is DNS-based. It does not move application traffic directly and it does not perform application deployment. Your primary and secondary endpoints must already exist and be reachable.

## Prerequisites

- AWS account with permission to create Route 53, CloudWatch, SNS, and related resources.
- AWS CLI v2.
- Terraform >= 1.6.
- Git.
- VS Code.
- Optional: GitHub CLI (`gh`).

Verify:

```bash
aws --version
terraform version
git --version
gh --version
```

Authenticate without putting keys in files.

### AWS CLI profile

```bash
aws configure --profile route53-failover
aws sts get-caller-identity --profile route53-failover
export AWS_PROFILE=route53-failover
```

For CI, prefer GitHub OIDC + an AWS IAM role instead of long-lived access keys.

## Project structure

```text
route53-failover-terraform/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── .vscode/
│   └── extensions.json
├── iam/
│   ├── github-actions-trust-policy.json
│   └── terraform-least-privilege-policy.json
├── scripts/
│   ├── deploy.sh
│   └── destroy.sh
├── terraform/
│   ├── backend.tf.example
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       └── route53-failover/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── .env.example
├── .gitignore
├── LICENSE
├── README.md
└── route53-failover.code-workspace
```

## 1. Configure the Terraform variables

Copy:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

On Windows PowerShell:

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars`.

Important variables:

- `hosted_zone_id`: existing public Route 53 hosted zone ID.
- `record_name`: DNS name to fail over.
- `primary_endpoint`: primary target hostname/IP.
- `secondary_endpoint`: secondary target hostname/IP.
- `health_check_path`: application health endpoint such as `/health`.
- `health_check_port`: normally `443`.
- `ttl`: 30–60 seconds is a practical starting point for failover DNS.
- `enable_cloudwatch_alarm`: enables health-check alarms.
- `create_sns_topic`: creates an SNS topic when alarms are enabled.

### Endpoint type

For an HTTP/HTTPS health check:

```hcl
health_check_type = "HTTPS"
```

For a hostname:

```hcl
primary_endpoint = "primary.example.com"
```

For an IP-based endpoint:

```hcl
primary_endpoint = "203.0.113.10"
```

Do not put secrets in health-check URLs. If authentication is required, expose a dedicated unauthenticated `/health` endpoint that returns a correct success response.

## 2. Terraform initialization

From the repository root:

```bash
cd terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
```

Review the plan carefully.

Apply:

```bash
terraform apply -var-file=terraform.tfvars
```

Or use:

```bash
../scripts/deploy.sh
```

## 3. Remote state: S3 + DynamoDB

The repository deliberately does not hardcode your backend bucket/table.

First create:

1. An S3 bucket for Terraform state.
2. A DynamoDB table with partition key `LockID` (String), if using DynamoDB locking.
3. Encryption at rest.
4. Public access blocked.
5. Versioning enabled.
6. Restricted IAM access.

Copy:

```bash
cp terraform/backend.tf.example terraform/backend.tf
```

Fill in your actual bucket, key, and region.

Then:

```bash
cd terraform
terraform init
```

### Important Terraform locking note

Terraform's modern S3 backend supports S3-native state locking with `use_lockfile = true`. DynamoDB locking is retained here as an explicit legacy/compatibility option because many existing organizations still use it.

For a new environment, evaluate S3-native locking first. If your organization standardizes on DynamoDB locking, set the DynamoDB table as documented in `backend.tf.example`.

Never commit real backend configuration containing sensitive organizational details if your policy treats them as confidential.

## 4. Least-privilege IAM

`iam/terraform-least-privilege-policy.json` is a starting policy for the resources created by this repository.

Do not blindly attach broad `AdministratorAccess`.

A production IAM design should separate:

- Bootstrap permissions for creating the remote-state bucket/table.
- Terraform deployment permissions.
- Read-only plan permissions where practical.
- CI deployment role.
- Human break-glass access.

For GitHub Actions, use OIDC federation rather than storing an AWS access key and secret in GitHub.

The trust policy template is:

```text
iam/github-actions-trust-policy.json
```

Replace placeholders such as AWS account ID, GitHub organization, repository, and branch conditions before use.

## 5. GitHub Actions

The example workflow performs:

- Terraform formatting check.
- Terraform initialization.
- Terraform validation.
- Terraform plan.

It does **not** automatically apply infrastructure on every push.

For production, require a protected environment and manual approval before apply.

### Recommended GitHub setup

1. Create an AWS IAM OIDC provider for GitHub Actions.
2. Create a dedicated IAM role.
3. Restrict its trust policy to the exact repository and branch/environment.
4. Add the role ARN as a GitHub variable/secret according to your organization's policy.
5. Update `.github/workflows/terraform.yml`.

Do not commit:

```text
*.tfvars
*.tfstate
*.tfstate.*
.env
.env.*
```

except approved example files.

## 6. Git workflow

Initialize:

```bash
git init
git branch -M main
git add .
git commit -m "feat: add Route 53 failover infrastructure"
```

Recommended branches:

```text
main        -> protected production branch
develop     -> integration branch
feature/*  -> individual changes
hotfix/*   -> urgent fixes
```

Create a GitHub repository with GitHub CLI:

```bash
gh auth login
gh repo create route53-failover-terraform --private --source=. --remote=origin
git push -u origin main
```

Or create the repository on GitHub and then:

```bash
git remote add origin git@github.com:YOUR_ORG/route53-failover-terraform.git
git push -u origin main
```

### Large files

Do not put Terraform state, build artifacts, videos, or generated archives in the Git repository unless there is a deliberate reason.

If large binary assets are genuinely required, use Git LFS:

```bash
git lfs install
git lfs track "*.zip"
git add .gitattributes
```

For this infrastructure repository, keeping generated ZIP archives outside Git is usually cleaner.

## 7. VS Code

Open:

```bash
code route53-failover.code-workspace
```

Recommended extensions are listed in `.vscode/extensions.json`.

Useful terminal commands:

```bash
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
```

If Terraform language features appear broken:

1. Confirm the HashiCorp Terraform extension is installed.
2. Run `terraform init`.
3. Open the `terraform/` directory in the workspace.
4. Check the Terraform binary path in VS Code.
5. Restart the Terraform language server.

## 8. Testing failover

### Test 1 — Normal state

Verify the record:

```bash
dig +short app.example.com
```

or:

```bash
nslookup app.example.com
```

Confirm the response points to the primary endpoint.

Then check the application health endpoint:

```bash
curl -I https://primary.example.com/health
```

### Test 2 — Controlled failure

Do **not** randomly delete production infrastructure.

Instead, use a staging environment and make the primary health endpoint return a failure status or make it unreachable.

For example, temporarily configure the staging load balancer to return HTTP 503 for `/health`.

Wait for the Route 53 health check to detect failure and for DNS responses to transition to the secondary.

Because DNS is cached, TTL is not a guarantee that every resolver will switch at exactly the TTL boundary.

Verify:

```bash
dig +short app.example.com
```

Run multiple queries from different resolvers if you are testing real-world propagation.

### Test 3 — Recovery

Restore the primary endpoint:

```bash
curl -I https://primary.example.com/health
```

Confirm the health check becomes healthy and verify Route 53 returns the primary again.

### Test 4 — CloudWatch alarm

If enabled, inspect the Route 53 health-check alarm in CloudWatch.

Confirm:

- ALARM occurs when the primary becomes unhealthy.
- OK returns after recovery.
- SNS notification arrives if subscriptions are configured.

## 9. Operational recommendations

### TTL

Start with 30–60 seconds for a failover record where faster DNS convergence matters.

Example 1:

```hcl
ttl = 30
```

Example 2:

```hcl
ttl = 60
```

Lower TTL does not guarantee instant failover because recursive resolvers and clients may cache responses according to their own behavior.

### Health endpoint

Use a lightweight endpoint such as:

```text
GET /health
HTTP 200
```

It should test only the dependencies necessary to declare the application usable. Do not make a health check perform expensive business logic.

### Monitoring

Route 53 failover is not a replacement for application monitoring. Combine:

- Route 53 health checks.
- CloudWatch alarms.
- Application metrics.
- Load balancer health.
- Logs.
- Synthetic monitoring.

### Security

- Never commit AWS credentials.
- Prefer IAM roles.
- Prefer GitHub OIDC for CI/CD.
- Encrypt Terraform state.
- Restrict access to the state bucket.
- Enable S3 versioning.
- Protect `main`.
- Require pull-request review.
- Use separate AWS accounts/environments for production and non-production.

## 10. Destroy

Only run this against infrastructure you intentionally want to remove:

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

Or:

```bash
../scripts/destroy.sh
```

The destroy script requires an explicit confirmation string.

## 11. Packaging and verification

From the parent directory:

Linux/macOS:

```bash
zip -r route53-failover-terraform.zip route53-failover-terraform \
  -x "*/.terraform/*" \
     "*/terraform.tfstate*" \
     "*/.env" \
     "*/terraform.tfvars"
```

PowerShell:

```powershell
Compress-Archive -Path .\route53-failover-terraform\* `
  -DestinationPath .\route53-failover-terraform.zip -Force
```

Before sharing the archive, inspect it:

```bash
unzip -l route53-failover-terraform.zip
```

Confirm it contains:

- README.md
- Terraform module
- deployment scripts
- destroy script
- IAM templates
- GitHub Actions workflow
- VS Code workspace
- `.gitignore`
- `.env.example`
- LICENSE

Confirm it does **not** contain:

- AWS credentials
- `.env`
- real `terraform.tfvars`
- `.tfstate`
- `.terraform/`
- private keys

## 12. Production change checklist

Before `terraform apply`:

- [ ] Correct AWS account.
- [ ] Correct hosted zone.
- [ ] Correct DNS record.
- [ ] Primary endpoint verified.
- [ ] Secondary endpoint verified.
- [ ] Health endpoints return expected status.
- [ ] IAM role is least privilege.
- [ ] Terraform state is remote and protected.
- [ ] CloudWatch alarm destination is configured.
- [ ] Change reviewed in `terraform plan`.
- [ ] Rollback/failback procedure tested in staging.

