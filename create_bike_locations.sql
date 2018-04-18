USE bikes;
CREATE TABLE bike_locations (
id           INT, 
name         VARCHAR(50), 
network_id   INT, 
hub_id       INT, 
inside_area  CHAR(5), 
address      VARCHAR(100), 
sponsored    CHAR(5), 
lon          DOUBLE, 
lat          DOUBLE, 
ts           TIMESTAMP
);



