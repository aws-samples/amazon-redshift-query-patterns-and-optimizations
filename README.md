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
If you have decided to choose option 1 for launching the cluster you will need to execute the scripts "schema_setup.sql"  and "table_load.sql" first. 

**!!Note: the pre-requisite before proceeding.**

For option 2 this is not needed.

The "query_patterns_optimization.sql" script has queries that you can run one after another. There are few query patterns which are optimized progressively as you progress through the script.

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

## Create Query Launcher
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
