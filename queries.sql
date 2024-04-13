-- Queries to run on the database

-- Query to find ids of users not enrolled in any events
SELECT `id` FROM `users`
EXCEPT
SELECT `user_id` FROM `people_in_the_meetup`;

-- Query to find all countries where the meetings are taking place
SELECT DISTINCT `country`
FROM `meetup_places`
WHERE `id` IN (
    SELECT `meetup_place_id`
    FROM `meetups`);

-- Query to find number of meetings taking place in a particular country
SELECT `meetup_places`.`country`, COUNT(`meetups`.`id`) AS 'Number of meetups' FROM `meetups`
JOIN `meetup_places` ON `meetups`.`meetup_place_id` = `meetup_places`.`id`
GROUP BY `meetup_places`.`country`;

-- Queries to find data from views
SELECT * FROM `all_events`;
SELECT * FROM `events_from_2024`;
