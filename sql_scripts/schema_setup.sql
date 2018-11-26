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

/****** Always good practices to check the number of slices in the Redshift cluster you want to load data *******/
select * from stv_slices;

/****** DB setup with ReadOnly users and ETL Users and DB schema *****/
create group etlusers;
create group rousers;
create user labuser with password 'Welcome123' in group rousers;
create user etluser with password 'Welcome123' in group etlusers;

create schema demo_local authorization labuser;
create table demo_local.schema_creation(creation_date date default trunc(sysdate));

grant select on all tables in schema demo_local to group rousers;
grant select on all tables in schema demo_local to group etlusers;

/**************Create tables without compression, distribution style or sort keys: *****/
	
CREATE TABLE demo_local.orders_nocomp
(
	o_orderkey BIGINT NOT NULL ENCODE RAW,
	o_custkey BIGINT NOT NULL ENCODE RAW,
	o_orderstatus CHAR(1) NOT NULL ENCODE RAW,
	o_totalprice NUMERIC(12, 2) NOT NULL ENCODE RAW,
	o_orderdate DATE NOT NULL ENCODE RAW,
	o_orderpriority CHAR(15) NOT NULL ENCODE RAW,
	o_clerk CHAR(15) NOT NULL ENCODE RAW,
	o_shippriority INTEGER NOT NULL ENCODE RAW,
	o_comment VARCHAR(79) NOT NULL ENCODE RAW
);

--DROP TABLE lineitem_nocomp;
CREATE TABLE demo_local.lineitem_nocomp
(
	l_orderkey BIGINT NOT NULL ENCODE RAW,
	l_partkey BIGINT NOT NULL ENCODE RAW,
	l_suppkey INTEGER NOT NULL ENCODE RAW,
	l_linenumber INTEGER NOT NULL ENCODE RAW,
	l_quantity NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_extendedprice NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_discount NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_tax NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_returnflag CHAR(1) NOT NULL ENCODE RAW,
	l_linestatus CHAR(1) NOT NULL ENCODE RAW,
	l_shipdate DATE NOT NULL ENCODE RAW,
	l_commitdate DATE NOT NULL ENCODE RAW,
	l_receiptdate DATE NOT NULL ENCODE RAW,
	l_shipinstruct CHAR(25) NOT NULL ENCODE RAW,
	l_shipmode CHAR(10) NOT NULL ENCODE RAW,
	l_comment VARCHAR(44) NOT NULL ENCODE RAW
);	

/********** Create tables WITH compression, NO distribution style or sort keys: ******/

--DROP TABLE demo_master.orders_comp;

CREATE TABLE demo_local.orders_comp
(
	o_orderkey BIGINT NOT NULL ENCODE RAW,
	o_custkey BIGINT NOT NULL ENCODE RAW,
	o_orderstatus CHAR(1) NOT NULL ENCODE RAW,
	o_totalprice NUMERIC(12, 2) NOT NULL ENCODE RAW,
	o_orderdate DATE NOT NULL ENCODE RAW,
	o_orderpriority CHAR(15) NOT NULL ENCODE RAW,
	o_clerk CHAR(15) NOT NULL ENCODE RAW,
	o_shippriority INTEGER NOT NULL ENCODE RAW,
	o_comment VARCHAR(79) NOT NULL ENCODE RAW);

--DROP TABLE demo_master.lineitem_comp;
CREATE TABLE demo_local.lineitem_comp
(
	l_orderkey BIGINT NOT NULL ENCODE RAW,
	l_partkey BIGINT NOT NULL ENCODE RAW,
	l_suppkey INTEGER NOT NULL ENCODE RAW,
	l_linenumber INTEGER NOT NULL ENCODE RAW,
	l_quantity NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_extendedprice NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_discount NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_tax NUMERIC(12, 2) NOT NULL ENCODE RAW,
	l_returnflag CHAR(1) NOT NULL ENCODE RAW,
	l_linestatus CHAR(1) NOT NULL ENCODE RAW,
	l_shipdate DATE NOT NULL ENCODE RAW,
	l_commitdate DATE NOT NULL ENCODE RAW,
	l_receiptdate DATE NOT NULL ENCODE RAW,
	l_shipinstruct CHAR(25) NOT NULL ENCODE RAW,
	l_shipmode CHAR(10) NOT NULL ENCODE RAW,
	l_comment VARCHAR(44) NOT NULL ENCODE RAW);
	
/**************Create tables WITH compression, distribution style and sort keys: ************/
---drop table demo_master.orders;
CREATE TABLE demo_local.orders
(
	o_orderkey BIGINT NOT NULL DISTKEY,
	o_custkey BIGINT NOT NULL,
	o_orderstatus CHAR(1),
	o_totalprice NUMERIC(12, 2),
	o_orderdate DATE NOT NULL,
	o_orderpriority CHAR(15) NOT NULL,
	o_clerk CHAR(15) NOT NULL,
	o_shippriority INTEGER NOT NULL,
	o_comment VARCHAR(79) NOT NULL
)
SORTKEY
(
	o_orderdate
);

