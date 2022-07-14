CREATE TABLE dim_dates (
    date_id           DATE NOT NULL,
    day_num_of_week   NUMBER(9) NOT NULL,
    day_name          VARCHAR2(50) NOT NULL,
    day_num_of_month  NUMBER(9) NOT NULL,
    day_num_of_year   NUMBER(9) NOT NULL,
    week_num_of_year  NUMBER(9) NOT NULL,
    month_num_of_year NUMBER(9) NOT NULL,
    month_name        VARCHAR2(50) NOT NULL,
    quarter_num       NUMBER(9) NOT NULL,
    year_num          NUMBER(9) NOT NULL,
    insert_date       DATE NOT NULL,
    update_date       DATE NOT NULL,
    PRIMARY KEY ( date_id )
);