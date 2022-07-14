-- CREATE DATABASE IF NOT EXISTS museum;
-- ALT + X from here; Updated rows 85; Queries 42
-- Script is reusable except last insert into the table 'ticket'

CREATE SCHEMA IF NOT EXISTS museum; 
ALTER DATABASE museum SET search_path TO museum;
SET client_encoding = 'UTF8';

-- DDL Part -- 

-- #1 Table 'Country'
-- This table contains information about modern coutnries and cities, in order to be able to group art work by location
CREATE TABLE IF NOT EXISTS museum.country (
	country_id serial4 NOT NULL,
	region varchar NULL,
	country varchar NULL,
	city varchar NULL,
	CONSTRAINT country_country_city_key UNIQUE (country, city),
	CONSTRAINT pk_country_country_id PRIMARY KEY (country_id)
);

-- #2 Table 'Country Historical'
-- This table contains information about historical coutnries and cities, in order to be able to group art work by location
CREATE TABLE IF NOT EXISTS museum.country_historical (
	country_h_id serial4 NOT NULL,
	region varchar NULL,
	country varchar NULL,
	city varchar NULL,
	country_id int4 NULL,
	CONSTRAINT country_historical_country_city_key UNIQUE (country, city),
	CONSTRAINT pk_country_historical_country_h_id PRIMARY KEY (country_h_id),
	CONSTRAINT fk_country_historical_country FOREIGN KEY (country_id) REFERENCES museum.country(country_id)
);

-- #3 Table 'Collection'
-- This table contains information about collections of art works; to keep track whether a single art piece is a part of a group 
CREATE TABLE IF NOT EXISTS museum.collection (
	collection_id serial4 NOT NULL,
	"name" varchar NOT NULL,
	CONSTRAINT collection_name_key UNIQUE (name),
	CONSTRAINT pk_collection_collection_id PRIMARY KEY (collection_id)
);

-- #4 Table 'Item'
-- This is the main table that contains extensive data about each art piece that has ever been in the museum 
CREATE TABLE IF NOT EXISTS museum.item (
	item_id serial4 NOT NULL,
	title varchar NOT NULL DEFAULT 'untitled'::character varying,
	author varchar NOT NULL DEFAULT 'unknown'::character varying,
	year_started date NOT NULL,
	year_ended date NOT NULL,
	"type" varchar NULL,
	"style" varchar NULL,
	collection_id int4 NULL,
	country_h_id int4 NULL,
	weight numeric NULL,
	width numeric NULL,
	length numeric NULL,
	height numeric NULL,
	on_repair bool NULL DEFAULT false,
	status varchar NULL,
	last_updated date NULL DEFAULT CURRENT_DATE,
	CONSTRAINT item_title_author_year_started_year_ended_key UNIQUE (title, author, year_started, year_ended),
	CONSTRAINT pk_item_item_id PRIMARY KEY (item_id),
	CONSTRAINT fk_item_collection FOREIGN KEY (collection_id) REFERENCES museum.collection(collection_id),
	CONSTRAINT fk_item_country FOREIGN KEY (country_h_id) REFERENCES museum.country_historical(country_h_id)
);

-- #5 Table 'Item Keyword'
-- This table contains key words for each art piece, to make online search easier; potentially for the museum's website
CREATE TABLE IF NOT EXISTS museum.item_keyword (
	id serial4 NOT NULL,
	item_id int4 NOT NULL,
	keyword varchar NULL,
	CONSTRAINT item_keyword_item_id_keyword_key UNIQUE (item_id, keyword),
	CONSTRAINT pk_item_keyword_id PRIMARY KEY (id),
	CONSTRAINT fk_item_keyword_item FOREIGN KEY (item_id) REFERENCES museum.item(item_id)
);

-- #6 Table 'Storage'
-- This table has information about exact locations of currently stored in archive art pieces
CREATE TABLE IF NOT EXISTS museum."storage" (
	storage_id serial4 NOT NULL,
	item_id int4 NOT NULL,
	floor int4 NULL,
	room int4 NULL,
	shelf int4 NULL,
	last_updated date NULL DEFAULT CURRENT_DATE,
	CONSTRAINT pk_tbl_storage_id PRIMARY KEY (storage_id),
	CONSTRAINT storage_item_id_floor_room_shelf_key UNIQUE (item_id, floor, room, shelf),
	CONSTRAINT fk_storage_item FOREIGN KEY (item_id) REFERENCES museum.item(item_id)
);

