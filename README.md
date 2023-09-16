# Intructions on how to use this repo

# Database Reliability Engineer by Ronaldo Akamine
Docker Composer to setup 2 PostgreSql databases and enable data replication
Database pg_master acts as Publisher and pg_replica as Subscriber.

## 1. Clone this repo to your local computer
   git clone

## 2. Make sure you have installed Docker
   https://www.docker.com/products/docker-desktop/
   
## 3. Execute the docker compose file
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
   
## 7. Make sure you have installed Docker


## 2. Make sure you have installed Docker
   
