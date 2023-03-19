## 1. Create a Slack APP
*Summary.*
go to https://api.slack.com/apps  and create a app  and add the app to the workspace and respective channel

Enable Activate Incoming Webhooks copy and keep the slack url handy

Ex : https://hooks.slack.com/services/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

To test the webhook:

curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' https://hooks.slack.com/services/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

## 2.AWS Lambda:

Sign in to the AWS Management Console. If you don't have an AWS account, you can create one by following the sign-up process.

Open the AWS Lambda console.

Click on the "Create function" button.

Choose the "Author from scratch" option.

In the "Function name" field, enter a name for your function (e.g., github-pr-slack).

In the "Runtime" dropdown, select "Python 3.8" (or a newer version if available).

Under "Function code", choose "Upload from" and select ".zip file" from the dropdown. Prepare a .zip file containing your lambda_function.py file and any dependencies (e.g., requests library). To do this, you can use the following command:


pip install requests -t ./lambda_package
cp lambda_function.py ./lambda_package
cd lambda_package
zip -r ../lambda_function.zip .

Upload the lambda_function.zip file using the "Upload" button.

Under the "Execution role" section, choose "Create a new role with basic Lambda permissions". AWS will automatically create an IAM role with basic execution permissions for your Lambda function.

Click on the "Create function" button at the bottom of the page.

Once the function is created, scroll down to the "Function code" section and click on "Edit" to make any changes to your code if needed.

Scroll down to the "Environment variables" section and click on "Edit". Add a new environment variable with the key SLACK_WEBHOOK_URL and set its value to your Slack webhook URL.

Scroll up to the "Designer" section and click on the "Add trigger" button. Select "API Gateway" from the list of available triggers.

In the "API" dropdown, select "Create a new API" and choose "HTTP API" for the API type. Keep the security setting as "Open" for testing purposes (you can secure it later).

Click on the "Add" button to create the API Gateway trigger.

You should now see the API Gateway trigger in the "Designer" section. Click on it to see the details, including the "Invoke URL", which is the endpoint you'll use as your webhook in your GitHub repository.

Now your Lambda function is set up and ready to process incoming requests. You can follow the previous instructions in my answer to set up the webhook in your GitHub repository and point it to the "Invoke URL" of the API Gateway trigger.

This Lambda function handles incoming webhook requests from GitHub and sends the relevant PR details to your Slack channel when a PR is merged or reverted. Remember to set the SLACK_WEBHOOK_URL environment variable in the AWS Lambda console.


## 3. Add API gaeway webhook to Github

Go to the GitHub page of the repository you want to add the webhook to.
Click on the "Settings" tab.
In the left sidebar, click on "Webhooks".
Click on the "Add webhook" button.
In the "Payload URL" field, enter the API Gateway webhook URL you've created earlier.
Set the "Content type" to "application/json".
Under the "Which events would you like to trigger this webhook?" section, choose "Let me select individual events" and select "Pull requests".
Make sure the "Active" checkbox is checked.
Click on the "Add webhook" button to save the webhook.