-- #7 Table 'Transaction'
-- This is a transactional table that keeps track of art purchases that has ever been made; can be updated by a museum's employee (e.g. accountant)
CREATE TABLE IF NOT EXISTS museum."transaction" (
	transaction_id serial4 NOT NULL,
	item_id int4 NOT NULL,
	date_bought date NULL,
	date_sold date NULL,
	price_bought numeric NULL,
	price_sold numeric NULL,
	bought_from varchar NULL,
	sold_to varchar NULL,
	last_updated date NULL DEFAULT CURRENT_DATE,
	CONSTRAINT pk_transation_transaction_id PRIMARY KEY (transaction_id),
	CONSTRAINT transaction_item_id_date_bought_price_bought_bought_from_key UNIQUE (item_id, date_bought, price_bought, bought_from),
	CONSTRAINT fk_transaction_item FOREIGN KEY (item_id) REFERENCES museum.item(item_id)
);

-- #8 Table 'Loan To'
-- Table contains data of art works that were temporary loaned to other museums for showcasing and no payment
CREATE TABLE IF NOT EXISTS museum.loan_to (
	loan_to_id serial4 NOT NULL,
	item_id int4 NOT NULL,
	loaned_to varchar NULL,
	date_sent date NULL DEFAULT CURRENT_DATE,
	date_returned date NULL,
	CONSTRAINT loan_to_item_id_loaned_to_date_sent_key UNIQUE (item_id, loaned_to, date_sent),
	CONSTRAINT pk_loan_loan_id PRIMARY KEY (loan_to_id),
	CONSTRAINT fk_loan_to_item FOREIGN KEY (item_id) REFERENCES museum.item(item_id)
);

-- #9 Table 'Loan From'
-- Another table with data about art works that were temporary loaned to us for showcasing and with no payment
CREATE TABLE IF NOT EXISTS museum.loan_from (
	loan_from_id serial4 NOT NULL,
	item_id int4 NOT NULL,
	loaned_from varchar NULL,
	date_received date NULL DEFAULT CURRENT_DATE,
	date_returned date NULL,
	CONSTRAINT loan_from_item_id_loaned_from_date_received_key UNIQUE (item_id, loaned_from, date_received),
	CONSTRAINT pk_loan_from_loan_from_id PRIMARY KEY (loan_from_id),
	CONSTRAINT fk_loan_from_item FOREIGN KEY (item_id) REFERENCES museum.item(item_id)
);

-- #10 Table 'Event'
-- Table contains data about museum's special events and their dates
CREATE TABLE IF NOT EXISTS museum."event" (
	event_id serial4 NOT NULL,
	title varchar NULL,
	theme varchar NULL,
	date_started date NULL DEFAULT CURRENT_DATE,
	date_ended date NULL,
	amount_issued int4 NULL,
	amount_available int4 NULL,
	ticket_price numeric NULL,
	CONSTRAINT event_title_theme_date_started_key UNIQUE (title, theme, date_started),
	CONSTRAINT pk_event_event_id PRIMARY KEY (event_id)
);

-- #11 Table 'Item Event'
-- Table dedicated to having information about what art pieces are displayed at a particular event
-- This table serves as conversion of many-to-many relation between 'item' and 'event' tables  
CREATE TABLE IF NOT EXISTS museum.item_event (
	id serial4 NOT NULL,
	item_id int4 NOT NULL,
	event_id int4 NOT NULL,
	last_updated date NULL DEFAULT CURRENT_DATE,
	CONSTRAINT item_event_item_id_event_id_key UNIQUE (item_id, event_id),
	CONSTRAINT pk_item_event_id PRIMARY KEY (id),
	CONSTRAINT fk_item_event_event FOREIGN KEY (event_id) REFERENCES museum."event"(event_id),
	CONSTRAINT fk_item_event_item FOREIGN KEY (item_id) REFERENCES museum.item(item_id)
);

-- #12 Table 'Ticket'
-- Table keeps track of ticket sales; both onsite and on the website
CREATE TABLE IF NOT EXISTS museum.ticket (
	ticket_id serial4 NOT NULL,
	event_id int4 NOT NULL,
	date_sold date NULL DEFAULT CURRENT_DATE,
	"location" varchar NULL,
	review int4 NULL,
	last_updated date NULL DEFAULT CURRENT_DATE,
	CONSTRAINT pk_ticket_ticket_id PRIMARY KEY (ticket_id),
	CONSTRAINT fk_ticket_event FOREIGN KEY (event_id) REFERENCES museum."event"(event_id)
);

