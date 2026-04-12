# DigitalOcean Terraform Stack

This stack is intentionally separated from the main `terraform/` directory so it can keep its own state and be applied independently.

## 1. Keep the token out of git

This stack reads the token directly from the `DIGITALOCEAN_TOKEN` environment variable, so there is no token field in the `.tf` files.

Do not `source` the repo root `.env` if it contains anything other than environment variable assignments.
Create a local file from the example and keep it out of git:

```bash
cp .do.env.example .do.env
```

Then load it into your shell:

```bash
set -a
source .do.env
set +a
```

## 2. Set your non-secret values

Copy the example file and adjust it locally:

```bash
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` is ignored by git via the repo root `.gitignore`.

This is also where you set your SSH key for droplet access:

```hcl
ssh_key_ids = [
  "your-ssh-key-id-or-fingerprint",
]
```

The value above must be a DigitalOcean SSH key identifier, not your API token.

## 3. Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

## 4. Expected local files

These files should stay local and uncommitted:

- `.do.env`
- `terraform.tfvars`
- `terraform.tfstate`
