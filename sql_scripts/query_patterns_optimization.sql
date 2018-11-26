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

/********************************************************************************************************
CASE 01
orders and lineitems tables created with no best standards
********************************************************************************************************/

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
    demo_local.orders_nocomp,
    demo_local.lineitem_nocomp
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

	
/********************************************************************************************************
CASE 02
orders and lineitems tables created with compression on. Still no sortkey and distkey.
********************************************************************************************************/
		
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
    demo_local.orders_comp,
    demo_local.lineitem_comp
WHERE
    o_orderkey = l_orderkey
    AND l_shipmode in ('AIR', 'SHIP', 'SOME')
    AND l_commitdate < l_receiptdate
    AND l_shipdate < l_commitdate
    AND l_receiptdate >= date '1992-01-01'
    AND l_receiptdate < date '1996-01-01' + interval '1' year
GROUP BY
    l_shipmode
ORDER BY
    l_shipmode;
	

	
/********************************************************************************************************
CASE 03
orders and lineitems tables  WITH compression, distribution style and sort keys
********************************************************************************************************/

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



/********************************************************************************************************
CASE 04
orders and lineitems tables with compression on, 
               distkey = orderkey which is the natural key as well as joining column 
               and sortkey != orderkey which is a different column for orders and lineitems table
********************************************************************************************************/
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
    demo_local.orders_base
join demo_local.lineitem_base on o_orderkey = l_orderkey --joining column which is the distkey in each table being joined
WHERE l_shipmode in ('AIR', 'SHIP')
    AND l_commitdate < l_receiptdate
    AND l_shipdate < l_commitdate
    AND l_receiptdate >= date '1992-01-01'
    AND l_receiptdate < date '1996-01-01' + interval '1' year
GROUP BY
    l_shipmode
ORDER BY
    l_shipmode;



/********************************************************************************************************
CASE 05
orders and lineitems tables with compression on, 
               distkey = orderkey which is the natural key as well as joining column 
               and sortkey = orderkey i.e the same column as the distkey as well as the joining column
********************************************************************************************************/

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
	
	
/********************************************************************************************************
CASE 06
Query pattern: EXISTS clause 
********************************************************************************************************/

set enable_result_cache_for_session to off;
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

/******Convert the above query using LEFT JOIN and improve the EXPLAIN******/
set enable_result_cache_for_session to off;
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


/********************************************************************************************************
CASE 07
Query pattern: Analytical query clause 
********************************************************************************************************/
set enable_result_cache_for_session to off;
select cust.c_nationkey, count(ord.o_orderkey), sum(ord.o_totalprice) from demo_local.orders_mergekey ord join demo_local.customer_base cust on ord.o_custkey = cust.c_custkey
where c_mktsegment = 'HOUSEHOLD' 
and o_totalprice > (select median(o_totalprice) from demo_local.orders_mergekey join demo_local.customer_base on o_custkey = c_custkey where c_mktsegment = 'HOUSEHOLD' )
group by 1
limit 10;

/******Convert the above query by minimizing distribution steps and improve the EXPLAIN******/
set enable_result_cache_for_session to off;
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

/******Further improve EXPLAIN by selecting dist_style = ALL on smaller table ******/
set enable_result_cache_for_session to off;
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
