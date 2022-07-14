-- log procedure
CREATE OR REPLACE PACKAGE BODY pkg_utl_logs IS

    PROCEDURE logg (
        log_mesage     VARCHAR := 'N/A',
        package_name   VARCHAR := 'N/A',
        procedure_name VARCHAR := 'N/A',
        rows_inserted  NUMBER := 0,
        rows_updated   NUMBER := 0,
        error_code     VARCHAR := 'N/A',
        error_message  VARCHAR := 'N/A'
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO log_table (
            log_id,
            log_date,
            log_time,
            log_mesage,
            user_name,
            package_name,
            procedure_name,
            rows_inserted,
            rows_updated,
            error_code,
            error_message
        ) VALUES (
            logg_seq.NEXTVAL,
            sysdate,
            to_char(current_timestamp, 'HH24:MI:SS'),
            log_mesage,
            user,
            package_name,
            procedure_name,
            rows_inserted,
            rows_updated,
            error_code,
            error_message
        );

        COMMIT;
    END;

END;