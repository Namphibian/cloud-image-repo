FROM microsoft/mssql-server-linux:2017-CU9

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=MssqlPass123
ENV MSSQL_PID=Developer

COPY ./dbscripts /
    
ENTRYPOINT [ "/bin/bash", "/blank_template_DB.sh" ]
CMD [ "/opt/mssql/bin/sqlservr" ]