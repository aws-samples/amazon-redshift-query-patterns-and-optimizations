## Amazon Redshift Query Patterns And Optimizations

In this workshop you will launch an Amazon Redshift cluster in your AWS account and load sample data ~ 100GB using TPCH dataset. You will learn query patterns that affects Redshift performance and how to optimize them. In this lab we will also provide a framework to simulate workload management (WLM) queue and run concurrent queries in regular interval and measure performance metrics- query throughput, query duration etc. We will also provide some use cases for Redshift spectrum to query data from s3 in columnar format such as Parquet.

## License Summary

This sample code is made available under a modified MIT license. See the LICENSE file.

# Lab 1: Launch cluster
Two options mentioned here to launch the Amazon Redshift cluster; both options require to have your own AWS account. The options are
* **Option 1 (Launch cluster from scratch)**
Pre-requisite for this option is to have VPC, Public Subnet, Cluster Parameter Group to be created.
In this option you will-
  * Launch the cluster using AWS Redshift console.
  * Create tables and load data from your s3 bucket.
  
* **Option 2 (Restore cluster from snapshot)**
You will restore from a cluster snapshot which has already data loaded.

Both the options require you to have a SQL client to work with the Redshift cluster.

## Download and install SQL client
 * You will need Java 8 or higher running on your computer. If you need Java, download and install from http://www.java.com/en/
 * Download the current Redshift JDBC Driver from https://s3.amazonaws.com/redshift-downloads/drivers/RedshiftJDBC42-1.2.10.1009.jar
 * For executing SQLs on this cluster you need a SQL client that works with Amazon Redshift. Please refer to https://docs.aws.amazon.com/redshift/latest/mgmt/connecting-via-client-tools.html for the client tools you can download and install.
  
  Note: For accessing the cluster through GUI you can use SQL Workbench/J, make sure to click on Manage Drivers (in the lower left corner of the configuration screen) and choose Amazon Redshift and the JDBC Driver you downloaded earlier.
 * At the end of the installation it will be ready to connect to a database – **stop when you get this step, as you have not yet configured a database to use!**
 
## Option 1 (Launch cluster from scratch)

### Create the IAM role you will need to copy S3 objects to Redshift
 * Log on to the AWS console using your student account. Choose the AWS region assigned by your instructor.
 * Choose the **IAM** service
 * In the left navigation pane, choose **Roles**.
 * Choose **Create role**.
 * In the AWS Service pane, choose **Redshift** and from bottom of the screen select **Redshift - Customizable**.
* Under Select your use case, choose Redshift - Customizable then choose **Next: Permissions**.
* On the Attach permissions policies page, check the box next to **AmazonS3ReadOnlyAccess, AWSGlueServiceRole** and then choose **Next: Review**.
* For Role name, type a name for your role. For this lab, use *myRedshiftRole*, then choose **Create Role**.
* Once the role is created, click on *myRedshiftRole*.
* Note the Role ARN—this is the Amazon Resource Name (ARN) for the role that you just created. You will need this later.

### Create a Redshift cluster
* From the AWS Console, choose the Amazon Redshift service.
* Change the region to US East (Viginia)
* Choose **Launch Cluster**
* On the Cluster Details page, enter the following values and then choose **Continue:**
* Cluster Identifier: type *democluster*.
* Database Name: type *demodb*.
* Database Port: type *8192*
* Master User Name: type *rsadmin*. You will use this username and password to connect to your database after the cluster is available.
* Master User Password and Confirm Password: type a password for the master user account. Be sure to follow the rules for passwords. Don’t forget your password (!), and choose Continue
* Create a 2 node cluster using ds2.xl and choose Continue
  * Node type : ds2.xl
  * Cluster type : Multi Node
  * Number of compute nodes : 4 (type in)
* On the Additional Configuration page, use the default VPC and the default Security Group. Leave other settings on their defaults.
* For **AvailableRoles**, choose *myRedshiftRole* and then choose **Continue.**
* On the Review page, double-check your choices and choose Launch Cluster. Choose Close to return to the Clusters dashboard.

