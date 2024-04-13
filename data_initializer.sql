-- data initializer
INSERT INTO users (id, username, password, first_name, last_name, birthdate, email, phone_no) VALUES
(1, 'user1', 'qwerty1234', 'Peter', 'Smith', '1995-03-20', 'testemail1@email.com', '+1234567890'),
(2, 'user2', 'qwerty456', 'Jane', 'Smith', '2000-01-31', 'abc@email.com', '+1987654321'),
(3, 'bob123', 'qwerty756', 'Bob', 'Jackson', '1998-10-20', 'def@email.com', '+987654321'),
(4, 'user12536', 'qwertssf1234', 'Peter', 'Floyd', '1995-05-29', 'ghi@email.com', '+123555590');

INSERT INTO `groups` (name, creation_date) VALUES
('Berliners', '2024-03-01'),
('Dresdners', '2024-03-03');

INSERT INTO `users_in_groups` (group_id, user_id) VALUES
(1, 1),
(1, 2),
(2, 3);

INSERT INTO `friend_friend_connections` (user1_id, user2_id) VALUES
(1, 2),
(2, 3);

INSERT INTO `meetup_places` (country, postcode, city, place) VALUES
('Germany', '01234', 'Munich', 'Englischer Garten'),
('United Kingdom', '123AWX', 'London', 'Big Ben'),
('Germany', '09876', 'Berlin', 'Alexanderplatz'),
('Spain', '456BG', 'Barcelona', 'La Sagrada Familia');

-- Data to add with procedures
CALL create_meetup(1, 1, '2024-03-08', 'Language exchange program! Romanic languages!');
CALL create_meetup(2, 2, '2024-05-18', 'Bring some food from your country and let us picnic together!');
CALL create_meetup(1, 4, '2024-04-01', 'Playing volleyball in Englischer Garten');
CALL create_meetup(3, 3, '2023-12-24', 'Singing christmas songs together');
CALL create_meetup(4, 2, '2024-03-25', 'Free walking tour in Barcelona!');
CALL create_meetup(7, 2, '2024-03-25', 'Visiting Valencia!'); -- place id does not exist, procedure will be not executed

CALL add_person_to_meetup(1, 2);
CALL add_person_to_meetup(1, 3);
CALL add_person_to_meetup(1, 4);
CALL add_person_to_meetup(1, 5); -- User with id 5 does not exist, procedure will not be executed
CALL add_person_to_meetup(1, 2); -- User already in the meeting, procedure will not be executed

CALL remove_person_from_meetup(1, 2);
CALL remove_person_from_meetup(1, 3);
CALL remove_person_from_meetup(1, 3); -- User not in the meetup anymore, procedure will not be executed