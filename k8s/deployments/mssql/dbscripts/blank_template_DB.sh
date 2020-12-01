#!/bin/bash
set -e

if [ "$1" = '/opt/mssql/bin/sqlservr' ]; then
  # If this is the container's first run, initialize the application database
  if [ ! -f /tmp/app-initialized ]; then
    # Initialize the application database asynchronously in a background process. This allows a) the SQL Server process to be the main process in the container, which allows graceful shutdown and other goodies, and b) us to only start the SQL Server process once, as opposed to starting, stopping, then starting it again.
    function initialize_app_database() {
      # Wait a bit for SQL Server to start. SQL Server's process doesn't provide a clever way to check if it's up or not, and it needs to be up before we can import the application database
      sleep 15s
           
		   # SqlPackage taken from https://github.com/Microsoft/mssql-docker/issues/135#issuecomment-389245587
		   apt-get update && apt-get install unzip -y
		   wget -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=873926 \
		       && unzip sqlpackage.zip -d /tmp/sqlpackage \
		       && chmod +x /tmp/sqlpackage/sqlpackage 

		   # Ensure DB supports contained databases
		   /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -i configure_Server.sql  

       # Create Empty databases, Run SQL Here
       opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -i create_db.sql
       

       # Import Data froma  bacpac file
		   #/tmp/sqlpackage/sqlpackage /a:Import /tsn:localhost,1433 /tdn:Pulse_LocDev_ODS /tu:sa /tp:"$SA_PASSWORD" /sf:myBacPac.bacpac && rm myBacPac.bacpac            

      # Note that the container has been initialized so future starts won't wipe changes to the data
      touch /tmp/app-initialized
    }
    initialize_app_database &
  fi
fi

exec "$@"
