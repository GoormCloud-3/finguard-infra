import boto3
import os

ssm = boto3.client("ssm")
sqs = boto3.client("sqs")

queue_url = None  # 전역 캐시
param_name = "/finguard/finance/trade-queue-url"

def get_queue_url():
    global queue_url
    if queue_url is not None:
        return queue_url

    
    #if not param_name:
    #    raise Exception("QUEUE_URL_PARAM 환경변수가 필요합니다")

    resp = ssm.get_parameter(Name=param_name)
    queue_url = resp["Parameter"]["Value"]
    return queue_url


def handler(event, context):
    action = event.get("action")
    message = event.get("message")
    print(event)

    url = get_queue_url()

    if action == "send":
        response = sqs.send_message(
            QueueUrl=url,
            MessageBody=message or "default message",
            MessageGroupId="default"
        )
        return {"statusCode": 200, "body": f"Message sent: {response['MessageId']}"}

    elif action == "receive":
        response = sqs.receive_message(
            QueueUrl=url,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=3
        )
        messages = response.get("Messages", [])
        if not messages:
            return {"statusCode": 200, "body": "No messages found"}

        msg = messages[0]
        return {
            "statusCode": 200,
            "body": f"Received message: {msg['Body']}",
            "receiptHandle": msg["ReceiptHandle"]
        }

    elif action == "delete":
        receipt_handle = event.get("receiptHandle")
        if not receipt_handle:
            return {"statusCode": 400, "body": "Missing receiptHandle for delete"}

        sqs.delete_message(
            QueueUrl=url,
            ReceiptHandle=receipt_handle
        )
        return {"statusCode": 200, "body": "Message deleted"}

    return {"statusCode": 400, "body": "Unsupported action"}