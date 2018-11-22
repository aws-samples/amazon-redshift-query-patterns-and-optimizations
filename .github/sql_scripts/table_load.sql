/********************************************************************************************************
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
********************************************************************************************************/

/****************************************************************************************************************************
PRE-REQUISITES
--------------
1. Update this file to replace the IAM role 'arn:aws:iam::413094830157:role/myRedshiftRole3' with your account specific role ARN.
2. From SQL client login into the cluster as "rsadmin" user and execute the below COPY commands
****************************************************************************************************************************/

set wlm_query_slot_count to 3; 
copy demo_local.orders_nocomp from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' compupdate off gzip;

set wlm_query_slot_count to 3; 
copy demo_local.lineitem_nocomp from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' compupdate off gzip;

set wlm_query_slot_count to 3; 
copy demo_local.orders_comp from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.lineitem_comp from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' gzip;

set wlm_query_slot_count to 3; 
copy demo_local.orders from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3;
copy demo_local.lineitem from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3'  delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.orders_base from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3;
copy demo_local.lineitem_base from 's3://tpcdhawspsa/10gb/splitfiles/slices=8/lineitems' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3'  delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.orders_mergekey from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3;
copy demo_local.lineitem_mergekey from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3'  delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.customer_base from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/customer/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.customer_distall from 's3://tpcdhawspsa/100gb/splitfiles/slices=32/customer/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

