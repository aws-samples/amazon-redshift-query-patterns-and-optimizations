SELECT extract( year from ord.o_orderdate) , sum(ord.o_totalprice) total_sales FROM demo_master.orders ord  group by 1;
