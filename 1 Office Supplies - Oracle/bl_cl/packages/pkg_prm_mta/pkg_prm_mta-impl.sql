CREATE OR REPLACE PACKAGE BODY pkg_prm_mta IS

    PROCEDURE loading (
        sa_table_name        VARCHAR := 'N/A',
        target_table_name    VARCHAR := 'N/A',
        package_name         VARCHAR := 'N/A',
        procedure_name       VARCHAR := 'N/A',
        previous_loaded_date TIMESTAMP := current_timestamp
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO prm_mta_incremental_load (
            sa_table_name,
            target_table_name,
            package_name,
            procedure_name,
            previous_loaded_date
        ) VALUES (
            sa_table_name,
            target_table_name,
            package_name,
            procedure_name,
            current_timestamp
        );

        COMMIT;
    END;

END;