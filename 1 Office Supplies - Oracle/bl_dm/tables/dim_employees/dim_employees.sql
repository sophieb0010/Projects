CREATE TABLE dim_employees (
    employee_surr_id    NUMBER(9) NOT NULL,
    source_system       VARCHAR2(20) NOT NULL,
    source_entity       VARCHAR2(20) NOT NULL,
    source_id           VARCHAR2(20) NOT NULL,
    employee_first_name VARCHAR2(20) NOT NULL,
    employee_last_name  VARCHAR2(20) NOT NULL,
    employee_email      VARCHAR2(40) NOT NULL,
    employee_gender     VARCHAR2(20) NOT NULL,
    phone               VARCHAR2(20) NOT NULL,
    department          VARCHAR2(40) NOT NULL,
    job_skill           VARCHAR2(60) NOT NULL,
    insert_date         DATE NOT NULL,
    update_date         DATE NOT NULL,
    PRIMARY KEY ( employee_surr_id )
);