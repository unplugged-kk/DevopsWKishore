provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# CloudWatch Event Rule to trigger Lambda function when volume is created
resource "aws_cloudwatch_event_rule" "volume_create_rule" {
  name        = "volume_create_rule"
  description = "Trigger Lambda function when volume is created"

  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EBS Volume Notification"],
  "detail": {
    "event": ["createVolume"]
  }
}
PATTERN
}

# Lambda function as the target for CloudWatch Event Rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.volume_create_rule.name
  target_id = "convert_gp2_to_gp3"
  arn       = aws_lambda_function.convert_gp2_to_gp3.arn

  # Ensure the Lambda function is created before associating it with the CloudWatch Event Rule
  depends_on = [aws_lambda_function.convert_gp2_to_gp3]
}


# IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_ebs_policy" {
  name        = "lambda_ebs_policy"
  description = "Permissions for Lambda to modify EBS volumes"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:ModifyVolume"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "lambda_ebs_policy_attachment" {
  name       = "lambda_ebs_policy_attachment"
  policy_arn = aws_iam_policy.lambda_ebs_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}


resource "aws_lambda_function" "convert_gp2_to_gp3" {
  function_name = "convert_gp2_to_gp3"
  runtime       = "python3.8"

  handler = "lambda_function.lambda_handler" # Update the handler value to match your Lambda function code

  # Specify your Lambda function code here
  filename = "lambda_function.zip" # Replace with the path to your Lambda function code ZIP file

  # Example IAM role for the Lambda function with necessary permissions
  role = aws_iam_role.lambda_role.arn

  # Optional: Add environment variables, timeouts, and other configurations for your Lambda function

  # Enable CloudWatch Logs for the Lambda function
  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      "LOG_LEVEL" = "INFO" # Example environment variable for logging level
    }
  }
}

# Create the Lambda function code ZIP file
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source_dir  = "lambda_function" # Replace with the path to your Lambda function code directory
}

