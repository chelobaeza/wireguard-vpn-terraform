# WireGuard VPN AWS Terraform Module

This project provides an automated way to deploy a WireGuard VPN server on AWS using Terraform. It leverages an EC2 instance, Docker, and the [wg-easy](https://github.com/wg-easy/wg-easy) management UI, with secure HTTPS access via Nginx and mkcert-generated certificates.

## Features
- **Automated EC2 provisioning** with security groups, key pair, and networking.
- **WireGuard VPN** deployed via Docker Compose using the `wg-easy` project.
- **HTTPS access** to the management UI using Nginx and mkcert for self-signed certificates.
- **Customizable** via Terraform variables for AMI, instance type, VPC, subnet, and SSH key.

## Prerequisites
- [Terraform](https://www.terraform.io/) installed
- AWS CLI configured with appropriate credentials
- SSH key pair in your AWS account

## Project Structure
- `main.tf` – Root Terraform configuration, instantiates the EC2 module
- `variables.tf` – Input variables for the root module
- `user_data.sh` – User data script to bootstrap the EC2 instance (Docker, wg-easy, Nginx, mkcert)
- `modules/ec2_instance/` – Reusable Terraform module for EC2 provisioning
- `get_ec2_linked_info.sh` – Helper script to fetch AWS resource IDs linked to an EC2 instance

## Usage

1. **Clone the repository**
   ```bash
   git clone <this-repo-url>
   cd wireguard
   ```

2. **Configure variables**
   - Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values:
     - `aws_region`, `vpc_id`, `subnet_id`, `instance_type`, `key_name`, `ami` (optional)

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```
   - Confirm the action when prompted.

6. **Access the VPN UI**
   - After deployment, find the public IP or DNS of your EC2 instance (output by Terraform or in AWS Console).
   - Open `https://<public-ip-or-dns>/` in your browser.
   - Accept the self-signed certificate warning.

## Security Notes
- The default security group allows SSH (22), HTTPS (443), and WireGuard (51820/UDP) from anywhere. Restrict these as needed.
- The HTTPS certificate is self-signed and generated on the instance for its public IP.
- Store your SSH key securely.

## Cleanup
To destroy all resources created by this project:
```bash
terraform destroy
```

## Importing Existing AWS Resources
If you have already created an EC2 instance and related resources manually (outside of Terraform), you can import them into your Terraform state. This allows you to manage those resources with Terraform going forward.

### Using the Helper Script
The script `get_ec2_linked_info.sh` helps you gather all the AWS resource IDs linked to a specific EC2 instance (such as IAM roles, security groups, subnets, volumes, etc.).

**Usage:**
```bash
./get_ec2_linked_info.sh <ec2-instance-id>
```
This will output a list of resource IDs in a format that matches Terraform resource types, making it easier to construct your import commands.

### Importing Resources into Terraform
For each resource managed by the EC2 module, use the `terraform import` command with the correct module path. For example:
```bash
terraform import module.ec2_instance.aws_instance.this <ec2-instance-id>
terraform import module.ec2_instance.aws_security_group.this <sg-id>
```

Terraform documentation for more details on [importing resources](https://developer.hashicorp.com/terraform/cli/import).

