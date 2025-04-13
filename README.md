# Cloud Balance - Fetch Lambda Terraform Module

This Terraform configuration defines the infrastructure for the **Cloud Balance Fetch Lambda**, which securely collects AWS Cost Explorer and EC2 resource data on behalf of users. The function is designed to run **outside of a VPC** to simplify setup and reduce latency.

## 🧩 What It Does

- Deploys a Node.js Lambda (`cloud-balance-local-fetch`) from a zipped function (`function.zip`)
- Grants least-privilege IAM access to:
  - `ec2:DescribeInstances` and `ec2:DescribeTags`
  - `ce:GetCostAndUsage`
- Adds the required `AWSLambdaBasicExecutionRole`
- Enables invocation by another Lambda (the Cloud Balance backend)

## 📦 Files

| File            | Purpose                                        |
|-----------------|------------------------------------------------|
| `main.tf`       | Core Terraform code for Lambda + IAM setup     |
| `function.zip`  | Contains the Node.js code for fetching AWS data |

## ✅ Resources Created

- **Lambda Function**: `cloud-balance-local-fetch`
- **IAM Role**: `cloud_balance_fetch_lambda_role`
- **IAM Policy**: `FetchLambdaEC2CostExplorerPolicy`
- **Lambda Permission**: Allows backend Lambda to invoke this one

## 🌍 AWS Region

This module assumes deployment to **`us-east-1`**. Update `source_arn` if you're using a different region.

## 🚀 How to Deploy

1. Ensure AWS credentials are configured (`aws configure`)
2. Make sure `function.zip` contains your latest code
3. Run the following:

```bash
terraform init
terraform apply
```

## System Architecture

The diagram below illustrates how the Cloud Balance mobile app, backend API, AWS Lambda functions, and PostgreSQL database interact across public and private cloud environments.

![Cloud Balance Architecture](assets/architect.png)

## License

MIT — see [LICENSE](LICENSE) for details.

---

## ✨ Credits

Part of the **Cloud Balance** final year project.
Maintained by [Kate](https://github.com/katmolony).
