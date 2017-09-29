# -*- coding: utf-8 -*-

import os
import sys
from platform import python_version
print('Python', python_version())
from requests_oauthlib import OAuth1Session
from datetime import datetime
from datetime import time


CK = os.environ["CKFOR334"]
CS = os.environ["CSFOR334"]
AT = os.environ["ATFOR334"]
AS = os.environ["ASFOR334"]

# ツイート投稿用のURL
url = "https://api.twitter.com/1.1/statuses/update.json"

# OAuth認証
twitter = OAuth1Session(CK, CS, AT, AS)
# ツイート本文  POST method で投稿

while True:
    now = datetime.now()
    if (now.hour == 3 and now.minute == 34): # and now.second == 59 and now.microsecond >=999980):
        params = {"status": "334 "+str(now)}
        req = twitter.post(url, params = params)
        print(datetime.now())
        break

# レスポンスを確認
if req.status_code == 200:
    print ("OK")
else:
    print ("Error: %d" % req.status_code)
