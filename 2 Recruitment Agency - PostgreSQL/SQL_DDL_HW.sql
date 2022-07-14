-- CREATE DATABASE agency;
-- Alt + X should work from here
-- 100% reusable, queries 43
CREATE SCHEMA IF NOT EXISTS public;
ALTER DATABASE agency SET search_path TO public;
SET client_encoding = 'UTF8';

-- Firstly, new ENUM types are created

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'remote_work') THEN
CREATE TYPE remote_work AS ENUM (
			'Office Only',
			'Remote Only',
			'Mixed');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'position_status') THEN
CREATE TYPE position_status AS ENUM (
			'Not Started',
			'In Progress',
			'Interview',
			'Closed');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'priority') THEN
CREATE TYPE priority AS ENUM (
			'High',
			'Medium',
			'Low');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'type_of_rate') THEN
CREATE TYPE type_of_rate AS ENUM (
			'Yearly',
			'Hourly',
			'Flat');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'level_of_education') THEN
CREATE TYPE level_of_education AS ENUM (
			'BA',
			'MA',
			'PhD',
			'Other');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'field_of_study') THEN
CREATE TYPE field_of_study AS ENUM (
			'Art',
			'Biology',
			'Computer Science',
			'Finance',
			'IT',
			'Other');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'line_of_work') THEN
CREATE TYPE line_of_work AS ENUM (
			'Biology',
			'Art',
			'IT',
			'Finance',
			'Other');
END IF;
END$$;

DO $$
BEGIN
IF NOT EXISTS (SELECT typname FROM pg_type WHERE typname = 'type_of_employment') THEN
CREATE TYPE type_of_employment AS ENUM (
			'Full-time',
			'Part-time',
			'Seasonal',
			'Internship');
END IF;
END$$;

-- Secondly, tables are created
-- Constraints and data types were transferred from logical model

-- #1 Table 'Applicant'
CREATE TABLE IF NOT EXISTS public.applicant (
	applicant_id serial4 NOT NULL,
	"name" text NOT NULL,
	surname text NOT NULL,
	sex text NOT NULL,
	date_of_birth date NOT NULL,
	phone text NOT NULL,
	email text NULL,
	date_available date NOT NULL,
	open_for_relocation bool NULL DEFAULT false,
	website_name text NULL,
	black_list bool NULL DEFAULT false,
	CONSTRAINT applicant_name_surname_date_of_birth_phone_key UNIQUE (name, surname, date_of_birth, phone),
	CONSTRAINT pk_applicant_applicant_id PRIMARY KEY (applicant_id));

-- #2 Table 'Country'
CREATE TABLE IF NOT EXISTS public.country (
	country_id serial4 NOT NULL,
	country text NULL,
	city text NULL,
	CONSTRAINT country_country_city_key UNIQUE (country, city),
	CONSTRAINT pk_country_country_id PRIMARY KEY (country_id));

-- #3 Table 'Correspondence Address'
CREATE TABLE IF NOT EXISTS public.correspondence_address (
	address_id serial4 NOT NULL,
	applicant_id int4 NOT NULL,
	zip_code int4 NOT NULL,
	country_id int4 NULL,
	street text NULL,
	building text NULL,
	flat text NULL,
	CONSTRAINT pk_correspondence_address_address_id PRIMARY KEY (address_id),
	CONSTRAINT uniqueness UNIQUE (applicant_id),
	CONSTRAINT fk_correspondence_address_applicant FOREIGN KEY (applicant_id) REFERENCES public.applicant(applicant_id),
	CONSTRAINT fk_correspondence_address_country FOREIGN KEY (country_id) REFERENCES public.country(country_id));

-- #4 Table 'Experience'
CREATE TABLE IF NOT EXISTS public.experience (
	job_id serial4 NOT NULL,
	applicant_id int4 NOT NULL,
	title text NULL,
	current_job bool NULL,
	company_name text NULL,
	"line_of_work" line_of_work NULL,
	"type_of_employment" type_of_employment NULL DEFAULT 'Full-time'::type_of_employment,
	start_date date NULL,
	end_date date NULL,
	country_id int4 NULL,
	CONSTRAINT experience_applicant_id_title_current_job_company_name_key UNIQUE (applicant_id, title, current_job, company_name),
	CONSTRAINT pk_experience_job_id PRIMARY KEY (job_id),
	CONSTRAINT fk_experience_applicant FOREIGN KEY (applicant_id) REFERENCES public.applicant(applicant_id),
	CONSTRAINT fk_experience_country FOREIGN KEY (country_id) REFERENCES public.country(country_id));

