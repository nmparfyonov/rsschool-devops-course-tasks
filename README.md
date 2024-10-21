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
## EC2 Memory swap
### Create a swap file
[Original resource](https://repost.aws/knowledge-center/ec2-memory-swap-file) Complete the following steps:

1. Run the dd command to create a swap file on the root file system. Note: In the command, bs is the block size and count is the number of blocks. The size of the swap file is the block size option multiplied by the count option in the dd command. Adjust these values to determine the swap file size. The block size that you specify must be less than the available memory on the instance, or you receive the memory exhausted error. In the following example dd command, the swap file is 4 GB (128 MB x 32):
    ```bash
    sudo dd if=/dev/zero of=/swapfile bs=128M count=32
    ```
1. To update the read and write permissions for the swap file, run the following command:
    ```bash
    sudo chmod 600 /swapfile
    ```
1. To set up a Linux swap space, run the following command:
    ```bash
    sudo mkswap /swapfile
    ```
1. To add the swap file to swap space and make the swap file available for immediate use, run the following command:
    ```bash
    sudo swapon /swapfile
    ```
1. To verify that the procedure was successful, run the following command:
    ```bash
    sudo swapon -s
    ```
1. To start the swap file at boot time, edit the /etc/fstab file. Open the file in the editor, and then run the following command:
    ```bash
    sudo vi /etc/fstab
    ```
1. Add the following new line at the end of the file:
    ```bash
    /swapfile swap swap defaults 0 0
    ```
1. Save the file, and then exit.