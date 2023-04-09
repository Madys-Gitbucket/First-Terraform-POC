# Configure the Provider's Source

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

}

# Configure the AWS Provider

provider "aws" {
  region  = "us-east-1"
}

// syntax to import AWS Lambda to terraform is - 
// terraform import resource_type resource_name (local to terraform) function_name (assigned in AWS)
// terraform import aws_lambda_function sample_function serverless-website-lambdafunction

resource "aws_lambda_function" "sample_function" {
  function_name     = "serverless-website-lambdafunction"
  role              = aws_iam_role.iam_role_for_lambda.arn
  handler           = "index.lambda_handler"
  runtime           = "Node.js 18.x"
  depends_on        = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

# Create an IAM Role for Lambda Function 

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "serverless-website-lambdafunction-role-b7uejgd6"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF
}

# Create an IAM Policy for the IAM Role (created for Lambda Function)

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name = "AWSLambdaBasicExecutionRole-886205ef-56d4-4f99-a724-ff0be42b57f7"
  description = "IAM policy that will be assigned to IAM role created for Lambda"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:706785990376:*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": [
              "arn:aws:logs:us-east-1:706785990376:log-group:/aws/lambda/serverless-website-lambdafunction:*"
            ]
        }
    ]
            
}
EOF
}

#Let's attach the IAM Policy to IAM Role 

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role            = aws_iam_role.iam_role_for_lambda.name 
  policy_arn      = aws_iam_policy.iam_policy_for_lambda.arn 
}
