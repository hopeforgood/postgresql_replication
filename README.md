# Database Reliability Engineer challenge

## 1. Introduction

Docker Composer to setup 2 PostgreSql databases and enable data replication
Database Master acts as Publisher and Replica as Subscriber.

## 2.
### 2.1. Docker Compose Setup
The docker-compose.yml file sets up two PostgreSQL instances named pg_master and pg_replica.

### 2.2. Database Creation and Schema Setup
PostgreSQL database instance pg_master has testDB database. In testDB we have a table called orders with the following columns:
DDL:
CREATE TABLE IF NOT EXISTS cloudwalk.orders(
    id              integer GENERATED ALWAYS AS IDENTITY primary key,
    product_name    text,
    quantity        integer,
    order_date      date);

Some inserts into pgMaster table orders:
  insert into cloudwalk.orders(product_name, quantity, order_date) values('Nike Before',100, now());
  insert into cloudwalk.orders(product_name, quantity, order_date) values('Nike After',100, now());


### 2.3. Deliverable
Set up logical replication from pg_master to pg_replica for the orders table.

Configure the pg_master instance to act as a publisher.
   CREATE PUBLICATION prod_orders FOR TABLE cloudwalk.orders;
Configure the pg_replica instance to act as a subscriber.
   CREATE SUBSCRIPTION get_prod_orders
    CONNECTION 'dbname = testdb
                host = 192.168.224.3
    			user = root
    			password = password
    			port = 5432'
    PUBLICATION prod_orders;
    
With bellow insert we can validate that changes on pg_master are reflected on pg_replica by using the script:
insert into cloudwalk.orders(product_name, quantity, order_date)
values('Nike AirJordan',100, now());

### 2.3. Partition the orders table
While constantly inserting new rows into the orders table, partition the orders table by the date column without downtime. (You can ignore the replication here.) 

## 3. Deliverable

You can deliver the code by sharing the repository with the interviewer in any public service (Github, BitBucket, Gitlab), or by sending the zip git repository. Align with the interviewer which best fits you.

Enjoy :)
