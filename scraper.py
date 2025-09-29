#!/usr/bin/env python3
#
# Discord message retriever
import requests
import json

def retrieve_messages(channelid):
    num = 0
    limit = 10

    headers = {
        'authorization': '<redacted>'
    }

    last_message_id = None

    while True:
        query_parameters = f'limit={limit}'
        if last_message_id is not None:
            query_parameters += f'&before={last_message_id}'

        r = requests.get(
            f'https://discord.com/api/v9/channels/{channelid}/messages?{query_parameters}',headers=headers
            )
        jsonn = json.loads(r.text)
        if len(jsonn) == 0:
            break

        print(jsonn)
        break

    print('number of messages we collected is',num)

retrieve_messages('<redacted>')
