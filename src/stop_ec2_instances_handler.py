import os

import boto3


def lambda_handler(event, _context):
    region = os.environ["REGION"]
    ec2 = boto3.client('ec2', region_name=region)
    ec2.stop_instances(InstanceIds=event["instances"])
    for instance in event["instances"]:
        print('Stopped your instances: ' + instance)
