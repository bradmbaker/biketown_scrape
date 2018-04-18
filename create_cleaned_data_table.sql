# this query creates a table with an entry for each bike at 5 minute intervals
# the info on the bike will be null if it is currently checked out
USE bikes;

# get the last and next sighting of each bike including lat/long/hub_id
DROP TABLE IF EXISTS all_bikes_prev_and_next_locations;
CREATE TABLE all_bikes_prev_and_next_locations AS
SELECT 
    id
  , name
  , network_id
  , hub_id
  , inside_area
  , address
  , sponsored
  , lon
  , lat
  , ts
  , COALESCE(LAG(lon) OVER (PARTITION BY id ORDER BY ts), 0) AS last_seen_at_lon
  , COALESCE(LAG(lat) OVER (PARTITION BY id ORDER BY ts), 0) AS last_seen_at_lat
  , COALESCE(LAG(hub_id) OVER (PARTITION BY id ORDER BY ts), 0) AS last_seen_at_hub_id
  , COALESCE(LEAD(lon) OVER (PARTITION BY id ORDER BY ts), 0) AS next_seen_at_lon
  , COALESCE(LEAD(lat) OVER (PARTITION BY id ORDER BY ts), 0) AS next_seen_at_lat
  , COALESCE(LEAD(hub_id) OVER (PARTITION BY id ORDER BY ts), 0) AS next_seen_at_hub_id  
FROM bike_locations
;

# create a table with all bikes at all data scrape times, even if the bikes seen at that time
DROP TABLE IF EXISTS all_possible_bike_ts_combos;
CREATE TABLE all_possible_bike_ts_combos AS
SELECT 
   a.ts
 , b.id
FROM (
	SELECT ts
	FROM bike_locations
	GROUP BY ts
) a
JOIN (
	SELECT id
	FROM bike_locations
	GROUP BY id
) b
ON 1 = 1
;

# add in known info on bikes at times when they were spotted
DROP TABLE IF EXISTS all_bikes_at_all_times;
CREATE TABLE all_bikes_at_all_times AS
SELECT
    a.ts
  , a.id
  , b.name
  , b.hub_id
  , b.inside_area
  , b.lon
  , b.lat
FROM all_possible_bike_ts_combos a
LEFT OUTER JOIN bike_locations b
ON a.id = b.id AND a.ts = b.ts
;

# get previous and next sightings for all ts and join in known data
DROP TABLE IF EXISTS all_bikes_at_all_times_w_prev;
CREATE TABLE all_bikes_at_all_times_w_prev AS
SELECT
    a.ts
  , a.id
  , a.name
  , a.hub_id
  , a.inside_area
  , COALESCE(a.lon, 0) AS lon
  , COALESCE(a.lat, 0) AS lat
  , COALESCE(LAG(a.lon) OVER (PARTITION BY a.id ORDER BY ts), 0) AS prev_lon
  , COALESCE(LAG(a.lat) OVER (PARTITION BY a.id ORDER BY ts), 0) AS prev_lat
  , COALESCE(LAG(a.hub_id) OVER (PARTITION BY a.id ORDER BY ts), 0) AS prev_hub
  , COALESCE(LEAD(a.lon) OVER (PARTITION BY a.id ORDER BY ts), 0) AS next_lon
  , COALESCE(LEAD(a.lat) OVER (PARTITION BY a.id ORDER BY ts), 0) AS next_lat
  , COALESCE(LEAD(a.hub_id) OVER (PARTITION BY a.id ORDER BY ts), 0) AS next_hub
  , b.last_seen_at_lon
  , b.last_seen_at_lat
  , b.last_seen_at_hub_id
  , b.next_seen_at_lon
  , b.next_seen_at_lat  
  , b.next_seen_at_hub_id
FROM all_bikes_at_all_times a
LEFT OUTER JOIN all_bikes_prev_and_next_locations b
ON a.id = b.id
  AND a.ts = b.ts
;

# dump into csv
SELECT 
    ts
  , id
  , name
  , hub_id
  , inside_area
  , lon
  , lat
  , prev_lon
  , prev_lat
  , prev_hub
  , next_lon
  , next_lat
  , next_hub
  , last_seen_at_lon
  , last_seen_at_lat
  , last_seen_at_hub_id
  , next_seen_at_lon
  , next_seen_at_lat  
  , next_seen_at_hub_id
INTO OUTFILE '~/Documents/R/biketown_scrape/all_bike_data.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM all_bikes_at_all_times_w_prev
;

# dump into csv
SELECT 
    id
  , name
  , hub_id
  , inside_area
  , address
  , lon
  , lat
  , ts
INTO OUTFILE '~/Documents/R/biketown_scrape/raw_data.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM bike_locations
;
