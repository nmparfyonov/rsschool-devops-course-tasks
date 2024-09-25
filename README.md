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
## 2. Check Terraform configuration files formatting
Use `terraform fmt`. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/fmt)
```bash
terraform fmt
echo $?
```
## 3. Plan changes
Use `terraform plan`. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/plan)
```bash
terraform plan
```
## 4. Create resources
1. Create `terraform.tfvars` file with variables:
    ```tfvars
    region         = "us-east-1"
    s3_bucket_name = "your-bucket-name"
    environment    = "test"
    ```
1. Use `terraform apply` to create resources. After execution s3 bucket will be created. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/apply)
    ```bash
    terraform apply -auto-approve
    ```
After completion
## 5. Destroy resources created
Use `terraform destroy`. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/destroy)
```bash
terraform plan -destroy
terraform destroy -auto-approve
```