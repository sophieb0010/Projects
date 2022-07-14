CREATE TABLE prm_mta_incremental_load (
    sa_table_name        VARCHAR2(50) NOT NULL,
    target_table_name    VARCHAR2(50) NOT NULL,
    package_name         VARCHAR2(50) NOT NULL,
    procedure_name       VARCHAR2(50) NOT NULL,
    previous_loaded_date TIMESTAMP NOT NULL
);