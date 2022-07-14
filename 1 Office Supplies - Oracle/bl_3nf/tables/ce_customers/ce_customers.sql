CREATE TABLE ce_customers (
    customer_id         NUMBER(9) NOT NULL,
    source_system       VARCHAR2(20) NOT NULL,
    source_entity       VARCHAR2(20) NOT NULL,
    source_id           VARCHAR2(20) NOT NULL,
    customer_first_name VARCHAR2(20) NOT NULL,
    customer_last_name  VARCHAR2(20) NOT NULL,
    customer_email      VARCHAR2(40) NOT NULL,
    customer_gender     VARCHAR2(20) NOT NULL,
    insert_date         DATE NOT NULL,
    update_date         DATE NOT NULL,
    PRIMARY KEY ( customer_id )
);