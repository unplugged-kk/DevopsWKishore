import os
import json
import requests

def send_to_slack(pr_title, pr_author, pr_merged_at, pr_url, pr_commit_hash, pr_description, webhook_url):
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

    response = requests.post(webhook_url, json=message)
    response.raise_for_status()

def lambda_handler(event, context):
    print("Event:", event)

    # Parse the payload received from the webhook
    payload = json.loads(event['body'])
    action = payload['action']
    pr_data = payload['pull_request']

    print("Action:", action)
    print("PR Data:", pr_data)

    # Check if the PR was merged or starts with "Revert:"
    if action == 'closed' and pr_data['merged'] or pr_data['title'].startswith('Revert:'):
        pr_title = pr_data['title']
        pr_url = pr_data['html_url']
        pr_merged_at = pr_data['merged_at']
        pr_author = pr_data['user']['login']
        pr_commit_hash = pr_data['merge_commit_sha']
        pr_description = pr_data['body']

        print("Sending PR data to Slack...")

        # Send PR data to Slack
        slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
        send_to_slack(pr_title, pr_author, pr_merged_at, pr_url, pr_commit_hash, pr_description, slack_webhook_url)
        print("PR data sent to Slack.")

    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
