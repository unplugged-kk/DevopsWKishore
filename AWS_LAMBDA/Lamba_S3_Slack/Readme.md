# GitHub PR Notifications to Slack and S3

This AWS Lambda function sends merged and reverted GitHub Pull Request (PR) notifications to a Slack channel and appends PR details to a text file in an S3 bucket. The S3 text file is rotated biweekly, creating a new file for each half of the month.

## Requirements

- An AWS account with permissions to create and manage Lambda functions, API Gateway, and S3 buckets
- A GitHub account with permissions to create and manage repositories and webhooks
- A Slack account with permissions to create and manage incoming webhooks

## Lambda Function

1. Create a new Lambda function in the AWS Management Console with the Python runtime (e.g., Python 3.8).
2. Use the provided `lambda_function.py` script as the Lambda function code.
3. Set the following environment variables for the Lambda function:
   1. `SLACK_WEBHOOK_URL`: The Slack incoming webhook URL
   2. `S3_BUCKET_NAME`: The name of the S3 bucket where the PR data will be stored

## API Gateway

1. Create a new API Gateway in the AWS Management Console.
2. Add a new POST method.
3. Set the Integration type to Lambda Function and choose the previously created Lambda function as the target.
4. Deploy the API.

## S3 Bucket

1. Create a new S3 bucket in the AWS Management Console.
2. Set up a bucket policy to grant the Lambda function's IAM role access to read and write objects in the bucket.

## GitHub Webhook

1. Go to the GitHub repository where you want to track PR events.
2. Navigate to Settings > Webhooks.
3. Click "Add webhook" and use the API Gateway's POST URL as the webhook URL.
4. Set the content type to `application/json`.
5. Choose the "Let me select individual events" option and select only the "Pull requests" event.
6. Save the webhook.

With this setup, the Lambda function will be triggered whenever a PR is merged or reverted in the connected GitHub repository. The PR details will be sent to the specified Slack channel and appended to the corresponding biweekly text file in the S3 bucket.
