import boto3
import json


def get_volume_id_from_arn(volume_arn):
    arn_parts = volume_arn.split(':')
    volume_id = arn_parts[-1].split('/')[-1]
    return volume_id


def lambda_handler(event, context):
    # Retrieve the volume ID from the CloudWatch Event
    volume_arn = event['resources'][0]
    volume_id = get_volume_id_from_arn(volume_arn)

    # Convert the volume type from gp2 to gp3
    ec2_client = boto3.client('ec2')
    response = ec2_client.modify_volume(
        VolumeId=volume_id,
        VolumeType='gp3'
    )

    print(f"Volume {volume_id} converted to gp3")