--drop table demo_master.lineitem;
CREATE TABLE demo_local.lineitem
(
	l_orderkey BIGINT NOT NULL DISTKEY,
	l_partkey BIGINT NOT NULL,
	l_suppkey INTEGER NOT NULL,
	l_linenumber INTEGER NOT NULL,
	l_quantity NUMERIC(12, 2) NOT NULL,
	l_extendedprice NUMERIC(12, 2) NOT NULL,
	l_discount NUMERIC(12, 2) NOT NULL,
	l_tax NUMERIC(12, 2) NOT NULL,
	l_returnflag CHAR(1) NOT NULL,
	l_linestatus CHAR(1) NOT NULL,
	l_shipdate DATE NOT NULL,
	l_commitdate DATE NOT NULL,
	l_receiptdate DATE NOT NULL,
	l_shipinstruct CHAR(25) NOT NULL,
	l_shipmode CHAR(10) NOT NULL,
	l_comment VARCHAR(44) NOT NULL
)
SORTKEY
(
	l_shipdate
);

/********************************************************************************************************
Create orders and lineitems tables with compression on, 
               distkey = orderkey which is the natural key as well as joining column 
               and sortkey != orderkey which is a different column for orders and lineitems table
********************************************************************************************************/
CREATE TABLE demo_local.orders_base
(
	o_orderkey BIGINT NOT NULL DISTKEY,
	o_custkey BIGINT NOT NULL,
	o_orderstatus CHAR(1),
	o_totalprice NUMERIC(12, 2),
	o_orderdate DATE NOT NULL,
	o_orderpriority CHAR(15) NOT NULL,
	o_clerk CHAR(15) NOT NULL,
	o_shippriority INTEGER NOT NULL,
	o_comment VARCHAR(79) NOT NULL
)
SORTKEY
(
	o_orderdate
);

CREATE TABLE demo_local.lineitem_base
(
	l_orderkey BIGINT NOT NULL DISTKEY,
	l_partkey BIGINT NOT NULL,
	l_suppkey INTEGER NOT NULL,
	l_linenumber INTEGER NOT NULL,
	l_quantity NUMERIC(12, 2) NOT NULL,
	l_extendedprice NUMERIC(12, 2) NOT NULL,
	l_discount NUMERIC(12, 2) NOT NULL,
	l_tax NUMERIC(12, 2) NOT NULL,
	l_returnflag CHAR(1) NOT NULL,
	l_linestatus CHAR(1) NOT NULL,
	l_shipdate DATE NOT NULL,
	l_commitdate DATE NOT NULL,
	l_receiptdate DATE NOT NULL,
	l_shipinstruct CHAR(25) NOT NULL,
	l_shipmode CHAR(10) NOT NULL,
	l_comment VARCHAR(44) NOT NULL
)
SORTKEY
(
	l_shipdate
);


/********************************************************************************************************
Create orders and lineitems tables with compression on, 
               distkey = orderkey which is the natural key as well as joining column 
               and sortkey = orderkey i.e the same column as the distkey as well as the joining column
********************************************************************************************************/
CREATE TABLE demo_local.orders_mergekey
(
	o_orderkey BIGINT NOT NULL DISTKEY,
	o_custkey BIGINT NOT NULL,
	o_orderstatus CHAR(1),
	o_totalprice NUMERIC(12, 2),
	o_orderdate DATE NOT NULL,
	o_orderpriority CHAR(15) NOT NULL,
	o_clerk CHAR(15) NOT NULL,
	o_shippriority INTEGER NOT NULL,
	o_comment VARCHAR(79) NOT NULL
)
SORTKEY
(
	o_orderkey
);

CREATE TABLE demo_local.lineitem_mergekey
(
	l_orderkey BIGINT NOT NULL DISTKEY,
	l_partkey BIGINT NOT NULL,
	l_suppkey INTEGER NOT NULL,
	l_linenumber INTEGER NOT NULL,
	l_quantity NUMERIC(12, 2) NOT NULL,
	l_extendedprice NUMERIC(12, 2) NOT NULL,
	l_discount NUMERIC(12, 2) NOT NULL,
	l_tax NUMERIC(12, 2) NOT NULL,
	l_returnflag CHAR(1) NOT NULL,
	l_linestatus CHAR(1) NOT NULL,
	l_shipdate DATE NOT NULL,
	l_commitdate DATE NOT NULL,
	l_receiptdate DATE NOT NULL,
	l_shipinstruct CHAR(25) NOT NULL,
	l_shipmode CHAR(10) NOT NULL,
	l_comment VARCHAR(44) NOT NULL
)
SORTKEY
(
	l_orderkey
);
	
/********************************************************************************************************
Customer table with dist_stype = KEY
********************************************************************************************************/
create table demo_local.customer_base(
C_CUSTKEY BIGINT ENCODE RAW DISTKEY SORTKEY,
C_NAME  VARCHAR(25) ENCODE RAW,
C_ADDRESS  VARCHAR(40) ENCODE RAW,
C_NATIONKEY BIGINT ENCODE RAW,
C_PHONE char(15) ENCODE RAW,
C_ACCTBAL DECIMAL(10,2) ENCODE RAW,
C_MKTSEGMENT char(10) ENCODE RAW,
C_COMMENT  VARCHAR(117) ENCODE RAW
)
;


/********************************************************************************************************
Customer table with dist_stype = ALL
********************************************************************************************************/

create table demo_local.customer_distall(
C_CUSTKEY BIGINT ENCODE RAW SORTKEY,
C_NAME  VARCHAR(25) ENCODE RAW,
C_ADDRESS  VARCHAR(40) ENCODE RAW,
C_NATIONKEY BIGINT ENCODE RAW,
C_PHONE char(15) ENCODE RAW,
C_ACCTBAL DECIMAL(10,2) ENCODE RAW,
C_MKTSEGMENT char(10) ENCODE RAW,
C_COMMENT  VARCHAR(117) ENCODE RAW
)
diststyle all
;