-- #5 Table 'Education'
CREATE TABLE IF NOT EXISTS public.education (
	education_id serial4 NOT NULL,
	applicant_id int4 NOT NULL,
	school text NULL,
	"level_of_education" level_of_education NOT NULL DEFAULT 'BA'::level_of_education,
	"field_of_study" field_of_study NULL,
	start_date date NULL,
	end_date date NULL,
	grade numeric NULL,
	CONSTRAINT education_applicant_id_school_level_of_education_field_of_s_key UNIQUE (applicant_id, school, level_of_education, field_of_study),
	CONSTRAINT pk_education_education_id PRIMARY KEY (education_id),
	CONSTRAINT fk_education_applicant FOREIGN KEY (applicant_id) REFERENCES public.applicant(applicant_id));

-- #6 Table 'Skill'
CREATE TABLE IF NOT EXISTS public.skill (
	skill_id serial4 NOT NULL,
	skill_name text NOT NULL,
	CONSTRAINT pk_skill_skill_id PRIMARY KEY (skill_id),
	CONSTRAINT skill_skill_name_key UNIQUE (skill_name));

-- #7 Table 'Applicant Skill'
CREATE TABLE IF NOT EXISTS public.applicant_skill (
	applicant_skill_id serial4 NOT NULL,
	applicant_id int4 NOT NULL,
	skill_id int4 NOT NULL,
	skill_level int4 NOT NULL,
	length_of_experience numeric NOT NULL,
	CONSTRAINT applicant_skill_applicant_id_skill_id_key UNIQUE (applicant_id, skill_id),
	CONSTRAINT pk_applicant_skill_applicant_skill_id PRIMARY KEY (applicant_skill_id),
	CONSTRAINT skill_level_range_check CHECK (((skill_level >= 1) AND (skill_level <= 5))),
	CONSTRAINT fk_applicant_skill_applicant FOREIGN KEY (applicant_id) REFERENCES public.applicant(applicant_id),
	CONSTRAINT fk_applicant_skill_skill FOREIGN KEY (skill_id) REFERENCES public.skill(skill_id));

-- #8 Table 'Client'
CREATE TABLE IF NOT EXISTS public.client (
	client_id serial4 NOT NULL,
	company_name text NULL,
	city text NULL,
	date_of_signing date NULL,
	date_of_termination date NULL,
	"type_of_rate" type_of_rate NULL,
	fee_rate numeric NULL,
	manager_id int4 NULL,
	CONSTRAINT client_company_name_city_date_of_signing_key UNIQUE (company_name, city, date_of_signing),
	CONSTRAINT pk_client_client_id PRIMARY KEY (client_id));

-- #9 Table 'Position'
CREATE TABLE IF NOT EXISTS public."position" (
	position_id serial4 NOT NULL,
	title text NOT NULL,
	"priority" priority NULL DEFAULT 'Low'::priority,
	client_id int4 NULL,
	date_open date NULL,
	date_close date NULL,
	"position_status" position_status NULL DEFAULT 'Not Started'::position_status,
	"line_of_work" line_of_work NULL,
	"type_of_employment" type_of_employment NULL DEFAULT 'Full-time'::type_of_employment,
	"remote_work" remote_work NULL DEFAULT 'Office Only'::remote_work,
	relocation bool NULL,
	experience int4 NULL,
	"level_of_education" level_of_education NULL DEFAULT 'BA'::level_of_education,
	country_id int4 NULL,
	salary numeric NULL,
	review int4 NULL,
	CONSTRAINT pk_position_position_id PRIMARY KEY (position_id),
	CONSTRAINT position_title_priority_client_id_date_open_experience_leve_key UNIQUE (title, priority, client_id, date_open, experience, level_of_education),
	CONSTRAINT review_range_check CHECK (((review >= 0) AND (review <= 5))),
	CONSTRAINT fk_position_client FOREIGN KEY (client_id) REFERENCES public.client(client_id),
	CONSTRAINT fk_position_country FOREIGN KEY (country_id) REFERENCES public.country(country_id));