-- Functions & Triggers --

-- #1 Function for the task 4a
-- Function that updates data in one of the tables
CREATE OR REPLACE FUNCTION museum.item_style_update (IN p_item_id BIGINT, p_title VARCHAR, p_style VARCHAR)
RETURNS BIGINT  
AS $$
BEGIN 
	
UPDATE
	museum.item i
SET
	"style" = p_style
WHERE
	i.item_id = p_item_id
	AND LOWER(i.title) LIKE LOWER('%' || p_title || '%');

IF NOT FOUND THEN 
	RAISE NOTICE 'Item is not found.';
END IF;

RETURN p_item_id;

END $$
LANGUAGE plpgsql;

 -- SELECT museum.item_style_update (1, 'Blue Smth', 'New Style');
 -- SELECT museum.item_style_update (100, 'Blue Smth', 'New Style');

-- #2 Function for the task 4b
-- Function that adds new transaction to the transaction table
CREATE OR REPLACE FUNCTION museum.transaction_insert_new_row
	(IN p_title VARCHAR, p_author VARCHAR, p_date_bought DATE, p_price_bought NUMERIC, p_bought_from VARCHAR) 
RETURNS BIGINT 
AS $$ 
DECLARE 
	v_transaction_id BIGINT;
BEGIN 
	
INSERT INTO museum."transaction"
(item_id, date_bought, date_sold, price_bought, price_sold, bought_from, sold_to)
VALUES
((SELECT item_id FROM museum.item WHERE LOWER(title) = LOWER(p_title) AND LOWER(author) = LOWER(p_author)), p_date_bought, 
NULL, p_price_bought, NULL, INITCAP(p_bought_from), NULL)
ON CONFLICT ON CONSTRAINT transaction_item_id_date_bought_price_bought_bought_from_key DO NOTHING
RETURNING transaction_id INTO v_transaction_id;

RETURN COALESCE(v_transaction_id, -1);

EXCEPTION 
	WHEN SQLSTATE '23502' THEN
	RAISE NOTICE 'Item is not found. Please check table ''Item'' for matching title and author.';

RETURN COALESCE(v_transaction_id, -1);

END $$
LANGUAGE plpgsql;

 -- SELECT museum.transaction_insert_new_row('Marvelous Day', 'PICASSO', '2021-12-15', 12000, 'public gallery');
 -- SELECT museum.transaction_insert_new_row('Bla', 'PICASSO', '2021-12-15', 12000, 'public gallery');

-- #3 Function
-- Function that updates status column in the 'item' table; to keep track of the art piece location
CREATE OR REPLACE FUNCTION museum.item_status_update()
RETURNS TRIGGER 
AS 
$$
BEGIN 
WITH t AS (
	SELECT
		i.title AS title,
		i.item_id AS item_id,
-- below case provides comment regarding item's location
		CASE 
			i.item_id 
			WHEN s.item_id THEN 'InStorage'
			WHEN l.item_id THEN 'InLoan'
			WHEN ie.item_id THEN 'AtEvent'
			WHEN t.item_id THEN 'Sold'
			ELSE 'OnSite'
		END AS place
	FROM
		museum.item i
	LEFT JOIN "transaction" t ON 
		t.item_id = i.item_id AND t.date_sold IS NOT NULL 
	LEFT JOIN museum."storage" s ON
		s.item_id = i.item_id
	LEFT JOIN museum.loan_to l ON
		l.item_id = i.item_id AND l.date_returned IS NULL OR l.date_returned >= current_date
	LEFT JOIN 
		(
		SELECT
			ie.item_id
		FROM
			museum.item_event ie
		INNER JOIN museum."event" e ON
			ie.event_id = e.event_id AND (e.date_ended IS NULL OR e.date_ended >= current_date)) ie ON
		ie.item_id = i.item_id)
UPDATE
	museum.item i
SET
	status = place
FROM
	t
WHERE
	i.item_id = t.item_id;
RETURN NEW;
END 
$$
LANGUAGE plpgsql;

