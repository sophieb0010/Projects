-- log table
CREATE TABLE log_table (
    log_id         NUMBER,
    log_date       DATE,
    log_time       VARCHAR(200),
    log_mesage     VARCHAR(200),
    user_name      VARCHAR(200),
    package_name   VARCHAR(200),
    procedure_name VARCHAR(200),
    rows_inserted  NUMBER,
    rows_updated   NUMBER,
    error_code     VARCHAR(200),
    error_message  VARCHAR(200)
);