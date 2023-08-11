import json
import os

import boto3


def lambda_handler(event, _context):
    body = json.loads(event["body"])
    region = os.environ["REGION"]
    start_time = body["start_time"]
    end_time = body["end_time"]
    ec2_server_id = body["ec2_instances_id"]
    scheduler = boto3.client('scheduler', region_name=region)
    scheduler.create_schedule(
        ActionAfterCompletion="DELETE",
        FlexibleTimeWindow={"Mode": "OFF"},
        Name="ec2-schedule-start-" + str(ec2_server_id),
        ScheduleExpression="at(" + start_time + ")",
        ScheduleExpressionTimezone="Europe/Paris",
        Target={
            "Arn": os.environ["START_EC2_LAMBDA_ARN"],
            "RoleArn": os.environ["EXECUTE_SCHEDULE_ROLE_ARN"],
            "Input": "{\"instances\": [\"" + ec2_server_id + "\"]}"
        },

    )

    scheduler.create_schedule(
        ActionAfterCompletion="DELETE",
        FlexibleTimeWindow={"Mode": "OFF"},
        Name="ec2-schedule-stop-" + str(ec2_server_id),
        ScheduleExpression="at(" + end_time + ")",
        ScheduleExpressionTimezone="Europe/Paris",
        Target={
            "Arn": os.environ["STOP_EC2_LAMBDA_ARN"],
            "RoleArn": os.environ["EXECUTE_SCHEDULE_ROLE_ARN"],
            "Input": "{\"instances\": [\"" + ec2_server_id + "\"]}"
        },
    )

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'success': True
        }),
        "isBase64Encoded": False
    }