-- below triggers are needed for timely 'item' table updates
CREATE OR REPLACE TRIGGER item_status_update1
AFTER INSERT OR UPDATE ON museum."storage"
FOR EACH ROW
EXECUTE PROCEDURE museum.item_status_update();

CREATE OR REPLACE TRIGGER item_status_update2
AFTER INSERT OR UPDATE ON museum.loan_to
FOR EACH ROW
EXECUTE PROCEDURE museum.item_status_update();

CREATE OR REPLACE TRIGGER item_status_update3
AFTER INSERT OR UPDATE ON museum.item_event 
FOR EACH ROW
EXECUTE PROCEDURE museum.item_status_update();

CREATE OR REPLACE TRIGGER item_status_update4
AFTER INSERT OR UPDATE ON museum."event"
FOR EACH ROW
EXECUTE PROCEDURE museum.item_status_update();

-- #4 Function
-- This function compares the amount_issued column at 'event' table with the 'ticket' table; to prevent overselling from happening
-- It throws error if amount being inserted in 'ticket' table exceeds tickets' amount_issued
CREATE OR REPLACE FUNCTION museum.event_amount_available_update() 
RETURNS TRIGGER 
AS $$ 
DECLARE 
	availability record;
BEGIN 
	
WITH t AS (	
	SELECT MAX(e.amount_issued) - COUNT(t.ticket_id) AS ticket_count, e.title 
	FROM museum."event" e
	LEFT JOIN museum.ticket t 
	USING (event_id)
	GROUP BY e.title),
	tt AS (
	UPDATE
		museum."event" e
	SET
		amount_available = t.ticket_count 
	FROM 
		t
	WHERE
		e.title = t.title)
	SELECT ticket_count, title INTO availability FROM t;

IF MIN(availability.ticket_count) <= 0 THEN 
	RAISE EXCEPTION 'Not enough availbale tickets for % event.', availability.title;  
END IF;

RETURN NEW ;

END $$
LANGUAGE plpgsql;

-- below triggers are required for the timely DB response on user's actions
CREATE OR REPLACE TRIGGER event_amount_available_update
AFTER INSERT OR UPDATE ON museum.ticket
FOR EACH ROW
EXECUTE PROCEDURE museum.event_amount_available_update();

CREATE OR REPLACE TRIGGER ticket_availability_check
AFTER INSERT OR UPDATE ON museum.ticket
FOR EACH ROW
EXECUTE PROCEDURE museum.event_amount_available_update();

-- DML Part --

-- #1 Table 'Country'
INSERT INTO museum.country 
(region, country, city)
VALUES
('Ile-de-France', 'France', 'Paris'),
('Essex', 'Great Britain', 'London'),
('Centre Centro', 'Italy', 'Palermo'),
('North Africa', 'Morocco', 'Rabat'),
('Aragon', 'Spain', 'Madrid')
ON CONFLICT ON CONSTRAINT country_country_city_key DO NOTHING;