-- #10 Table 'Position Skill'
CREATE TABLE IF NOT EXISTS public.position_skill (
	position_skill_id serial4 NOT NULL,
	position_id int4 NOT NULL,
	skill_id int4 NOT NULL,
	skill_level int4 NOT NULL,
	CONSTRAINT pk_position_skill_position_skill_id PRIMARY KEY (position_skill_id),
	CONSTRAINT position_skill_position_id_skill_id_key UNIQUE (position_id, skill_id),
	CONSTRAINT fk_position_skill_position FOREIGN KEY (position_id) REFERENCES public."position"(position_id),
	CONSTRAINT fk_position_skill_skill FOREIGN KEY (skill_id) REFERENCES public.skill(skill_id));

-- #11 Table 'Application'
CREATE TABLE IF NOT EXISTS public.application (
	application_id serial4 NOT NULL,
	"date" date NULL,
	position_id int4 NULL,
	applicant_id int4 NULL,
	CONSTRAINT application_position_id_applicant_id_key UNIQUE (position_id, applicant_id),
	CONSTRAINT pk_application_application_id PRIMARY KEY (application_id),
	CONSTRAINT fk_application_applicant FOREIGN KEY (applicant_id) REFERENCES public.applicant(applicant_id),
	CONSTRAINT fk_application_position FOREIGN KEY (position_id) REFERENCES public."position"(position_id));

-- #12 Table 'Interview'
CREATE TABLE IF NOT EXISTS public.interview (
	interview_id serial4 NOT NULL,
	application_id int4 NOT NULL,
	"date" date NULL,
	"result" bool NULL,
	CONSTRAINT pk_interview_interview_id PRIMARY KEY (interview_id),
	CONSTRAINT fk_interview_application FOREIGN KEY (application_id) REFERENCES public.application(application_id));

-- #13 Table 'Applicant List'
CREATE TABLE IF NOT EXISTS public.applicant_list (
	id serial4 NOT NULL,
	interview_id int4 NULL,
	"date" date NULL DEFAULT CURRENT_DATE,
	got_hired bool NULL,
	review int4 NULL,
	CONSTRAINT applicant_list_interview_id_date_key UNIQUE (interview_id, date),
	CONSTRAINT pk_applicant_list_id PRIMARY KEY (id),
	CONSTRAINT fk_applicant_list_interview FOREIGN KEY (interview_id) REFERENCES public.interview(interview_id));

-- Thirdly, inserting new data (Updated Rows should be 78)

-- #1 Table 'Applicant'
CREATE OR REPLACE FUNCTION insert_into_applicant()
RETURNS TABLE (tt INTEGER) 
LANGUAGE plpgsql
AS 
$$
BEGIN 
RETURN QUERY
WITH temp_table AS (
INSERT INTO applicant
(name, surname, sex, date_of_birth, phone, email, date_available, open_for_relocation, website_name, black_list)
VALUES
('Bob', 'Brown', 'm', '1990/04/14', '375293655411', 'bb@gmail.com', '2022/01/01', 'yes', 'link.com', 'yes'),
('Gretta', 'Black', 'f', '1982/02/01', '48756223555', 'gb@mail.ru',	'2021/12/05', 'no', 'jobboard.com' , 'no'),
('Ben', 'Yellow', 'm', '1974/01/05', '375293655422', 'by@yahoo.com', '2021/12/04', 'yes', 'link.com', 'no')
ON CONFLICT ON CONSTRAINT applicant_name_surname_date_of_birth_phone_key DO NOTHING
RETURNING applicant_id)
SELECT applicant_id FROM temp_table;

END;
$$;

CREATE TABLE IF NOT EXISTS temp_table (applicant_id) AS (SELECT insert_into_applicant());

