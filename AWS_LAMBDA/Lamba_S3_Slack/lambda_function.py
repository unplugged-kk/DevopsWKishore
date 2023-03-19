import json
import os
import boto3
from botocore.exceptions import ClientError
from datetime import datetime
import requests

# Get environment variables
SLACK_WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']
S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']

# Create S3 client
s3 = boto3.client('s3')

def extract_pr_data(event):
    """
    Extracts the relevant pull request data from the webhook payload
    """
    if event.get("headers") and event.get("body"):
        # Parse webhook payload
        webhook_payload = json.loads(event["body"])
        # Get pull request data
        pr_data = webhook_payload["pull_request"]
        # Check if pull request was merged or if it's a revert
        if pr_data["merged"] or pr_data["title"].startswith("Revert:"):
            return pr_data
    return None


def generate_s3_key(merged_at):
    """
    Generates the S3 key for the file containing the pull request data
    """
    merged_date = datetime.strptime(merged_at, "%Y-%m-%dT%H:%M:%SZ").date()
    month_start = merged_date.replace(day=1)
    biweekly_start = month_start.replace(day=16) if merged_date.day > 15 else month_start
    return f"{biweekly_start.year}/{biweekly_start.month:02}/{biweekly_start.day:02}-PRs.txt"


def append_to_s3(data, bucket, key):
    """
    Appends the pull request data to the file in S3
    """
    try:
        # Get existing data from S3 file
        s3_object = s3.get_object(Bucket=bucket, Key=key)
        existing_data = s3_object["Body"].read().decode("utf-8")
        # Append new data to existing data
        new_data = existing_data + data
    except ClientError as e:
        if e.response["Error"]["Code"] == "NoSuchKey":
            # If file doesn't exist yet, create new data
            new_data = data
        else:
            # Otherwise, raise the error
            raise e

    # Upload new data to S3 file
    s3.put_object(Body=new_data, Bucket=bucket, Key=key)


def send_to_slack(pr_data, webhook_url):
    """
    Sends a message to Slack with the pull request data
    """
    pr_title = pr_data['title']
    pr_author = pr_data['user']['login']
    pr_merged_at = pr_data['merged_at']
    pr_url = pr_data['html_url']
    pr_commit_hash = pr_data['merge_commit_sha']
    pr_description = pr_data['body']

    # Format message as a Slack block
    message = {
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*PR Title:* {pr_title}\n*Author:* {pr_author}\n*Merged at:* {pr_merged_at}\n*URL:* {pr_url}\n*Commit Hash:* {pr_commit_hash}\n*Description:* {pr_description}"
                },
            },
        ]
    }

    # Send message to Slack
    response = requests.post(webhook_url, json=message)
    response.raise_for_status()


def lambda_handler(event, context):
    """
    Lambda function entry point
    """
    pr_data = extract_pr_data(event)

    if pr_data is not None:
        # Generate string containing the pull request data
        pr_data_str = f"PR Title: {pr_data['title']}\n"
        pr_data_str += f"Author: {pr_data['user']['login']}\n"
        pr_data_str += f"Merged at: {pr_data['merged_at']}\n"
        pr_data_str += f"PR URL: {pr_data['html_url']}\n"
        pr_data_str += f"Commit Hash: {pr_data['merge_commit_sha']}\n"
        pr_data_str += f"Description: {pr_data['body'] if pr_data['body'] else 'No description provided'}\n"
        pr_data_str += "-" * 80 + "\n\n"


        s3_key = generate_s3_key(pr_data['merged_at'])

        print(f"Bucket: {S3_BUCKET_NAME}")
        print(f"Key: {s3_key}")

        append_to_s3(pr_data_str, S3_BUCKET_NAME, s3_key)
        send_to_slack(pr_data, SLACK_WEBHOOK_URL)

    return {"statusCode": 200, "body": json.dumps("Success")}