-- #2 Table 'Country Historical'
INSERT INTO museum.country_historical
(region, country, city, country_id)
VALUES
('Berry', 'France', 'Paris', (SELECT country_id FROM museum.country WHERE LOWER(country) = 'france' AND LOWER(city) = 'paris')),
('North East', 'Great Britain', 'London', (SELECT country_id FROM museum.country WHERE LOWER(country) = 'great britain' AND LOWER(city) = 'london')),
('Andalusia', 'Spain', 'Palermo',  (SELECT country_id FROM museum.country WHERE LOWER(country) = 'italy' AND LOWER(city) = 'palermo')),
('North Africa', 'Morocco', 'Rabat', (SELECT country_id FROM museum.country WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat')),
('Aragon', 'Spain', 'Madrid', (SELECT country_id FROM museum.country WHERE LOWER(country) = 'spain' AND LOWER(city) = 'madrid'))
ON CONFLICT ON CONSTRAINT country_historical_country_city_key DO NOTHING;

-- #3 Table 'Collection'
INSERT INTO museum.collection
("name")
VALUES
('Old Skeleton'), 
('Blue Paintings'), 
('12 Pieces Service'), 
('Tolstoy First Edition'), 
('3 Random Pieces')
ON CONFLICT ON CONSTRAINT collection_name_key DO NOTHING;

-- #4 Table 'Item'
INSERT INTO museum.item
(title, author, year_started, year_ended, "type", "style", collection_id, country_h_id, weight, "width", "length", "height", on_repair, status)
VALUES
('Blue Smth', 'Pete Davidon', '1675-01-01', '1677-01-01', 'Painting', 'Impressionism', (SELECT collection_id FROM museum.collection WHERE LOWER("name") = 'blue paintings'),
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'france' AND LOWER(city) = 'paris'), 1, 50, 40, NULL, false, NULL),
('Blue Moon', 'Pete Davidon', '1676-01-01', '1678-01-01', 'Painting', 'Impressionism', (SELECT collection_id FROM museum.collection WHERE LOWER("name") = 'blue paintings'),
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'france' AND LOWER(city) = 'paris'), 1, 75, 40, NULL, 'yes', NULL),
('Vase with Flowers', 'Martha Stuart', '1888-01-01', '1888-01-01', 'Painting', 'Modern', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'palermo'), 0.5, 75, 30, NULL, 'no', NULL),
('Skull', DEFAULT, '504-01-01', '550-01-01', 'Bone', NULL, (SELECT collection_id FROM museum.collection WHERE LOWER("name") = 'old skeleton'),
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'palermo'), 0.3, 20, 15, 10, 'no', NULL),
('Old Book', 'Priest Vladimir', '1341-01-01', '1351-01-01', 'Book', 'Gothic', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat'), 1.5, 25, 35, 5, 'no', NULL),
('Sunset', 'Picasso', '1841-01-01', '1841-01-01', 'Painting', 'Graphic', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat'), 1, 80, 80, NULL, 'no', NULL),
('Sea Breeze', 'Picasso', '1842-01-01', '1843-01-01', 'Painting', 'New Wave', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat'), 1, 80, 80, NULL, 'no', NULL),
('Morning Forest', 'Picasso', '1840-01-01', '1841-01-01', 'Painting', 'Graphic', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat'), 1, 80, 80, NULL, 'no', NULL),
('Mountain Snow', 'Picasso', '1840-01-01', '1841-01-01', 'Painting', 'Graphic', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat'), 1, 80, 80, NULL, 'no', NULL),
('Marvelous Day', 'Picasso', '1840-01-01', '1841-01-01', 'Painting', 'Graphic', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'morocco' AND LOWER(city) = 'rabat'), 1, 80, 80, NULL, 'no', NULL),
('Birds', 'Dali', '1940-01-01', '1940-01-01', 'Painting', 'Nuar', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'madrid'), 1, 80, 80, NULL, 'no', NULL),
('Sky', 'Dali', '1940-01-01', '1940-01-01', 'Painting', 'Nuar', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'madrid'), 1, 80, 80, NULL, 'no', NULL),
('Smth by Dali', 'Dali', '1940-01-01', '1940-01-01', 'Painting', 'Nuar', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'madrid'), 1, 80, 80, NULL, 'no', NULL),
('Portrait', 'Dali', '1940-01-01', '1940-01-01', 'Painting', 'Nuar', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'madrid'), 1, 80, 80, NULL, 'no', NULL),
('Circle', 'Dali', '1940-01-01', '1940-01-01', 'Painting', 'Nuar', NULL,
(SELECT country_h_id FROM museum.country_historical WHERE LOWER(country) = 'spain' AND LOWER(city) = 'madrid'), 1, 80, 80, NULL, 'no', NULL)
ON CONFLICT ON CONSTRAINT item_title_author_year_started_year_ended_key DO NOTHING;

-- #5 Table 'Item Keyword'
INSERT INTO museum.item_keyword
(item_id, keyword)
VALUES
((SELECT item_id FROM museum.item WHERE title = 'Blue Smth' AND author = 'Pete Davidon'), 'Blue'),
((SELECT item_id FROM museum.item WHERE title = 'Blue Moon' AND author = 'Pete Davidon'), 'Blue'),
((SELECT item_id FROM museum.item WHERE title = 'Blue Moon' AND author = 'Pete Davidon'), 'Moon'),
((SELECT item_id FROM museum.item WHERE title = 'Vase with Flowers' AND author = 'Martha Stuart'), 'Red'),
((SELECT item_id FROM museum.item WHERE title = 'Vase with Flowers' AND author = 'Martha Stuart'), 'Flower'),
((SELECT item_id FROM museum.item WHERE title = 'Skull' AND author = 'unknown'), 'Rare'),
((SELECT item_id FROM museum.item WHERE title = 'Old Book' AND author = 'Priest Vladimir'), 'Slavic'),
((SELECT item_id FROM museum.item WHERE title = 'Old Book' AND author = 'Priest Vladimir'), 'Original')
ON CONFLICT ON CONSTRAINT item_keyword_item_id_keyword_key DO NOTHING;

