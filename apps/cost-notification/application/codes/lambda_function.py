import os
import boto3
import requests
import logging
from datetime import datetime, timedelta, date
from boto3.dynamodb.types import TypeDeserializer


logger = logging.getLogger()

COST_METRICS_VALUE = os.getenv("COST_METRICS_VALUE")
SETTINGS_TABLE = os.getenv("SETTINGS_TABLE")


def lambda_handler(event, context) -> None:

    total_billing = get_total_billing()
    logger.info('total_billing: %s' % (total_billing))

    title = get_message(total_billing)
    logger.info('title: %s' % (title))
    line_access_token = get_token()
    response = post_line(title, line_access_token)
    logger.info('response: %s' % (response))


def get_total_billing() -> dict:
    client = boto3.client('ce', region_name='us-east-1')

    (start_date, end_date) = get_total_cost_date_range()

    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ce.html#CostExplorer.Client.get_cost_and_usage
    response = client.get_cost_and_usage(
        TimePeriod={
            'Start': start_date,
            'End': end_date
        },
        Granularity='MONTHLY',
        Metrics=[
            COST_METRICS_VALUE
        ]
    )
    return {
        'start': response['ResultsByTime'][0]['TimePeriod']['Start'],
        'end': response['ResultsByTime'][0]['TimePeriod']['End'],
        'billing': response['ResultsByTime'][0]['Total'][COST_METRICS_VALUE]['Amount'],
    }


def get_message(total_billing: dict) -> (str):
    start = datetime.strptime(total_billing['start'], '%Y-%m-%d').strftime('%m/%d')

    end_today = datetime.strptime(total_billing['end'], '%Y-%m-%d')
    end_yesterday = (end_today - timedelta(days=1)).strftime('%m/%d')

    total = round(float(total_billing['billing']), 3)

    title = f'{start}～{end_yesterday}の請求額は、{total:.3f} USDです。'
    return title


def get_token() -> str:
    deserializer = TypeDeserializer()
    dynamodb = boto3.client('dynamodb')
    options = {
        'TableName': SETTINGS_TABLE,
        'Key': {
            'type': {'S': 'line_access_token'},
        }
    }
    raw_responce = dynamodb.get_item(**options)
    print(raw_responce)
    conved_responce = {
        k: deserializer.deserialize(v)
        for k, v in raw_responce['Item'].items()
    }
    line_access_token = conved_responce.get('value')
    print(line_access_token)
    return line_access_token


def post_line(title: str, line_access_token: str) -> None:
    # LINE Notify API
    # https://notify-bot.line.me/doc/ja/

    url = "https://notify-api.line.me/api/notify"
    headers = {"Authorization": "Bearer %s" % line_access_token}
    data = {'message': f'{title}'}

    try:
        response = requests.post(url, headers=headers, data=data)
        return response
    except requests.exceptions.RequestException as e:
        logger.exception(e)


def get_total_cost_date_range() -> (str, str):
    start_date = get_begin_of_month()
    end_date = get_today()

    if start_date == end_date:
        end_of_month = datetime.strptime(start_date, '%Y-%m-%d') + timedelta(days=-1)
        begin_of_month = end_of_month.replace(day=1)
        return begin_of_month.date().isoformat(), end_date
    return start_date, end_date


def get_begin_of_month() -> str:
    return date.today().replace(day=1).isoformat()


def get_today() -> str:
    return date.today().isoformat()
