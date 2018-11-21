/****************************************************************************************************************************
PRE-REQUISITES
--------------
1. Update this file to replace the IAM role 'arn:aws:iam::413094830157:role/myRedshiftRole3' with your account specific role ARN.
2. Download the dataset from github and upload into an s3 bucket in your AWS account.
3. Update this file to point to the s3 location
4. From SQL client login into the cluster as "rsadmin" user and execute the below COPY commands
****************************************************************************************************************************/

set wlm_query_slot_count to 3; 
copy demo_local.orders_nocomp from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' compupdate off gzip;

set wlm_query_slot_count to 3; 
copy demo_local.lineitem_nocomp from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' compupdate off gzip;

set wlm_query_slot_count to 3; 
copy demo_local.orders_comp from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.lineitem_comp from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|' gzip;

set wlm_query_slot_count to 3; 
copy demo_local.orders from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3;
copy demo_local.lineitem from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3'  delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.orders_base from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3;
copy demo_local.lineitem_base from 's3://<your_s3_bucket>/10gb/splitfiles/slices=8/lineitems' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3'  delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.orders_mergekey from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/orders/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3;
copy demo_local.lineitem_mergekey from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/lineitems/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3'  delimiter '|' gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.customer_base from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/customer/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

set wlm_query_slot_count to 3; 
copy demo_local.customer_distall from 's3://<your_s3_bucket>/100gb/splitfiles/slices=32/customer/gzip' iam_role 'arn:aws:iam::413094830157:role/myRedshiftRole3' delimiter '|'  gzip ;

