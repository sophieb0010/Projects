CREATE OR REPLACE PACKAGE pkg_utl_logs AUTHID definer IS
    PROCEDURE logg (
        log_mesage     VARCHAR := 'N/A',
        package_name   VARCHAR := 'N/A',
        procedure_name VARCHAR := 'N/A',
        rows_inserted  NUMBER := 0,
        rows_updated   NUMBER := 0,
        error_code     VARCHAR := 'N/A',
        error_message  VARCHAR := 'N/A'
    );

END;