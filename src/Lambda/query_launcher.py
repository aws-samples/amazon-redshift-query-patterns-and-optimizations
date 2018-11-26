#!/usr/bin/env python

from __future__ import print_function

#Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.

#Permission is hereby granted, free of charge, to any person obtaining a copy of this
#software and associated documentation files (the "Software"), to deal in the Software
#without restriction, including without limitation the rights to use, copy, modify,
#merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import sys
import boto3
import pg8000
import datetime
import random

#### Configuration

ssl = True

debug = True

##################
query_type_list = ['short_query', 'long_query']
    
def run_command(cursor, statement):
    if debug:
        print("Running Statement: %s" % statement)
        
    return cursor.execute(statement)

def lambda_handler(event, context):
    host = event['Host']
    port = event['Port']
    database = event['Database']
    user = event['User']
    password = event['Password']
    
    s3_bucket_name = "awspsa-redshift-lab"
    thread_num = 'THREAD%d' % random.randint(1, 1000000)
    print('Thread num %s' %thread_num)
    
    try:
        query_type_random = random.choice(query_type_list)
        print('query_type_random: %s' %query_type_random )
        query_list = ['a', 'b', 'c']
        query_random = random.choice(query_list)
        s3_object_key = 'scripts/' + query_type_random + '/' + query_random + '/demo-query.sql' 
        print('s3 object key: %s' %s3_object_key )
        
        s3 = boto3.resource('s3')
        obj = s3.Object(s3_bucket_name, s3_object_key)
        query_str = obj.get()['Body'].read().decode('utf-8') 
        print(query_str)
	  
    except:
        print('Reading from s3 failed: exception %s' % sys.exc_info()[1])

    pg8000.paramstyle = "qmark"

    try:
        if debug:
            #print('Password is %s' %password)
            print('Connect to Redshift: %s' % host)
        conn = pg8000.connect(database=database, user=user, password=password, host=host, port=port, ssl=ssl)
    except:
        print('Redshift Connection Failed: exception %s' % sys.exc_info()[1])
        return 'Failed'

    if debug:
        print('Succesfully Connected Redshift Cluster')
    cursor = conn.cursor()
    
    start = datetime.datetime.now()
    print('Starttime of query: %s' % start.strftime('%Y-%m-%dT%H:%M:%S'))
    
    if query_type_random == 'long_query':
        sql_setquerygroup = 'set query_group to biextract'
        run_command(cursor, sql_setquerygroup)
    
    sql_cache_off = 'set enable_result_cache_for_session to off'
    run_command(cursor, sql_cache_off)
    run_command(cursor, query_str)
    #result = cursor.fetchall()
    end = datetime.datetime.now()
    print('Endtime of query: %s' % end.strftime('%Y-%m-%dT%H:%M:%S'))
    delta = end - start
    print('Time taken to execute: %s ' % delta)
    
           
    if debug:
        print("Publishing CloudWatch Metrics")
    
    cursor.close()
    conn.close()
    return 'Finished'

if __name__ == "__main__":
    lambda_handler(sys.argv[0], None)
