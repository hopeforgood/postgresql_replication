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
   {code}
   docker ps
   {code}

   You should see:
   NAMES
    postgresql_replication-pg_master-1
    postgresql_replication-pg_replica-1

## 5. Verify wich IP address has been set for master:
   docker network inspect postgresql_replication_default

   look for "Name": "postgresql_replication-pg_master-1" and check it's "IPv4Address".
   
## 2. Make sure you have installed Docker
## 2. Make sure you have installed Docker
## 2. Make sure you have installed Docker
   