-- #2 Table 'Country'
INSERT INTO country 
(country, city)
VALUES
('Belarus', 'Minsk'),
('Belarus', 'Gomel'),
('Poland', 'Warsaw')
ON CONFLICT ON CONSTRAINT country_country_city_key DO NOTHING;

-- #3 Table 'Correspondence Address'
INSERT INTO correspondence_address
(applicant_id, zip_code, country_id, street, building, flat)
VALUES
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), 222015, (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='gomel'), 'Pobeditelej', 12, 13),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), 223950, (SELECT country_id FROM country WHERE lower(country)='poland' AND lower(city)='warsaw'), 'Stroitelej', 14, 14),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), 222012, (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='minsk'), 'Burdejnogo', 23, 15)
ON CONFLICT ON CONSTRAINT uniqueness DO NOTHING;

-- #4 Table 'Experience'
INSERT INTO experience 
(applicant_id, title, current_job, company_name, line_of_work, start_date, end_date, country_id)
VALUES
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), 'Junior Engineer', 'yes', 'CoolTech', 'IT', '2017/06/01', NULL, (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='gomel')),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), 'Junior Engineer', 'no', 'NotSoCoolTech', 'IT','2017/06/01', '2018/09/10', (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='gomel')),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), 'Data Analyst', 'yes', 'Google', 'IT', '2019/06/01', NULL, (SELECT country_id FROM country WHERE lower(country)='poland' AND lower(city)='warsaw')),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), 'Team Lead', 'yes', 'EPAM', 'IT', '2020/06/01', NULL, (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='minsk')) ,
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), 'Senior Developer', 'no', 'Netflix', 'IT', '2018/10/01', '2019/02/01', (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='minsk')),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), 'Junior Developer', 'no', 'META', 'IT', '2017/06/01', '2018/09/10', (SELECT country_id FROM country WHERE lower(country)='belarus' AND lower(city)='minsk'))
ON CONFLICT ON CONSTRAINT experience_applicant_id_title_current_job_company_name_key DO NOTHING;

-- #5 Table 'Education'
INSERT INTO education
(applicant_id, school, level_of_education, field_of_study, start_date, end_date, grade)
VALUES 
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), 'Main University', DEFAULT, 'Computer Science', '2013/09/01', '2016/06/01', 3.5),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), 'Warsaw Uni', 'PhD', 'Computer Science', '2016/09/01', '2021/06/01', 4.7),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), 'Minskij Technological', DEFAULT, 'Computer Science', '2010/09/01', '2015/06/01', 2.8)
ON CONFLICT ON CONSTRAINT education_applicant_id_school_level_of_education_field_of_s_key DO NOTHING;

-- #6 Table 'Skill'
INSERT INTO skill
(skill_name)
VALUES 
('SQL'),
('Python'),
('Excel'),
('PowerBI'),
('Math')
ON CONFLICT ON CONSTRAINT skill_skill_name_key DO NOTHING;

-- #7 Table 'Applicant Skill'
INSERT INTO applicant_skill
(applicant_id, skill_id, skill_level, length_of_experience)
VALUES
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'sql'), 3, 1),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'python'), 4, 3),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 0), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'math'), 2, 10),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'sql'), 4, 3.5),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'python'), 5, 4.25),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'excel'), 1, 0.5),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'powerbi'), 3, 1),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'sql'), 5, 10),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'python'), 2, 0.5),
((SELECT applicant_id  FROM temp_table LIMIT 1 OFFSET 2), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'math'), 5, 15)
ON CONFLICT ON CONSTRAINT applicant_skill_applicant_id_skill_id_key DO NOTHING;

-- #8 Table 'Client'
INSERT INTO client 
(company_name, city, date_of_signing, date_of_termination, type_of_rate, fee_rate, manager_id)
VALUES 
('CoolCo', 'Minsk', '2016/01/12', '2017/02/06', 'Yearly', 20, 1),
('CoolCo', 'Grodno', '2017/06/25', NULL, 'Yearly', 20, 1),
('CoolCo', 'Gomel', '2018/11/05', NULL, 'Flat', 5000, 1)
ON CONFLICT ON CONSTRAINT client_company_name_city_date_of_signing_key DO NOTHING;