-- #6 Table 'Storage'
INSERT INTO museum."storage"
(item_id, "floor", room, shelf)
VALUES
((SELECT item_id FROM museum.item WHERE title = 'Blue Smth' AND author = 'Pete Davidon'), 1, 2, 5),
((SELECT item_id FROM museum.item WHERE title = 'Blue Moon' AND author = 'Pete Davidon'), 2, 3, 5),
((SELECT item_id FROM museum.item WHERE title = 'Vase with Flowers' AND author = 'Martha Stuart'), 1, 3, 4),
((SELECT item_id FROM museum.item WHERE title = 'Skull' AND author = 'unknown'), 1, 4, 5),
((SELECT item_id FROM museum.item WHERE title = 'Old Book' AND author = 'Priest Vladimir'), 2, 3, 7)
ON CONFLICT ON CONSTRAINT storage_item_id_floor_room_shelf_key DO NOTHING;

-- #7 Table 'Transaction'
INSERT INTO museum."transaction"
(item_id, date_bought, date_sold, price_bought, price_sold, bought_from, sold_to)
VALUES
((SELECT item_id FROM museum.item WHERE title = 'Blue Smth' AND author = 'Pete Davidon'), '2020-01-06', NULL, 1500, NULL, 'Museum of Art', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Blue Moon' AND author = 'Pete Davidon'), '2019-01-13', NULL, 200, NULL, 'Modern Art NY', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Vase with Flowers' AND author = 'Martha Stuart'), '2020-07-06', NULL, 20000, NULL, 'Mary Smith Co', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Skull' AND author = 'unknown'), '2020-05-06', NULL, 152.3, NULL, 'Museum of Art', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Old Book' AND author = 'Priest Vladimir'), '2020-12-13', NULL, 0, NULL, 'Anna Lochart', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Sunset' AND author = 'Picasso'), '2017-12-13', NULL, 0, NULL, 'Anna Lochart', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Sea Breeze' AND author = 'Picasso'), '2017-12-13', NULL, 0, NULL, 'Anna Lochart', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Morning Forest' AND author = 'Picasso'), '2017-12-13', NULL, 0, NULL, 'Anna Lochart', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Mountain Snow' AND author = 'Picasso'), '2017-12-13', NULL, 0, NULL, 'Anna Lochart', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Marvelous Day' AND author = 'Picasso'), '2017-12-13', '2021-12-10', 0, 10000, 'Anna Lochart', 'Public Gallery')
ON CONFLICT ON CONSTRAINT transaction_item_id_date_bought_price_bought_bought_from_key DO NOTHING;

-- #8 Table 'Loan To'
INSERT INTO museum.loan_to
(item_id, loaned_to, date_sent, date_returned)
VALUES
((SELECT item_id FROM museum.item WHERE title = 'Sunset' AND author = 'Picasso'), 'Public Gallery', '2020-11-05', '2020-11-10'), 
((SELECT item_id FROM museum.item WHERE title = 'Sea Breeze' AND author = 'Picasso'), 'Public Gallery', '2020-11-05', '2020-11-10'), 
((SELECT item_id FROM museum.item WHERE title = 'Morning Forest' AND author = 'Picasso'), 'Public Gallery', '2020-11-05', '2020-11-10'), 
((SELECT item_id FROM museum.item WHERE title = 'Mountain Snow' AND author = 'Picasso'), 'Public Gallery', '2020-11-05', NULL), 
((SELECT item_id FROM museum.item WHERE title = 'Marvelous Day' AND author = 'Picasso'), 'Public Gallery', '2020-11-05', '2020-11-10')
ON CONFLICT ON CONSTRAINT loan_to_item_id_loaned_to_date_sent_key DO NOTHING;

