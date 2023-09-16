# Intructions on how to use this repo

# Database Reliability Engineer by Ronaldo Akamine
Docker Composer to setup 2 PostgreSql databases and enable data replication
Database pg_master acts as Publisher and pg_replica as Subscriber.

## 1. Clone this repo to your local computer
   git clone

## 2. Make sure you have installed Docker
   https://www.docker.com/products/docker-desktop/
   
## 3. Execute the docker compose file
   In your computer's terminal navigate to the repo root folder "postgresql_replication" and execute:
   docker-compose up -d

## 4. Check that you now have e docker containers running:
   docker ps 

   You should see NAMES:
    postgresql_replication-pg_master-1
    postgresql_replication-pg_replica-1

## 5. Verify what is the IP address set for pg_master-1:
   docker network inspect postgresql_replication_default

   look for "Name": "postgresql_replication-pg_master-1" and check it's "IPv4Address".
   Take note of this ip address so later we can configure it for the subscription in replica DB.
   
## 6. Configure the Replication for the subscription
   The Publisher was already configured in the "01-init.sh" file of pg_master so we just need to setup the subscriber.
   Check how many hows we have in the replica's table:
   select count(*) from cloudwalk.orders; 
   
   Log in to pg_replica with root/password and execute bellow command in postgresql:
      CREATE SUBSCRIPTION get_prod_orders
      CONNECTION 'dbname = testdb
                  host = 192.168.224.3
      			user = root
      			password = password
      			port = 5432'
      PUBLICATION prod_orders;   
## 7. Compile and execute insert procedure:
  Compile the procure prc_inserts in pg_master and call it:
  procedure_prc_inserts.sql
  CALL public.fnc_inserts();

  This procedure is set to perform 100000 record inserts into cloudwalk.orders table.
  And the loop waits 0.2 seconds between each insert so we can simulate real world inserts into our database.

  Check on pg_master and pg_replica how many how we have in cloudwalk.orders table.
  Verify that while the procure runs the replication is working good.

  --To check total rows
  select count(*) from cloudwalk.orders; 

  --To quickly check latest rows added
  select * from cloudwalk.orders order by 1 desc;

## 8. To make the cloudwalk.orders as a partitioned table with no downtime we have to:
Create the new partitioned table:
CREATE TABLE IF NOT EXISTS cloudwalk.orders2(
    id              integer GENERATED BY DEFAULT AS IDENTITY,
    product_name    text,
    quantity        integer,
    order_date      date,
    constraint pk_orders primary key (id, order_date)
) PARTITION BY RANGE (order_date);

--Create some partitions (child tables)
CREATE TABLE cloudwalk.orders2_20230916 PARTITION OF cloudwalk.orders2 
     FOR VALUES FROM (now()) TO (now() + interval '1 day');
CREATE TABLE cloudwalk.orders2_20230917 PARTITION OF cloudwalk.orders2 
     FOR VALUES FROM (now() + interval '1 day') TO (now() + interval '2 day');
CREATE TABLE cloudwalk.orders2_20230917 PARTITION OF cloudwalk.orders2 
     FOR VALUES FROM (now() + interval '2 day') TO (now() + interval '3 day');
CREATE TABLE cloudwalk.orders2_20230917 PARTITION OF cloudwalk.orders2 
     FOR VALUES FROM (now() + interval '3 day') TO (now() + interval '4 day');
CREATE TABLE cloudwalk.orders2_20230917 PARTITION OF cloudwalk.orders2 
     FOR VALUES FROM (now() + interval '4 day') TO (now() + interval '5 day');

--Notice the partitioned table we created the identity column as DEFAULT instead of ALWAYS
--This allow the trigger to insert the id from the source table.

## 8.1 Create a trigger that will send all data the no partitioned table receives also to the new partitioned table:
CREATE FUNCTION fnc_migrate_orders() RETURNS trigger AS $$
    BEGIN
		insert into cloudwalk.orders2
		select * from cloudwalk.orders a
		 where not exists (select 1
		                     from cloudwalk.orders2 b
		                    where a.id = b.id
		                      and a.order_date = b.order_date);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_migrate_orders BEFORE INSERT ON cloudwalk.orders
    FOR EACH STATEMENT EXECUTE FUNCTION fnc_migrate_orders();

## 8.2 Right after the trigger creation check the new partitoned table now has the same data as the original table
select * from cloudwalk.orders2; --Partitioned
select * from cloudwalk.orders;  --Not Partitioned

## 10. To make the cloudwalk.orders as a partitioned table with no downtime we have to:
1-) Create a view pointing to original table:
   create or replace view cloudwalk.orders_vw as
   select * from cloudwalk.orders;
1.1-) All applications that just needs to read data will have to read data from pg_master using this view instead of querying directly the real table.

1.2-) Now lets create a second table similar to cloudwalk.orders but partitioned:
CREATE TABLE IF NOT EXISTS cloudwalk.orders2(
    id              integer GENERATED ALWAYS AS IDENTITY primary key,
    product_name    text,
    quantity        integer,
    order_date      date);
) PARTITION BY RANGE (order_date);
   
   




--Ultimately if you need to use original table name for all applications you can rename the table names
--Deprecate table that is not partitioned
alter table cloudwalk.orders rename to orders_old;
--Make new partitioned table the official one:
alter table cloudwalk.orders2 rename to orders;
--Do not forget to also recompile the view to point to new partitioned table.
create or replace view cloudwalk.orders_vw as
select * from cloudwalk.orders order by 1 desc;

--But this opration caused bellow error in inserting procedure:
SQL Error [42P01]: ERROR: relation "cloudwalk.orders" does not exist
  Where: PL/pgSQL function prc_inserts() line 9 at SQL statement

In other words I am not sure if it's possible to really change a Production table to be partitioned with no real Down time.
This table name renaming also breaks the data replication that needs to be reconfigured again.
