## 0. Prerequesite 
*Summary.*
go to https://api.slack.com/apps  and create a app  and add the app to the workspace and respective channel

Enable Activate Incoming Webhooks copy and keep the slack url handy

Ex : https://hooks.slack.com/services/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

To test the webhook:

curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' https://hooks.slack.com/services/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

## 1. Pull Request Data Collector GitHub Action
*Summary.*

This GitHub Action collects data from pull requests when they are merged or when a PR is opened with a title starting with "Revert:". The collected data is then sent to a specified Slack channel using an incoming webhook.

## 2. Setup
Add the .github directory to your repository: Create a .github directory in the root of your repository (if it doesn't already exist) and add a workflows directory and a scripts directory inside it. The final structure should look like this:

your-repo/
  .github/
    workflows/
    scripts/

Create the workflow file: Inside the .github/workflows directory, create a new file called pr_data_collector.yml and copy the contents of the provided pr_data_collector.yml into it.

Create the Python script: Inside the .github/scripts directory, create a new file called collect_and_store_pr_data.py and copy the contents of the provided collect_and_store_pr_data.py into it.

Set up the Slack webhook: Create an incoming webhook in your Slack workspace by following the official Slack guide. Make a note of the webhook URL, as you will need it in the next step.

Add the webhook URL to your GitHub repository secrets: In your GitHub repository, go to the "Settings" tab, click on "Secrets" in the left sidebar, and then click on "New repository secret". Name the secret SLACK_WEBHOOK_URL and set its value to the webhook URL from the previous step.

## 3. How it works

When a pull request is merged or a PR with a title starting with "Revert:" is opened, this GitHub Action will collect the following data:

PR title
PR author
PR merge timestamp (if applicable)
PR URL
PR commit hash (if applicable)
PR description
The collected data is then sent as a message to the Slack channel associated with the webhook URL.


   