-- #9 Table 'Position'
CREATE OR REPLACE FUNCTION insert_into_position()
RETURNS TABLE (tt INTEGER) 
LANGUAGE plpgsql
AS 
$$
BEGIN 
RETURN QUERY
WITH temp_table_1 AS (
INSERT INTO position 
(title, priority, client_id, date_open, date_close, position_status, line_of_work, type_of_employment, remote_work, relocation, 
experience, level_of_education, country_id, salary, review)
VALUES 
('Senior Developer', 'High', (SELECT client_id FROM client WHERE lower(company_name)='coolco' AND lower(city) = 'gomel'), '2021/12/01', NULL, 
DEFAULT, 'IT', 'Full-time', 'Mixed', 'yes', 1, DEFAULT, 1, NULL, NULL),
('Developer', DEFAULT, (SELECT client_id FROM client WHERE lower(company_name)='coolco' AND lower(city) = 'gomel'), '2021/12/05', NULL, 
DEFAULT, 'IT', 'Full-time', 'Remote Only', 'no', 2, DEFAULT, 2, NULL, NULL),
('Data Analyst', 'Medium', (SELECT client_id FROM client WHERE lower(company_name)='coolco' AND lower(city) = 'grodno'), '2021/12/10', NULL, 
DEFAULT, 'IT', 'Full-time', 'Mixed', 'yes', 3, DEFAULT, 3, NULL, NULL)
ON CONFLICT ON CONSTRAINT position_title_priority_client_id_date_open_experience_leve_key DO NOTHING
RETURNING position_id)
SELECT position_id FROM temp_table_1;

END;
$$;

CREATE TABLE IF NOT EXISTS temp_table_1 (position_id) AS (SELECT insert_into_position());

-- #10 Table 'Position Skill'
INSERT INTO position_skill
(position_id, skill_id, skill_level)
VALUES 
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 0), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'sql'), 2),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 0), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'python'), 3),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 0), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'math'), 3),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'sql'), 3),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'python'), 2),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 1), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'math'), 4),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 2), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'sql'), 3),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 2), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'powerbi'), 2),
((SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 2), (SELECT skill_id FROM skill WHERE lower(skill_name) = 'excel'), 2)
ON CONFLICT ON CONSTRAINT position_skill_position_id_skill_id_key DO NOTHING;

-- #11 Table 'Application'
INSERT INTO application 
(date, position_id, applicant_id)
VALUES 
('2021/12/03', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 0), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 0)),
('2021/12/02', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 0), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 1)),
('2021/12/01', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 0), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 2)),
('2021/12/05', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 1), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 0)),
('2021/12/06', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 1), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 1)),
('2021/12/05', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 1), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 2)),
('2021/12/10', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 2), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 0)),
('2021/12/11', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 2), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 1)),
('2021/12/11', (SELECT position_id FROM temp_table_1 LIMIT 1 OFFSET 2), (SELECT applicant_id FROM temp_table LIMIT 1 OFFSET 2))
ON CONFLICT ON CONSTRAINT application_position_id_applicant_id_key DO NOTHING;

-- #12 Table 'Interview'
CREATE TABLE IF NOT EXISTS temp_interview AS -- this temporary table handles the selection process based on the skills' 
SELECT                                   	 -- overlap between candidate and position
	a2.application_id,
	t."rank",
	a2.position_id,
	a2.applicant_id,
	t.points
FROM
	(
	SELECT
		DENSE_RANK () OVER(PARTITION BY a.position_id ORDER BY COUNT(as2.skill_level) DESC) AS "rank",
		a.position_id ,
		a.applicant_id ,
		COUNT(as2.skill_level) AS points
	FROM
		application a
	INNER JOIN position_skill ps ON
		a.position_id = ps.position_id
	LEFT JOIN applicant_skill as2 ON
		as2.skill_id = ps.skill_id
		AND as2.applicant_id = a.applicant_id
	WHERE
		ps.skill_level <= as2.skill_level
		OR as2.skill_level IS NULL
	GROUP BY
		a.position_id,
		a.applicant_id
	ORDER BY
		a.position_id ASC,
		points DESC,
		a.applicant_id ASC) t