-- #9 Table 'Loan From'
INSERT INTO museum.loan_from
(item_id, loaned_from, date_received, date_returned)
VALUES
((SELECT item_id FROM museum.item WHERE title = 'Birds' AND author = 'Dali'), 'Public Gallery', '2021-12-05', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Sky' AND author = 'Dali'), 'Public Gallery', '2021-12-05', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Smth by Dali' AND author = 'Dali'), 'Public Gallery', '2021-12-05', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Portrait' AND author = 'Dali'), 'Public Gallery', '2021-12-05', NULL),
((SELECT item_id FROM museum.item WHERE title = 'Circle' AND author = 'Dali'), 'Public Gallery', '2021-12-05', NULL)
ON CONFLICT ON CONSTRAINT loan_from_item_id_loaned_from_date_received_key DO NOTHING;

-- #10 Table 'Event'
INSERT INTO museum."event"
(title, theme, date_started, date_ended, amount_issued, amount_available, ticket_price)
VALUES
('Picasso. New Perspective.', 'Early Picasso', '2021-07-01', '2021-07-30', 3, NULL, 3),
('New Old Works of Picasso', 'Late Picasso', '2021-08-01', '2021-08-30', 3, NULL, 4),
('Picasso. New Vision.', 'Genius of Picasso', '2021-09-01', '2021-09-30', 2, NULL, 5),
('Dali. Early paintings.', 'Dali.', '2021-10-01', '2021-10-30', 2, NULL, 5),
('Dali. New Vision.', 'Dali. New Colors.', '2021-11-01', NULL, 2, NULL, 5)
ON CONFLICT ON CONSTRAINT event_title_theme_date_started_key DO NOTHING;

