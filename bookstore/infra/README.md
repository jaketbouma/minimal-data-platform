# Minimal Data Platform - AWS v0

This project is a Terraform configuration for deploying a minimal data platform on AWS. It includes the necessary files to define and manage infrastructure resources using Terraform.

## Project Structure

- `main.tf`: Main configuration file defining AWS resources.
- `variables.tf`: Input variables for the Terraform configuration.
- `outputs.tf`: Output values returned after infrastructure creation.
- `provider.tf`: Configuration for the AWS provider.

## Getting Started

### Prerequisites

- Terraform installed on your machine.
- AWS account with appropriate permissions.

### Setup

1. Clone the repository:
   ```
   git clone <repository-url>
   cd minimal-data-platform/aws-v0
   ```

2. Configure your AWS credentials. You can do this by setting environment variables or using the AWS CLI.

3. Initialize the Terraform project:
   ```
   terraform init
   ```

4. Review the planned changes:
   ```
   terraform plan
   ```

5. Apply the configuration to create the resources:
   ```
   terraform apply
   ```

### Usage

After applying the configuration, you can access the created resources using the outputs defined in `outputs.tf`.

### Cleanup

To remove the resources created by Terraform, run:
```
terraform destroy
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.