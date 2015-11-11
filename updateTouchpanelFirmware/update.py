#!/usr/bin/env python
#update.py
from datetime import datetime
from elasticsearch import Elasticsearch,RequestsHttpConnection

host='192.168.99.100'
port='32781'
#url = 'http://{0}:{1}/devices/touchpanel/_search'.format(host,port)
es = Elasticsearch(host='192.168.99.100',port='32781')
res = es.get(index="devices", doc_type='touchpanel', id=1)

print(res['_source']['IPConfig']['IPAddress'])

