# DB Template Container is built using the compose file within the blank-sqldb folder
# After first start of db container, image is created an pushed to acrrepo for use int he devstack
######################################################################################################################################
  - 1) DB can be created from a BACPAC file or Script (Depending on how you might need to initialise it)
        If you have a large baseline dataset in an existing database then export the chema and data to a bacpac file.
        Otherwise create a SQL script to generate the DB Schema

  - 2) Place the bacpac and or DB create scripts in the blank-sqldb\dbscripts directory.

  - 3) Build the and run the container to import and configure Pulse data in the container using the files in the devstack-sqldb folder
           - Dockerfile, Pulls a standard MS SQL Server image, runs the blank_template_db.sh script
                         Scripts create DB, import data/db from bacpac file 
           - docker-compose-sqlserver.yml.  Calls Dockerfile in same directory

           # docker-compose -f .\docker-compose-sqlserver.yml build --force-rm
           # docker-compose -f .\docker-compose-sqlserver.yml up

  - 4) Restart container and ensure it comes up quickly without re-importing data to confirm it has configured correctly.
           # docker-compose -f .\docker-compose-sqlserver.yml stop
           # docker-compose -f .\docker-compose-sqlserver.yml start

  - 5) Create an image from the container, and push to repo if this is static
           # docker ps
           # docker commit -m "devstack-blank-sql 20200520-1330" -a "PSC" <<containerid> pulsedevacr.azurecr.io/devstack-sqldb-blank:latest
           # az acr login --name pulsedevacr
           # docker push pulsedevacr.azurecr.io/devstack-sqldb-blank:latest

  - 6) Use the image in the 