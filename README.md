# Terraform
## Manual run
### Prerequisites
1. `aws cli` installed and configured
1. `terraform` installed and configured
1. `S3 bucket` for terraform state file created
### 1. Initialize terraform
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
### 2. Check Terraform configuration files formatting
Use `terraform fmt`. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/fmt)
```bash
terraform fmt
echo $?
```
### 3. Plan changes
Use `terraform plan`. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/plan)
```bash
terraform plan
```
### 4. Create resources
1. Create `terraform.tfvars` file with variables:
    ```tfvars
    region         = "us-east-1"
    s3_bucket_name = "your-bucket-name"
    environment    = "test"
    ```
1. Use `terraform apply` to create resources. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/apply)
    ```bash
    terraform apply -auto-approve
    ```
1. After execution following resources will be created:
    * S3 bucket with parameters from variables passed
    * OIDS github provider for githu actions
    * IAM role for github actions
    * VPC with two public and two private subnets in different availability zones
    * Security Groups for private and public subnets
    * Bastion host for ssh connection
    * Master and worker nodes for k3s cluster
### 5. Destroy resources created
Use `terraform destroy`. More info see in [documentation](https://developer.hashicorp.com/terraform/cli/commands/destroy)
```bash
terraform plan -destroy
terraform destroy -auto-approve
```
## Github Actions workflow
### Description
Github actions worflow includes following jobs:
1. `terraform-check` - check Terraform configuration files formatting
1. `terraform-plan` - plan changes
1. `terraform-apply` - create resources
### Variables
1. Following repository `secrets` should be configured:
    * `AWS_ACCOUNT_ID` - AWS account id eg. 123456789012
    * `AWS_REGION` - AWS region to deploy resources eg. us-east-1
    * `TFSTATE_S3_BUCKET` - AWS S3 bucket name to store terraform state file
    * `TF_S3_BUCKET_NAME` - AWS S3 bucket name to be created using this configuration files
    * `TF_S3_BUCKET_NAME` - AWS S3 bucket name to be created using this configuration files
1. Following repository `variables` should be configured:
    * `TF_ENVIRONMENT` - AWS S3 bucket tag
    * `TF_SSH_KEY_NAME` - AWS EC2 ssh key name
## K3S Cluster
### Description
k3s cluster has following configuration:
1. Master (control-plane) node
1. Worker node
### Setup
1. Create resources using `terraform apply`
1. Connect to bastion host with ssh key
1. Connect Master node with the same ssh key
1. Get k3s `node-token`:
    ```bash
    cat /var/lib/rancher/k3s/server/node-token
    ```
1. Connect to worker node using ssh key
1. Launch k3s-agent:
    ```bash
    curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_NODE_IP}:6443 K3S_TOKEN="${K3S_NODE_TOKEN}" sh -s
    ```
1. Configure `kubectl` on your local host according to this [instruction](https://docs.k3s.io/cluster-access)
1. Deploy any resources using `kubectl`:
    ```bash
    kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
    ```