INNER JOIN application a2 ON
	a2.applicant_id = t.applicant_id AND 
	a2.position_id = t.position_id
WHERE
	"rank" <= 5;

CREATE OR REPLACE FUNCTION insert_into_interview()
RETURNS TABLE (tt INTEGER) 
LANGUAGE plpgsql
AS 
$$
BEGIN 
RETURN QUERY
WITH temp_table_2 AS (
INSERT INTO interview 
(application_id, date, result)
VALUES
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 0), '2021/12/10', 'yes'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 1), '2021/12/10', 'no'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 2), '2021/12/10', 'yes'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 3), '2021/12/10', 'yes'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 4), '2021/12/10', 'yes'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 5), '2021/12/10', 'no'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 6), '2021/12/10', 'yes'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 7), '2021/12/10', 'yes'),
((SELECT application_id FROM temp_interview LIMIT 1 OFFSET 8), '2021/12/10', 'no')
RETURNING interview_id, result)
SELECT interview_id FROM temp_table_2 WHERE result = 'yes';
END;
$$;

CREATE TABLE IF NOT EXISTS temp_table_2 (interview_id) AS (SELECT insert_into_interview());

-- #13 Table 'Applicant List'
INSERT INTO applicant_list
(interview_id, date, got_hired, review )
VALUES 
((SELECT interview_id FROM temp_table_2 LIMIT 1 OFFSET 0), DEFAULT, NULL, NULL),
((SELECT interview_id FROM temp_table_2 LIMIT 1 OFFSET 1), DEFAULT, NULL, NULL),
((SELECT interview_id FROM temp_table_2 LIMIT 1 OFFSET 2), DEFAULT, NULL, NULL),
((SELECT interview_id FROM temp_table_2 LIMIT 1 OFFSET 3), DEFAULT, NULL, NULL),
((SELECT interview_id FROM temp_table_2 LIMIT 1 OFFSET 4), DEFAULT, NULL, NULL),
((SELECT interview_id FROM temp_table_2 LIMIT 1 OFFSET 5), DEFAULT, NULL, NULL)
ON CONFLICT ON CONSTRAINT applicant_list_interview_id_date_key DO NOTHING;

-- Alter all tables and add 'record_ts' field to each table. Make it not null and set its default value to current_date.
DO 
$$
DECLARE
    selectrow RECORD;
BEGIN
	FOR selectrow IN
    	SELECT 
      		  'ALTER TABLE '|| t.mytable || ' ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date' AS script 
   		FROM 
			  (SELECT tablename AS mytable FROM pg_tables WHERE schemaname  = 'public') t
	LOOP EXECUTE selectrow.script;
	END LOOP;
END;
$$;

/* 
-- Script for restarting sequences
ALTER SEQUENCE applicant_applicant_id_seq RESTART WITH 1;
ALTER SEQUENCE correspondence_address_address_id_seq RESTART WITH 1;
ALTER SEQUENCE country_country_id_seq RESTART WITH 1;
ALTER SEQUENCE applicant_skill_applicant_skill_id_seq RESTART WITH 1;
ALTER SEQUENCE position_position_id_seq RESTART WITH 1;
ALTER SEQUENCE position_skill_position_skill_id_seq RESTART WITH 1;
ALTER SEQUENCE application_application_id_seq RESTART WITH 1;
ALTER SEQUENCE interview_interview_id_seq RESTART WITH 1;
ALTER SEQUENCE applicant_list_id_seq RESTART WITH 1;
ALTER SEQUENCE education_education_id_seq RESTART WITH 1;
ALTER SEQUENCE experience_job_id_seq RESTART WITH 1;
ALTER SEQUENCE skill_skill_id_seq RESTART WITH 1;
ALTER SEQUENCE client_client_id_seq RESTART WITH 1;
*/

/*
-- Script for deleting tables
DROP TABLE temp_table;
DROP TABLE temp_table_1;
DROP TABLE temp_table_2;
DROP TABLE temp_interview;
*/

/* 
-- Script for deleting all data
TRUNCATE applicant CASCADE;
TRUNCATE skill CASCADE;
TRUNCATE client CASCADE;
TRUNCATE country CASCADE;
*/