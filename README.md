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

**!! You will need to have a copy of the Redshift snapshot "rslab-ds2-xl-4n-final" in your AWS account. Please request access for the snapshot.!!**

* Login to AWS console in the AWS account in which you want to onboard your cluster and switch to the correct region.
* (Optional) Create new KMS Key or use existing "aws/redshift" KMS key. Copy KMS Key ID into your notepad.
* Download the github cloudformation template file **redshift_vpc_glue.yaml** and save it in your local system.
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
