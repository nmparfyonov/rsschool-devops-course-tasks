# Terraform
## 1. Initialize terraform
#### OPTION 1. Declare variables directly to `terraform init` command
```bash
terraform init \
-backend-config="bucket=your-bucket-name" \
-backend-config="region=us-east-1" \
-backend-config="key=state/terraform.tfstate" \
-backend-config="encrypt=true"
```
#### OPTION 2. Create file with variables and pass it to `terraform init` command
1. Create `backend.tfvars` file with variables:
    ```tfvars
    bucket  = "your-bucket-name"
    region  = "us-east-1"
    key     = "state/terraform.tfstate"
    encrypt = true
    ```
1. Initialize terraform using previously created file `backend.tfvars`
    ```bash
    terraform init -backend-config=backend.tfvars
    ```
