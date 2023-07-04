from sshtunnel import SSHTunnelForwarder,create_logger
import psycopg2
import logging

logger = logging.getLogger('sshtunnel')
logger.setLevel(logging.DEBUG)
 
sh =  SSHTunnelForwarder(
    ('ec2-35-176-29-95.eu-west-3.compute.amazonaws.com'),
    ssh_username="ec2-user",
     ssh_private_key="/Users/kodjo/workspace/afriex-jmeter-testbench/scripts/access-rds-mysql.pem",
     logger=create_logger(loglevel=10),
    local_bind_address=('', 3306),
    remote_bind_address=('afriex-mysql-dev.cg3sddgrw4ht.eu-west-3.rds.amazonaws.com', 3306)
) 
sh.start()
print("****SSH Tunnel Established****:"+str(tunnel))
 
connection = psycopg2.connect(user = "admin",
                                  password = "mgkrglKUcMCXEPguceq8xsSj",
                                  host = "afriex-mysql-dev.cg3sddgrw4ht.eu-west-3.rds.amazonaws.com",
                                  port = "3306",
                                  database = "afriex")

try:
       campaignId = 'u22249586'
       cursor = connection.cursor()
       cursor.execute("select * from sylius_product")

       for row in cursor:
         print(row)

finally:
        connection.close()
 
print("YAYY!!")

