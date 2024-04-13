CREATE DATABASE `meetup`;

CREATE TABLE `users` (
    `id` INT auto_increment PRIMARY KEY,
    `username` VARCHAR(20) NOT NULL UNIQUE,
    `password` VARCHAR(20) NOT NULL,
    `first_name` VARCHAR(20) NOT NULL,
    `last_name` VARCHAR(20) NOT NULL,
    `birthdate` DATE NOT NULL,
    `email` VARCHAR(40) NOT NULL,
    `phone_no` VARCHAR(20)
);

CREATE TABLE `groups` (
    `id` INT auto_increment,
    `name` VARCHAR(20) NOT NULL,
    `creation_date` DATE NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `users_in_groups` (
    `id` INT auto_increment,
    `group_id` INT,
    `user_id` INT,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

CREATE TABLE `friend_friend_connections` (
    `user1_id` INT,
    `user2_id` INT,
    FOREIGN KEY (`user1_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user2_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

CREATE TABLE `meetup_places` (
    `id` INT auto_increment,
    `country` VARCHAR(20) NOT NULL,
    `postcode` VARCHAR(10) NOT NULL,
    `city` VARCHAR(30) NOT NULL,
    `place` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `meetups` (
    `id` INT auto_increment,
    `meetup_place_id` INT,
    `host_id` INT,
    `meetup_date` DATETIME NOT NULL,
    `meetup_name` VARCHAR(80) NOT NULL,
    `people_attending` SMALLINT DEFAULT 0,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`meetup_place_id`) REFERENCES `meetup_places`(`id`),
    FOREIGN KEY (`host_id`) REFERENCES `users`(`id`),
    CONSTRAINT people_attending_positive CHECK (people_attending >= 0)
);

CREATE TABLE `people_in_the_meetup` (
    `id` INT auto_increment,
    `meetup_id` INT,
    `user_id` INT,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`meetup_id`) REFERENCES `meetups`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- This procedure ensures that when a meetup is created, host is automatically added to the people in the meetup table
-- and the value of people attending the event is increased to 1
delimiter //
CREATE PROCEDURE `create_meetup`(
    IN `meetup_place_id_value` INT,
    IN `host_id_value` INT,
    IN `meetup_date_value` DATE,
    IN `meetup_name_value` VARCHAR (80)
    )

BEGIN
    DECLARE new_meetup_id INT;
    DECLARE host_exists INT;
    DECLARE place_exists INT;
    -- Checks if the the place id and host id exist
    SELECT COUNT(*) INTO host_exists FROM `users` WHERE `id` = host_id_value;
    SELECT COUNT(*) INTO place_exists FROM `meetup_places` WHERE `id` = meetup_place_id_value;

    IF host_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Host does not exist';
    ELSEIF place_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meetup place does not exist';
    ELSE
        START TRANSACTION;
        INSERT INTO `meetups` (meetup_place_id, host_id, meetup_date, meetup_name, people_attending) VALUES
        (meetup_place_id_value, host_id_value, meetup_date_value, meetup_name_value, 0);
        SET new_meetup_id = LAST_INSERT_ID();
        UPDATE `meetups` SET `people_attending` = `people_attending` + 1 WHERE `id` = `new_meetup_id`;
        INSERT INTO `people_in_the_meetup` (meetup_id, user_id) VALUES
        (new_meetup_id, host_id_value);
        COMMIT;
    END IF;
END //
delimiter ;

-- when adding someone to the meetup, the people attending should increase by 1
delimiter //
CREATE PROCEDURE `add_person_to_meetup` (
    IN `meetup_id_value` INT,
    IN `user_id_value` INT
)
BEGIN
    DECLARE meetup_id_exists INT;
    DECLARE user_exists INT;
    DECLARE user_already_added INT;
    -- Checks if the the place id and host id exist
    SELECT COUNT(*) INTO meetup_id_exists FROM `meetups` WHERE `id` = meetup_id_value;
    SELECT COUNT(*) INTO user_exists FROM `users` WHERE `id` = user_id_value;
    -- Check if the user is in the people_in_the_meetup table
    SELECT COUNT(*) INTO `user_already_added` FROM `people_in_the_meetup` WHERE `meetup_id` = meetup_id_value AND `user_id` = user_id_value;


    IF meetup_id_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meetup with this id does not exist';
    ELSEIF user_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User with this id does not exist';
    ELSEIF user_already_added = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User with this id has been already added to that meeting';
    ELSE
        START TRANSACTION;
        INSERT INTO `people_in_the_meetup` (meetup_id, user_id) VALUES
        (meetup_id_value, user_id_value);
        UPDATE `meetups` SET `people_attending` = `people_attending` + 1 WHERE `id` = `meetup_id_value`;
        COMMIT;
    END IF;
END //
delimiter ;

-- when deleting someone from the meetup, the people attending should decrease by 1
delimiter //
CREATE PROCEDURE `remove_person_from_meetup` (
    IN `meetup_id_value` INT,
    IN `user_id_value` INT
)
BEGIN
    DECLARE meetup_id_exists INT;
    DECLARE user_exists INT;
    DECLARE user_already_removed INT;
    -- Checks if the the place id and host id exist
    SELECT COUNT(*) INTO meetup_id_exists FROM `meetups` WHERE `id` = meetup_id_value;
    SELECT COUNT(*) INTO user_exists FROM `users` WHERE `id` = user_id_value;
    -- Check if the user is in the people_in_the_meetup table
    SELECT COUNT(*) INTO `user_already_removed` FROM `people_in_the_meetup` WHERE `meetup_id` = meetup_id_value AND `user_id` = user_id_value;

    IF meetup_id_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meetup with this id does not exist';
    ELSEIF user_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User with this id does not exist';
    ELSEIF user_already_removed = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User with this id is not in this meetup';
    ELSE
        START TRANSACTION;
        DELETE FROM `people_in_the_meetup` WHERE `user_id` = `user_id_value` AND `meetup_id` = `meetup_id_value`;
        UPDATE `meetups` SET `people_attending` = `people_attending` - 1 WHERE `id` = `meetup_id_value`;
        COMMIT;
    END IF;
END //
delimiter ;

-- View to find all possible meetups from the newest to the oldest
CREATE VIEW `all_events` AS
SELECT `meetup_places`.`country`, `meetup_places`.`city`, `meetup_places`.`place`, `meetups`.`meetup_date`, `meetups`.`meetup_name`
FROM `meetups`
JOIN `meetup_places` ON `meetups`.`meetup_place_id` = `meetup_places`.`id`
ORDER BY `meetups`.`meetup_date` DESC;

-- View to find all meetups taking place in 2024
CREATE VIEW `events_from_2024` AS
SELECT `meetup_places`.`country`, `meetup_places`.`place`, `meetups`.`meetup_date`, `meetups`.`meetup_name`
FROM `meetups`
JOIN `meetup_places` ON `meetups`.`meetup_place_id` = `meetup_places`.`id`
WHERE `meetups`.`meetup_date` LIKE '2024%'
ORDER BY `meetups`.`meetup_date`;

-- Indexes to speed up the execution of the queries
CREATE INDEX `country_index` ON `meetup_places`(`country`);
CREATE INDEX `city_index` ON `meetup_places`(`city`);
CREATE INDEX `meetup_date_index` ON `meetups`(`meetup_date`);