### Authorize your access to the Redshift cluster, by adding a rule to your Security Group
* On the Clusters dashboard, click on *democluster*.
* Scroll down to find your VPC security groups. Click on your active security group.
* On the Security Group pane, click on **Inbound**.
* Choose **Edit**, then **Add Rule**.
* Assign a **Type** of **TCP/IP**, and enter the port range to *8192*.
* Assign a **Source** of **Custom** and set the CIDR block to *0.0.0.0/0*. Choose **Save**. 

[Note: this allows access to your Redshift cluster from any computer on the Internet. Never do this in a production environment!!!] 

### Connect to your Redshift cluster using SQL Workbench/J (Optional)
* From the AWS Console, choose the Amazon Redshift service, then choose **Clusters** and click on *democluster*.
* Scroll down to the JDBC URL. This is your connection string. Copy it. It should look something like: ```jdbc:redshift://democluster.cdkituczqepk.us-east-1.redshift.amazonaws.com:8192/demodb```
* Open SQL Workbench/J. Choose File, and then choose Connect window. Choose Create a new connection profile.
* In the New profile text box, type a name for the profile.
* In the Driver box, choose Amazon Redshift (If the Redshift driver is red, then download and update the driver from, https://docs.aws.amazon.com/redshift/latest/mgmt/configure-jdbc-connection.html#download-jdbc-driver)
* In the URL box, paste the connection string you copied earlier.
* In the Username box, type *rsadmin*
* In the Password box, type the password you chose when you created the Redshift cluster.

IMPORTANT: be sure to click to Autocommit box
* Choose Test. If there are any error messages, do what you need to fix them. If the test succeeds, choose OK.

## Option 2 (Restore cluster from snapshot)
You will use the cloudformation template file available in this github. This Cloudformation template will create a VPC and create few more resources including the Redshift cluster in that VPC. 

**!! You will need to have a copy of the Redshift snapshot "rslab-ds2-xl-4n" in your AWS account. Please request access for the snapshot.!!**

* Login to AWS console in the AWS account in which you want to onboard your cluster and switch to the correct region.
* (Optional) Create new KMS Key or use existing "aws/redshift" KMS key. Copy KMS Key ID into your notepad.
* Download the github cloudformation template file **[redshift_vpc_glue.yaml](https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/blob/master/src/CloudFormation/redshift_vpc_glue.yml)** and save it in your local system.
* Navigate to **CloudFormation > Stacks > Create stack** . In the **Create stack** page under **Specify template** section  select **Upload a template file** and then Choose file from your local system.
* Click **Next**
* Enter Stack name: *rsLab*
* Enter TagEnviornment: *Development*
* Enter DatabaseName: *rsdev01*
* Enter MasterUserName: *rsadmin*
* Enter MasterUserPassword: Welcome_123
* Choose ClusterType: *multi-node*
* Choose NumberOfNodes: *4*
* Choose NodeType: *ds2.xlarge*
* Choose PortNumber: *8192*
* Enter SubscriptionEmail: (your email)

(No need to change Other parameters, unless you want)
* Click *Next*
* Create Tag(s) 
    Options -\> Tags
 	  Enter Key -\> Owner
 	  Enter Value -\>  <your email alias>
    Note: Optionally you can create one more tags, if you want.
* Enable Termination protection 
  Click Advanced -\> 
   Termination protection  -\> 
      select radio button **Enabled**
        -\> **Next**
* Select checkbox against "I acknowledge that AWS CloudFormation might create IAM resources with custom names."
* Click *Create*
* You can monitor the progress of Stack resources
* Choose your stack
* Click on **Events**, **Resources** & **Outputs** tabs
 
 
 # Lab 2: Table design and query optimization
If you have decided to choose option 1 for launching the cluster you will need to execute the scripts [schema_setup.sql](https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/blob/master/sql_scripts/schema_setup.sql)  and [table_load.sql](https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/blob/master/sql_scripts/table_load.sql) first. 

**!!Note: the pre-requisite in the script files table_load.sql before proceeding.**

For option 2 this is not needed.

The [query_patterns_optimization.sql](https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/blob/master/sql_scripts/query_patterns_optimization.sql) script has queries that you can run one after another. There are few query patterns which are optimized progressively as you progress through the script.

The optimization techniques follow the best practices described in [Amazon Redshift Best Practices](https://docs.aws.amazon.com/redshift/latest/dg/best-practices.html). The example queries are-

### Tables built with compression, sortkey and distkey
```sql
--orders and lineitems tables  WITH compression, distribution style and sort keys
set enable_result_cache_for_session to off;
SELECT
    l_shipmode,
    sum(case
        when o_orderpriority = '1-URGENT'
            OR o_orderpriority = '2-HIGH'
            then 1
        else 0
    end) as high_line_count,
    sum(case
        when o_orderpriority <> '1-URGENT'
            AND o_orderpriority <> '2-HIGH'
            then 1
        else 0
    end) AS low_line_count
FROM
    demo_local.orders,
    demo_local.lineitem
WHERE
    o_orderkey = l_orderkey
    AND l_shipmode in ('AIR', 'SHIP', 'MAY')
    AND l_commitdate < l_receiptdate
    AND l_shipdate < l_commitdate
    AND l_receiptdate >= date '1992-01-01'
    AND l_receiptdate < date '1996-01-01' + interval '1' year
GROUP BY
    l_shipmode
ORDER BY
    l_shipmode;
 ```
### Sortkey and distkey columns are same for tables used in JOINs frequently
```sql
EXPLAIN
SELECT
    l_shipmode,
    sum(case
        when o_orderpriority = '1-URGENT'
            OR o_orderpriority = '2-HIGH'
            then 1
        else 0
    end) as high_line_count,
    sum(case
        when o_orderpriority <> '1-URGENT'
            AND o_orderpriority <> '2-HIGH'
            then 1
        else 0
    end) AS low_line_count
FROM
   demo_local.orders_mergekey,
   demo_local.lineitem_mergekey
WHERE
    o_orderkey = l_orderkey
    AND l_shipmode in ('AIR', 'SHIP')
    AND l_commitdate < l_receiptdate
    AND l_shipdate < l_commitdate
    AND l_receiptdate >= date '1992-01-01'
    AND l_receiptdate < date '1996-01-01' + interval '1' year
GROUP BY
    l_shipmode
ORDER BY
    l_shipmode;
```

### Query pattern: EXISTS clause 
```sql
EXPLAIN
SELECT cntrycode, 
       Count(*) AS numcust, 
       Sum(c_acctbal) AS totacctbal 
FROM   (SELECT Substring(c_phone FROM 1 FOR 2) AS cntrycode, 
               c_acctbal 
        FROM   demo_local.customer_base 
        WHERE  Substring(c_phone FROM 1 FOR 2) IN ( '13', '31', '23', '29', '30', '18', '17') 
               AND c_acctbal > (SELECT Avg(c_acctbal) 
                                FROM   demo_local.customer_base 
                                WHERE  c_acctbal > 0.00 
                                       AND Substring (c_phone FROM 1 FOR 2) IN ( 
                                           '13', '31', '23', '29','30', '18', '17' )) 
               AND NOT EXISTS (SELECT * 
                               FROM   demo_local.orders_mergekey 
                               WHERE  o_custkey = c_custkey)) AS custsale 
GROUP  BY cntrycode 
ORDER  BY cntrycode;
```
```sql
EXPLAIN 
SELECT cntrycode, 
       Count(*) AS numcust, 
       Sum(c_acctbal) AS totacctbal 
FROM   (SELECT Substring(c_phone FROM 1 FOR 2) AS cntrycode, 
               c_acctbal 
        FROM   demo_local.customer_base LEFT JOIN demo_local.orders_mergekey ON o_custkey = c_custkey
        WHERE  Substring(c_phone FROM 1 FOR 2) IN ( '13', '31', '23', '29', '30', '18', '17') 
               AND c_acctbal > (SELECT Avg(c_acctbal) 
                                FROM   demo_local.customer_base 
                                WHERE  c_acctbal > 0.00 
                                       AND Substring (c_phone FROM 1 FOR 2) IN ( 
                                           '13', '31', '23', '29','30', '18', '17' )) 
--               AND NOT EXISTS (SELECT * 
--                               FROM   demo_local.orders_mergekey 
--                               WHERE  o_custkey = c_custkey)) AS custsale 
               AND o_custkey IS NULL
		)
GROUP  BY cntrycode 
ORDER  BY cntrycode; 
```
### Query pattern: Analytical query 

```sql
EXPLAIN
select cust.c_nationkey, count(ord.o_orderkey), sum(ord.o_totalprice) from demo_local.orders_mergekey ord join demo_local.customer_base cust on ord.o_custkey = cust.c_custkey
where c_mktsegment = 'HOUSEHOLD' 
and o_totalprice > (select median(o_totalprice) from demo_local.orders_mergekey join demo_local.customer_base on o_custkey = c_custkey where c_mktsegment = 'HOUSEHOLD' )
group by 1
limit 10;
```

```sql
EXPLAIN
select c_nationkey, count(c_nationkey), sum(o_totalprice)
from
(
select cust.c_nationkey, ord.o_totalprice
, median(o_totalprice) over( partition by c_mktsegment ) median_price
from demo_local.orders_mergekey ord join demo_local.customer_base cust on ord.o_custkey = cust.c_custkey
where c_mktsegment = 'HOUSEHOLD' 
)
where o_totalprice > median_price
group by c_nationkey
limit 10;
```
```sql
EXPLAIN
select c_nationkey, count(c_nationkey), sum(o_totalprice)
from
(
select cust.c_nationkey, ord.o_totalprice
, median(o_totalprice) over( partition by c_mktsegment ) median_price
from demo_local.orders_mergekey ord join demo_local.customer_distall cust on ord.o_custkey = cust.c_custkey
where c_mktsegment = 'HOUSEHOLD' 
)
where o_totalprice > median_price
group by c_nationkey
limit 10;
```

# Lab 3: WLM efficiency

In this lab you will launch AWS resources to emulate concurrent query execution in the Amazon Redshift cluster you launched in lab 1. Using the launched infrastructure you will be able to tune the WLM setting according to your need.

The following steps will create a AWS Step Function State Machine and a AWS Lambda function in your AWS account. The State Machine can be scheduled from AWS CloudWatch to launch concurrent queries- a mix of long and short running queries, in your Redshift cluster. After a few minutes of execution of the State Machine you can watch the Query Throughput and Query Duration metrics in the Database Performance dashboard. 

## Setup

Go to an s3 bucket in your account and create the following folders. You will need to the s3 bucket name for creating CloudWatch schedule based event.

```
<mybucket>/querylauncher/lambda-code/wlm/
<mybucket>/querylauncher/scripts/long_query/
<mybucket>/querylauncher/scripts/short_query/
```

Once the above folders are created upload the following files from the github-

<mybucket>/querylauncher/scripts/long_query/  --> https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/tree/master/sql_scripts/long_query
 
<mybucket>/querylauncher/scripts/short_query/ --> https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/tree/master/sql_scripts/short_query
 
<mybucket>/querylauncher/lambda-code/wlm/     --> https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/blob/master/src/Lambda/query_launcher.zip

## Install Query Launcher
Following steps will create AWS Step function State Machine and AWS Lambda function in your AWS account. The State machine will later will be scheduled in CloudWatch events as scheduled rule.

* Login to AWS console in the AWS account where you have launched the Amazon Redshift cluster.
* Download the github cloudformation template file **[RedshiftWLMLambdaLauncher.yaml](https://github.com/aws-samples/amazon-redshift-query-patterns-and-optimizations/blob/master/src/CloudFormation/RedshiftWLMLambdaLauncher.yml)** and save it in your local system.
* Navigate to **CloudFormation > Stacks > Create stack** . In the **Create stack** page under **Specify template** section  select **Upload a template file** and then Choose the RedshiftWLMLambdaLauncher.yaml file from your local system.
* 	Click **Next** on the Select Template page.
* 	Enter **Stack name** example *StepFnLambda*. 
  * Enter the **S3Bucket** field where you have setup your s3 bucket that contains the Lambda code and SQL queries.
  * Enter the **S3Key** fot the location in the above s3 bucket where you have placed the query_launcher.zip file. It should be querylauncher/lambda-code/wlm/query_launcher.zip
  * Select the **SecurityGroups** from the dropdown. It should be starting as "rslab-LambdaSecurityGroup-" where "rslab" is the name of the cloudformation stack for Redshift launch cluster.
  * Select the **VPCSubnetIDs** as the Public Subnet 1 and 2 . These subnets are created during the Redshift launch cluster.
Hit **Next**.

```Note: The stack name you enter will appear as prefix of the AWS Lambda function name, IAM role for Lambda and Step Function State Machine that this template is going to create.```

* 	Enter the **Key** = Owner and **Value** = Your_NAME. Expand Advanced and enable Termination Protection. Click **Next**.
* 	Check the **I acknowledge that AWS CloudFormation might create IAM resources**." and click **Create**.
* 	Monitor the progress of cluster launch from "Cloudformation" service navigation page. Successful completion of the stack will be marked with the status = "**CREATE_COMPLETE**".
* 	At the end of successful execution of the stack four resources will get created which will be visible on Resources tab of the stack you just created. Click on the Physical ID of the resource of Type "AWS::StepFunctions::StateMachine". The Physical ID will look something like "*arn:aws:states:us-east-1:413094830157:stateMachine:LambdaStateMachine-BRcwDzke2wiW*".

## Schedule Query Launcher

Now you have the State machine is ready in your AWS account. You will need to schedule this state machine in regular interval so that it can launch concurrent queries in your Redshift cluster.

* Login to AWS console in the AWS account and go to "**Cloudwatch**" service.
* From the left navigation Click on **Rules** under **Events**. And then click on **Create rule**.
* Select **Schedule** as Event Source and make sure **Fixed rate of 5 Minutes** is set.
* Click on **Add Target** > **Step Functions state machine**. Select the state machine that starts with *LambdaStateMachine-*. Expand **Configure input** > **Constant (JSON text)**. In the text box enter below JSON text with the relevant value of your s3 bucket and Redshift cluster Host. Change the password.
```JSON
{
  "S3Bucket": "awspsalab",
  "Host": "rslab-redshiftcluster-17qvgq9ynjs8q.csdiadofcvnr.us-east-1.redshift.amazonaws.com",
  "Port": 8192,
  "Database": "awspsars",
  "Password": "Welcome123",
  "User": "labuser"
}
```
* Choose **Use existing role** and select the role created by the query launcher which should start with name "*StepFnLambda-StatesMachineExecutionRole-*". 
* Hit Configure details. Give a Name and Description.


# Lab 4: Redshift Spectrum

In this lab you will setup Redshift external schema and query external tables. You will also gain knowledge on some query patterns to optimize Redshift Spectrum.

## Create an external schema and external tables

You can run the below SQLs as-is by replacing with your AWS account number.
* \<Your-AWS-Account-Number\>: Replace with your AWS account number.

### Create external schema and catalog database
```sql
DROP SCHEMA IF EXISTS "spectrum";
CREATE EXTERNAL SCHEMA "spectrum" 
FROM DATA CATALOG 
DATABASE 'spectrumdb' 
iam_role 'arn:aws:iam::<Your-AWS-Account-Number>:role/rsLabGroupPolicy-SpectrumRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;
```
### Create external table (non-partitioned)
```sql
CREATE external table "spectrum"."suppliers_ext_parq" ( 
 s_suppkey BIGINT,
 s_name VARCHAR(128),
 s_address VARCHAR(128),
 s_nationkey BIGINT,
 s_phone VARCHAR(128),
 s_acctbal  DECIMAL(12,2),
 s_comment VARCHAR(128)
)
STORED AS PARQUET
LOCATION 's3://awspsa-redshift-lab/supplier/';
```
### Create partitioned table
The datafiles in s3 are in PARQUET format and Partitioned on L_SHIPDATE

```sql
CREATE EXTERNAL table "spectrum"."lineitem_parq_part_1" ( 
 L_ORDERKEY BIGINT,
 L_PARTKEY BIGINT,
 L_SUPPKEY BIGINT,
 L_LINENUMBER INT,
 L_QUANTITY DECIMAL(12,2),
 L_EXTENDEDPRICE DECIMAL(12,2),
 L_DISCOUNT DECIMAL(12,2),
 L_TAX DECIMAL(12,2),
 L_RETURNFLAG VARCHAR(128),
 L_LINESTATUS VARCHAR(128),
 L_COMMITDATE VARCHAR(128),
 L_RECEIPTDATE VARCHAR(128),
 L_SHIPINSTRUCT VARCHAR(128),
 L_SHIPMODE VARCHAR(128),
 L_COMMENT VARCHAR(128))
PARTITIONED BY (L_SHIPDATE VARCHAR(128))
STORED as PARQUET
LOCATION 's3://awspsa-redshift-lab/lineitem_partition/';
```

#### Add partitions in the table

```sql
ALTER TABLE  "spectrum"."lineitem_parq_part_1" 
ADD PARTITION(saledate='1992-01-02') 
LOCATION 's3://awspsa-redshift-lab/lineitem_partition/l_shipdate=1992-01-02/';

ALTER TABLE  "spectrum"."lineitem_parq_part_1" 
ADD PARTITION(saledate='1992-01-03') 
LOCATION 's3://awspsa-redshift-lab/lineitem_partition/l_shipdate=1992-01-03/';
```
#### List the partitions of the table

```sql
SELECT schemaname, tablename, values, location 
FROM svv_external_partitions
WHERE tablename = 'lineitem_parq_part_1' and schemaname='spectrum'
```



## Query external tables
After your external table is created, you can query using the same SELECT statement that you use to query other regular Amazon Redshift tables.  The SELECT statement queries can include joining tables, aggregating data, and filtering on predicates

```sql
SELECT s_nationkey, count(*)
FROM "spectrum"."suppliers_ext_parq"
WHERE s_nationkey in (10,15,20) and s_acctbal > 1000
GROUP BY s_nationkey;

SELECT MIN(L_SHIPDATE), MAX(L_SHIPDATE), count(*)
FROM "spectrum"."lineitem_parq_part_1";
```

### How to check whether "[partition-pruning](https://aws.amazon.com/blogs/big-data/10-best-practices-for-amazon-redshift-spectrum/)" is in effect?
You can use the following SQL to analyze the effectiveness of partition pruning. If the query touches only a few partitions, you can verify if everything behaves as expected:
```SELECT query, segment,
       MIN(starttime) AS starttime,
       MAX(endtime) AS endtime,
       datediff(ms,MIN(starttime),MAX(endtime)) AS dur_ms,
       MAX(total_partitions) AS total_partitions,
       MAX(qualified_partitions) AS qualified_partitions,
       MAX(assignment) as assignment_type
FROM svl_s3partition
WHERE query=pg_last_query_id()
GROUP BY query, segment;
```
### Join Redshift local table with external table
As a best practice, keep your larger fact tables in Amazon S3 and your smaller dimension tables in Amazon Redshift.  Let’s see how that works.

#### Create the EVENT table by using the following command
```sql
CREATE TABLE event(
eventid integer not null distkey,
venueid smallint not null,
catid smallint not null,
dateid smallint not null sortkey,
eventname varchar(200),
starttime timestamp
);
```
#### Load the EVENT table by replacing your AWS account number

```sql
copy event from 's3://awssampledbuswest2/tickit/allevents_pipe.txt' 
iam_role 'arn:aws:iam::<Your-AWS-Account-Number>:role/rsLabGroupPolicy-SpectrumRole'
delimiter '|' timeformat 'YYYY-MM-DD HH:MI:SS' region 'us-west-2';
```
#### Create External table SALES in Data Catalog.
```sql
create external table "spectrum"."sales"(
salesid integer,
listid integer,
sellerid integer,
buyerid integer,
eventid integer,
dateid smallint,
qtysold smallint,
pricepaid decimal(8,2),
commission decimal(8,2),
saletime timestamp
)
row format delimited
fields terminated by '\t'
stored as textfile
location 's3://awspsa-redshift-lab/sales/'
table properties ('numRows'='172000');
```

Below query is example of joining the external table SPECTRUM.SALES with the physically loaded local table – EVENT to find the total sales for the top ten events.
```sql
SELECT top 10 sales.eventid, sum(sales.pricepaid) 
FROM "spectrum"."sales" sales, event
WHERE sales.eventid = event.eventid
AND sales.pricepaid > 30
GROUP BY sales.eventid
ORDER BY 2 desc;
```

### Execution Plan of JOIN-ed SQL
View the query plan for the previous query. Note the *S3 Seq Scan*, *S3 HashAggregate*, and *S3 Query Scan* steps that were executed against the data on Amazon S3.
Look at the query plan to find what steps have been pushed to the Amazon Redshift Spectrum layer.

```sql
EXPLAIN
SELECT top 10 sales.eventid, sum(sales.pricepaid) 
FROM "spectrum"."sales" sales, public.event
WHERE sales.eventid = event.eventid
AND sales.pricepaid > 30
GROUP BY sales.eventid
ORDER BY 2 DESC;
```
Observations:
--

The S3 Seq Scan node shows the filter pricepaid > 30.00 was processed in the Redshift Spectrum layer.
A filter node under the XN S3 Query Scan node indicates predicate processing in Amazon Redshift on top of the data returned from the Redshift Spectrum layer.
The S3 HashAggregate node indicates aggregation in the Redshift Spectrum layer for the group by clause (group by spectrum.sales.eventid).



## Performance comparison between CSV, PARQUET and partitioned data

### Create CSV Table:
```sql
CREATE external table "spectrum"."lineitem_csv" 
( 
 L_ORDERKEY BIGINT,
 L_PARTKEY INT,
 L_SUPPKEY INT,
 L_LINENUMBER INT,
 L_QUANTITY DECIMAL(12,2),
 L_EXTENDEDPRICE DECIMAL(12,2),
 L_DISCOUNT DECIMAL(12,2),
 L_TAX DECIMAL(12,2),
 L_RETURNFLAG VARCHAR(128),
 L_LINESTATUS VARCHAR(128),
 L_SHIPDATE VARCHAR(128) ,
 L_COMMITDATE VARCHAR(128),
 L_RECEIPTDATE VARCHAR(128),
 L_SHIPINSTRUCT VARCHAR(128),
 L_SHIPMODE VARCHAR(128),
 L_COMMENT VARCHAR(128)
)
row format delimited
fields terminated by '|'
stored as textfile
LOCATION 's3://awspsa-redshift-lab/lineitem_csv/'
;
```
### Create Parquet format table
```sql
CREATE external table "spectrum"."lineitem_parq" 
( 
 L_ORDERKEY BIGINT,
 L_PARTKEY BIGINT,
 L_SUPPKEY BIGINT,
 L_LINENUMBER INT,
 L_QUANTITY DECIMAL(12,2),
 L_EXTENDEDPRICE DECIMAL(12,2),
 L_DISCOUNT DECIMAL(12,2),
 L_TAX DECIMAL(12,2),
 L_RETURNFLAG VARCHAR(128),
 L_LINESTATUS VARCHAR(128),
 L_SHIPDATE VARCHAR(128),
 L_COMMITDATE VARCHAR(128),
 L_RECEIPTDATE VARCHAR(128),
 L_SHIPINSTRUCT VARCHAR(128),
 L_SHIPMODE VARCHAR(128),
 L_COMMENT VARCHAR(128)
)
stored as PARQUET
LOCATION 's3://awspsa-redshift-lab/lineitem_parq2/'
;
```

### Create Parquet format Partitioned table
```sql
CREATE external table "spectrum"."lineitem_parq_part" 
( 
 L_ORDERKEY BIGINT,
 L_PARTKEY BIGINT,
 L_SUPPKEY BIGINT,
 L_LINENUMBER INT,
 L_QUANTITY DECIMAL(12,2),
 L_EXTENDEDPRICE DECIMAL(12,2),
 L_DISCOUNT DECIMAL(12,2),
 L_TAX DECIMAL(12,2),
 L_RETURNFLAG VARCHAR(128),
 L_LINESTATUS VARCHAR(128),
 L_COMMITDATE VARCHAR(128),
 L_RECEIPTDATE VARCHAR(128),
 L_SHIPINSTRUCT VARCHAR(128),
 L_SHIPMODE VARCHAR(128),
 L_COMMENT VARCHAR(128)
)
partitioned by (L_SHIPDATE VARCHAR(128))
stored as PARQUET
LOCATION 's3://awspsa-redshift-lab/lineitem_partition/'
;
```

### Run query on CSV table
```sql
SELECT MIN(L_SHIPDATE), MAX(L_SHIPDATE), count(*)
FROM "spectrum"."lineitem_csv";
```

### Run query on Parquet table
```sql
SELECT MIN(L_SHIPDATE), MAX(L_SHIPDATE), count(*)
FROM "spectrum"."lineitem_parq";
```
Verify rows & bytes returned and execution time of SQL. Get the Query ID from Redshift console or STV_RECENTS.

```sql
SELECT QUERY, 
SEGMENT, 
SLICE, 
DATEDIFF(MS,MIN(STARTTIME),MAX(ENDTIME)) AS DUR_MS, 
S3_SCANNED_ROWS, 
S3_SCANNED_BYTES, 
S3QUERY_RETURNED_ROWS, 
S3QUERY_RETURNED_BYTES, FILES
FROM SVL_S3QUERY 
WHERE query=pg_last_query_id()
--QUERY IN (52601, 52603) 
GROUP BY QUERY, SEGMENT, SLICE, S3_SCANNED_ROWS, S3_SCANNED_BYTES, S3QUERY_RETURNED_ROWS, S3QUERY_RETURNED_BYTES, FILES ORDER BY QUERY, SEGMENT, SLICE;
```

#### Observations:

Execution time (column dur_ms) for querying parquet data is significantly lower than CSV.



## Predicate pushdown to Spectrum layer improves query performance
### Example 1: DISTINCT vs GROUP BY (Avoid using DISTINCT for Spectrum table)
```sql
EXPLAIN 
SELECT DISTINCT l_returnflag, 
l_linestatus 
FROM 	"spectrum"."lineitem_parq"
WHERE EXTRACT(YEAR from l_shipdate::DATE) BETWEEN '1995' AND  '1998' 
ORDER BY l_returnflag, l_linestatus
;
```
```sql
EXPLAIN 
SELECT l_returnflag,
l_linestatus 
FROM 	"spectrum"."lineitem_parq"
WHERE EXTRACT(YEAR from l_shipdate::DATE) BETWEEN '1995' AND  '1998' 
GROUP BY l_returnflag, l_linestatus 
ORDER BY l_returnflag, l_linestatus
;
```

#### Observations:
--
It turns out that there is no pushdown in the first query (because of DISTINCT). Instead, a large number of rows are returned to Amazon Redshift to be sorted and de-duped. In the second query, S3 HashAggregate is pushed to Redshift Spectrum, where most of the heavy lifting and aggregation is done. Querying against SVL_S3QUERY_SUMMARY confirms the explain plan differences:
The lesson learned is that you should replace “DISTINCT” with “GROUP BY” in your SQL statements wherever possible

### Example 2: (Use of DATE function which can’t be push down) 
Perform a quick test using the following two queries, you would notice a huge performance difference between these two queries:
```sql
SELECT MIN(L_SHIPDATE), MAX(L_SHIPDATE), count(*)
FROM "spectrum"."lineitem_parq";

SELECT MIN(DATE(L_SHIPDATE)), MAX(DATE(L_SHIPDATE)), count(*)
FROM "spectrum"."lineitem_parq";
```
#### Observations: 

In the first query’s explain plan, S3 Aggregate is being pushed down to the Amazon Redshift Spectrum layer, and only the aggregated results are returned to Amazon Redshift for final processing.
On the other hand, if you take a close look at the second query’s explain plan, you would notice that there is no S3 aggregate in the Amazon Redshift Spectrum layer because Amazon Redshift Spectrum doesn’t support DATE as a regular data type or the DATE transform function. As a result, this query is forced to bring back a huge amount of data from S3 into Amazon Redshift to transform and process.
