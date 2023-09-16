# Database Reliability Engineer challenge

## 1. Introduction

Docker Composer to setup 2 PostgreSql databases and enable data replication
Database Master acts as Publisher and Replica as Subscriber.

## 2.
### 2.1. Docker Compose Setup
The docker-compose.yml file sets up two PostgreSQL instances named pg_master and pg_replica.

### 2.2. Database Creation and Schema Setup
PostgreSQL database instance pg_master has testDB database. In testDB we have a table called orders with the following columns:
- id: Integer, primary key, auto-increment
- product_name: Text
- quantity: Integer
- order_date: Date

Create a small script which will insert some sample rows into the orders table. This will be needed for the next exercises.

### 2.3. Deliverable

Configure the pg_master instance to act as a publisher.
Configure the pg_replica instance to act as a subscriber.
Set up logical replication from pg_master to pg_replica for the orders table.
Validate that changes on pg_master are reflected on pg_replica by using the script from 1.

### 2.3. Partition the orders table
While constantly inserting new rows into the orders table, partition the orders table by the date column without downtime. (You can ignore the replication here.) 

## 3. Deliverable

You can deliver the code by sharing the repository with the interviewer in any public service (Github, BitBucket, Gitlab), or by sending the zip git repository. Align with the interviewer which best fits you.

Enjoy :)