-- #11 Table 'Item Event'
INSERT INTO museum.item_event
(item_id, event_id)
VALUES
((SELECT item_id FROM museum.item WHERE title = 'Sunset' AND author = 'Picasso'), (SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Perspective.')),
((SELECT item_id FROM museum.item WHERE title = 'Sea Breeze' AND author = 'Picasso'), (SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Perspective.')),
((SELECT item_id FROM museum.item WHERE title = 'Morning Forest' AND author = 'Picasso'), (SELECT event_id FROM museum."event" WHERE title = 'New Old Works of Picasso')),
((SELECT item_id FROM museum.item WHERE title = 'Mountain Snow' AND author = 'Picasso'), (SELECT event_id FROM museum."event" WHERE title = 'New Old Works of Picasso')),
((SELECT item_id FROM museum.item WHERE title = 'Marvelous Day' AND author = 'Picasso'), (SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Vision.')),
((SELECT item_id FROM museum.item WHERE title = 'Birds' AND author = 'Dali'), (SELECT event_id FROM museum."event" WHERE title = 'Dali. Early paintings.')),
((SELECT item_id FROM museum.item WHERE title = 'Sky' AND author = 'Dali'), (SELECT event_id FROM museum."event" WHERE title = 'Dali. New Vision.'))
ON CONFLICT ON CONSTRAINT item_event_item_id_event_id_key DO NOTHING;

-- #12 Table 'Ticket'
-- This data is not unique; overselling causes error and scripted message to pop up 
INSERT INTO museum.ticket
(event_id, date_sold, "location", review)
VALUES 
((SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Perspective.'), '2021-06-30', 'Website', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Perspective.'), '2021-06-29', 'Cash Register', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Perspective.'), '2021-06-30', 'Website', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'New Old Works of Picasso'), '2021-07-30', 'Website', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'New Old Works of Picasso'), '2021-07-30', 'Cash Register', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'Picasso. New Vision.'), '2021-08-30', 'Website', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'Dali. Early paintings.'), '2021-09-30', 'Website', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'Dali. New Vision.'), '2021-10-30', 'Website', NULL),
((SELECT event_id FROM museum."event" WHERE title = 'Dali. New Vision.'), '2021-10-30', 'Website', NULL)
ON CONFLICT DO NOTHING;

-- Denormalized View for the task 5 --

-- #5 Function
-- This function collects all objects' column names from the selected schema 
CREATE OR REPLACE FUNCTION museum.schema_column_names()
RETURNS SETOF TEXT  
LANGUAGE plpgsql 
AS $$
DECLARE var TEXT; 
		spare TEXT;
BEGIN 
FOR var IN (SELECT DISTINCT table_name FROM information_schema.columns WHERE table_schema = 'museum')
LOOP 
EXECUTE FORMAT (' 
	SELECT STRING_AGG(REPLACE(column_name, column_name, ''%I.'' || column_name) || '' AS %I_'' || column_name, '', '')
	FROM information_schema.columns
	WHERE table_name = ''%I'' AND column_name NOT LIKE ''%%id%%''
	GROUP BY table_name', var, var, var) INTO spare;
	RETURN NEXT spare;
END LOOP;
END $$;

-- Temporary table to store and convert above function results into a string
CREATE TEMPORARY TABLE IF NOT EXISTS column_names AS (
SELECT
	STRING_AGG(schema_column_names, ', ') AS title
FROM
	museum.schema_column_names());

-- #6 Function 
-- This function is the second step of creating denormalized view of the whole DB
-- It creates view based on the first function results
DO $$   
DECLARE 
	var TEXT; 
BEGIN 
SELECT title INTO var FROM column_names;
EXECUTE (SELECT FORMAT 
			('CREATE OR REPLACE VIEW museum.denormalized_view AS 
			SELECT DISTINCT %s 
			FROM museum.item 
			LEFT JOIN museum.item_event USING(item_id)
			LEFT JOIN museum.event USING(event_id)
			LEFT JOIN museum.storage USING(item_id)
			LEFT JOIN museum.transaction USING(item_id)
			LEFT JOIN museum.loan_from USING(item_id)
			LEFT JOIN museum.loan_to USING(item_id)
			LEFT JOIN museum.ticket USING(event_id)
			LEFT JOIN museum.item_keyword USING(item_id) 
			LEFT JOIN museum.collection USING(collection_id) 
			LEFT JOIN museum.country_historical USING(country_h_id) 
			LEFT JOIN museum.country USING(country_id)
			WHERE "transaction".date_bought >= CURRENT_DATE - ''1 month'' :: INTERVAL OR 
			 "transaction".date_sold >= CURRENT_DATE - ''1 month'' :: INTERVAL OR 
			 ("transaction".date_bought IS NULL AND "transaction".date_sold IS NULL)', var));
END $$;

-- Role 'Manager' for the task 6 --

-- #7 Function 
DO $$
BEGIN
IF NOT EXISTS 
	(SELECT FROM pg_catalog.pg_roles WHERE rolname = 'manager') 
THEN
	REVOKE ALL PRIVILEGES ON DATABASE museum FROM PUBLIC;
	REVOKE ALL PRIVILEGES ON SCHEMA museum FROM PUBLIC;
	CREATE ROLE manager LOGIN;
	GRANT CONNECT ON DATABASE museum TO manager;
	GRANT USAGE ON SCHEMA museum TO manager;
	GRANT SELECT ON ALL TABLES IN SCHEMA museum TO manager;
END IF;
END $$;

-- SELECT * FROM information_schema.table_privileges WHERE grantee = 'manager';

/* -- cleaning part
DROP OWNED BY manager;
DROP ROLE manager;
*/

/* -- cleaning part
TRUNCATE museum.country CASCADE ;
TRUNCATE museum."event" CASCADE ;
TRUNCATE museum.collection CASCADE ;

ALTER SEQUENCE museum.country_country_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.country_historical_country_h_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.collection_collection_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.item_item_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.item_keyword_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.storage_storage_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.transaction_transaction_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.loan_to_loan_to_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.loan_from_loan_from_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.event_event_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.item_event_id_seq RESTART WITH 1;
ALTER SEQUENCE museum.ticket_ticket_id_seq RESTART WITH 1;
*/

/* -- add unique part
ALTER TABLE museum.country ADD UNIQUE (country, city);
ALTER TABLE museum.country_historical ADD UNIQUE (country, city);
ALTER TABLE museum.collection ADD UNIQUE ("name");
ALTER TABLE museum.item ADD UNIQUE (title, author, year_started, year_ended);
ALTER TABLE museum.item_keyword ADD UNIQUE (item_id, keyword);
ALTER TABLE museum."storage" ADD UNIQUE (item_id, "floor", room, shelf);
ALTER TABLE museum."transaction" ADD UNIQUE (item_id, date_bought, price_bought, bought_from);
ALTER TABLE museum.loan_to ADD UNIQUE (item_id, loaned_to, date_sent);
ALTER TABLE museum.loan_from ADD UNIQUE (item_id, loaned_from, date_received);
ALTER TABLE museum."event" ADD UNIQUE (title, theme, date_started, date_ended);
ALTER TABLE museum.item_event ADD UNIQUE (item_id, event_id);
ALTER TABLE museum.ticket ADD UNIQUE (item_id, event_id);
*/