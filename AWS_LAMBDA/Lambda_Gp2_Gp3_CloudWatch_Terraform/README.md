# Convert gp2 Volumes to gp3 using CloudWatch Events and Lambda

This project demonstrates how to use AWS CloudWatch Events and Lambda to automatically convert newly created gp2 EBS volumes to gp3. By leveraging CloudWatch Events, you can monitor the creation of gp2 volumes and trigger a Lambda function to convert them to gp3.

## Prerequisites

Before getting started, ensure you have the following prerequisites:

- AWS CLI configured with access keys and the desired AWS region.
- Terraform installed locally.
- Basic knowledge of AWS services such as CloudWatch Events, Lambda, and EC2.

## Deployment Steps

To deploy this project, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/unplugged-kk/DevopsWKishore.git

2. Navigate to the project directory:
   cd AWS_LAMBDA/Lambda_Gp2_Gp3_CloudWatch_Terraform/

3. Update the Terraform variables:

   Open the terraform.tfvars file.
   Modify the values according to your requirements.
   Save and close the file.
4. Initialize Terraform:
   ```
   terraform init   
   ```
5. Deploy the infrastructure:
    ```
   terraform apply
   ```
   Confirm the deployment by typing yes when prompted.
6. Wait for Terraform to finish creating the resources. Once completed, you should see the output      containing the CloudWatch Event rule and Lambda function ARNs. 

7. Test the setup:
   - Create a new gp2 EBS volume in your AWS account.
   - Check the Lambda function logs in the AWS CloudWatch console.
   - The Lambda function should be triggered and convert the volume from gp2 to gp3.

## Cleanup

To clean up and remove the resources created by this project, run:   
Confirm the destruction by typing yes when prompted.

## Customization

You can customize this project according to your requirements:

Modify the Lambda function code:

- Open the lambda_function/lambda_function.py file.
- Update the lambda_handler function as needed.
- Save and close the file.

Update the Terraform variables:

- Open the terraform.tfvars file.
- Modify the variables to match your desired configurations.
- Save and close the file.
- Adjust any other Terraform configurations or AWS resources as necessary.


