
import boto3, sys

def main():
    sqs = boto3.resource('sqs')
    queue_name = sys.argv[1]
    queue = sqs.get_queue_by_name(QueueName=queue_name)

    response = queue.send_message(MessageBody='world')

    message_id = response.get('MessageId')


if __name__ == '__main__':
    main()
