USE CyclisticBikeTrip;



-- check duplications
SELECT
	COUNT(ride_id),
    ride_id
FROM trip
GROUP BY ride_id;



-- get rid of unlock by mistake rows and didn't lock the bike
-- (where start to end less then 1 minute and star_station is the same with end_station or unlock over a week)

DELETE FROM trip 
WHERE
	TIMESTAMPDIFF(MINUTE, started_at, ended_at) < 1
	AND start_station_name = end_station_name;

DELETE FROM trip 
WHERE
	TIMESTAMPDIFF(MINUTE, started_at, ended_at) < 0;
    
DELETE FROM trip 
WHERE
	TIMESTAMPDIFF(MINUTE, started_at, ended_at) > 10080;
    
    
    
-- try to fill out the empty cells

UPDATE 
	trip
SET
	start_station_name = CASE WHEN start_station_name = '' THEN NULL ELSE start_station_name END,
    start_station_id = CASE WHEN start_station_id = '' THEN NULL ELSE start_station_id END,
    end_station_name = CASE WHEN end_station_name = '' THEN NULL ELSE end_station_name END,
    end_station_id = CASE WHEN end_station_id = '' THEN NULL ELSE end_station_id END;


SELECT 
	a.start_lat,
    a.start_lng,
	a.start_station_name,
    a.start_station_id,
    b.start_lat,
    b.start_lng,
	b.start_station_name,
    b.start_station_id,
    IFNULL(a.start_station_name, b.start_station_name),
    IFNULL(a.start_station_id, b.start_station_id)
FROM trip AS a
JOIN trip AS b
ON a.start_lat = b.start_lat AND a.start_lng = b.start_lng
	AND a.ride_id != b.ride_id
WHERE a.start_station_name IS NULL;
	

UPDATE trip AS a, trip AS b 
SET a.start_station_name = IFNULL(a.start_station_name, b.start_station_name),
	a.start_station_id = IFNULL(a.start_station_id, b.start_station_id)
WHERE
	a.start_lat = b.start_lat 
    AND a.start_lng = b.start_lng
	AND a.ride_id != b.ride_id;



-- find out the preference using bike type of member and casual riders and the average using time

SELECT 
    rideable_type AS bike_type,
    COUNT(DISTINCT CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) AS members,
    CASE WHEN member_casual = 'member' THEN AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) END AS avg_member_min,
	COUNT(DISTINCT CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) AS casuals,
    CASE WHEN member_casual = 'casual' THEN AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) END AS avg_casual_min
FROM trip
GROUP BY bike_type, member_casual;



-- find out member and casual riders' trends druring a day

SELECT 
	HOUR(started_at) AS time_hour,
	COUNT(DISTINCT CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) AS members,
    COUNT(DISTINCT CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) AS casuals
FROM trip
GROUP BY 
    time_hour
ORDER BY time_hour;



-- find out member and casual riders' trends during the year

SELECT 
	YEAR(started_at) AS years,
	MONTH(started_at) AS months,
	COUNT(DISTINCT CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) AS members,
    COUNT(DISTINCT CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) AS casuals
FROM trip
GROUP BY 
    years, months
ORDER BY years, months;



-- find out weekday and weekend trends

SELECT 
	DAYNAME(started_at) AS weekdays,
	COUNT(DISTINCT CASE WHEN member_casual = 'member' THEN ride_id ELSE NULL END) AS members,
    CASE WHEN member_casual = 'member' THEN AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) END AS avg_member_min,
    COUNT(DISTINCT CASE WHEN member_casual = 'casual' THEN ride_id ELSE NULL END) AS casuals,
    CASE WHEN member_casual = 'casual' THEN AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) END AS avg_casual_min
FROM trip
GROUP BY 
    weekdays, member_casual;


SELECT 
	COUNT(ride_id) AS ride_id,
    ROUND(start_lat,5) AS lat,
    ROUND(start_lng,5) AS lng,
    member_casual
FROM trip
GROUP BY 2, 3, 4

