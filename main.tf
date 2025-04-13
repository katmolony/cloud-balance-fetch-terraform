# ----------------------------
# Lambda Function: Fetch AWS Resources & Costs (No VPC)
# ----------------------------
resource "aws_lambda_function" "fetch_lambda" {
  function_name = "cloud-balance-local-fetch"
  role          = aws_iam_role.fetch_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
  timeout = 285

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

# ----------------------------
# IAM Role for Fetch Lambda
# ----------------------------
resource "aws_iam_role" "fetch_lambda_role" {
  name = "cloud_balance_fetch_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# ----------------------------
# IAM Policies for Lambda Access
# ----------------------------

resource "aws_iam_role_policy_attachment" "fetch_lambda_basic" {
  role       = aws_iam_role.fetch_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "fetch_lambda_custom_policy" {
  name        = "FetchLambdaEC2CostExplorerPolicy"
  description = "Allows only necessary actions for EC2 and Cost Explorer access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Sid: "EC2DescribeInstances",
        Effect: "Allow",
        Action: [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource: "*"
      },
      {
        Sid: "CostExplorerUsage",
        Effect: "Allow",
        Action: [
          "ce:GetCostAndUsage"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fetch_lambda_custom_attach" {
  role       = aws_iam_role.fetch_lambda_role.name
  policy_arn = aws_iam_policy.fetch_lambda_custom_policy.arn
}

# ----------------------------
# Allow Backend Lambda to Invoke This Fetch Lambda
# ----------------------------
resource "aws_lambda_permission" "allow_backend_to_invoke_fetch" {
  statement_id  = "AllowBackendInvokeFromBackendV2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_lambda.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = "arn:aws:lambda:us-east-1:203918882764:function:cloud_balance_backend"
}
