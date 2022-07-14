CREATE TABLE sa_corporate.corporate_ext (
    transaction_id      CHAR(20),
    order_id            CHAR(20),
    order_date          CHAR(20),
    ship_date           CHAR(20),
    ship_mode           CHAR(20),
    customer_id         CHAR(20),
    customer_first_name CHAR(20),
    customer_last_name  CHAR(20),
    customer_email      CHAR(40),
    customer_gender     CHAR(20),
    "SEGMENT"           CHAR(20),
    city                CHAR(40),
    country             CHAR(40),
    market              CHAR(20),
    employee_first_name CHAR(20),
    employee_last_name  CHAR(20),
    employee_email      CHAR(40),
    employee_gender     CHAR(20),
    phone               CHAR(20),
    department          CHAR(40),
    job_skill           CHAR(60),
    employee_id         CHAR(20),
    product_id          CHAR(20),
    "CATEGORY"          CHAR(40),
    subcategory         CHAR(40),
    product_name        CHAR(120),
    product_desc        CHAR(60),
    sales               CHAR(20),
    quantity            CHAR(20),
    "COST"              CHAR(20),
    price               CHAR(20),
    payment_type        CHAR(20),
    payment_id          CHAR(20),
    start_date          CHAR(20)
)
ORGANIZATION EXTERNAL ( TYPE oracle_loader
    DEFAULT DIRECTORY sales ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
            SKIP 1
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' MISSING FIELD VALUES ARE NULL
    ) LOCATION ( 'source_corporate.csv' )
) REJECT LIMIT 0;