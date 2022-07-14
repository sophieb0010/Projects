CREATE OR REPLACE PACKAGE pkg_prm_mta IS
    PROCEDURE loading (
        sa_table_name        VARCHAR := 'N/A',
        target_table_name    VARCHAR := 'N/A',
        package_name         VARCHAR := 'N/A',
        procedure_name       VARCHAR := 'N/A',
        previous_loaded_date TIMESTAMP := current_timestamp
    );

END;