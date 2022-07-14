CREATE OR REPLACE PACKAGE BODY pkg_src_load IS

    error_code       VARCHAR(200) := 'N/A';
    error_message    VARCHAR(200) := 'N/A';
    package_name     VARCHAR(200) := 'PKG_SRC_LOAD';
    row_count_before NUMBER;
    row_count_after  NUMBER;
    rows_affected    NUMBER := 0;

    PROCEDURE load_src_corporate IS

        procedure_name    VARCHAR(200) := 'LOAD_SRC_CORPORATE';
        sa_table_name     VARCHAR(200) := 'CORPORATE_ETX';
        target_table_name VARCHAR(200) := 'SRC_CORPORATE';
    BEGIN
        pkg_utl_logs.logg('Start loading of SRC_CORPORATE.', package_name, procedure_name);
        SELECT
            COUNT(transaction_id)
        INTO row_count_before
        FROM
            sa_corporate.src_corporate;

        MERGE /* + append */ INTO sa_corporate.src_corporate src
        USING sa_corporate.corporate_ext ext ON ( ext.transaction_id = src.transaction_id )
        WHEN MATCHED THEN UPDATE
        SET src.order_id = ext.order_id,
            src.order_date = ext.order_date,
            src.ship_date = ext.ship_date,
            src.ship_mode = ext.ship_mode,
            src.customer_id = ext.customer_id,
            src.customer_first_name = ext.customer_first_name,
            src.customer_last_name = ext.customer_last_name,
            src.customer_email = ext.customer_email,
            src.customer_gender = ext.customer_gender,
            src."SEGMENT" = ext."SEGMENT",
            src.city = ext.city,
            src.country = ext.country,
            src.market = ext.market,
            src.employee_first_name = ext.employee_first_name,
            src.employee_last_name = ext.employee_last_name,
            src.employee_email = ext.employee_email,
            src.employee_gender = ext.employee_gender,
            src.phone = ext.phone,
            src.department = ext.department,
            src.job_skill = ext.job_skill,
            src.employee_id = ext.employee_id,
            src.product_id = ext.product_id,
            src.category = ext.category,
            src.subcategory = ext.subcategory,
            src.product_name = ext.product_name,
            src.product_desc = ext.product_desc,
            src.sales = ext.sales,
            src.quantity = ext.quantity,
            src.cost = ext.cost,
            src.price = ext.price,
            src.payment_type = ext.payment_type,
            src.payment_id = ext.payment_id,
            src.start_date = ext.start_date,
            src.update_date = sysdate
        WHERE
            ( decode(src.order_id, ext.order_id, 0, 1) + decode(src.order_date, ext.order_date, 0, 1) + decode(src.ship_date, ext.ship_date,
            0, 1) + decode(src.ship_mode, ext.ship_mode, 0, 1) + decode(src.customer_id, ext.customer_id, 0, 1) + decode(src.customer_first_name,
            ext.customer_first_name, 0, 1) + decode(src.customer_last_name, ext.customer_last_name, 0, 1) + decode(src.customer_email,
            ext.customer_email, 0, 1) + decode(src.customer_gender, ext.customer_gender, 0, 1) + decode(src."SEGMENT", ext."SEGMENT",
            0, 1) + decode(src.city, ext.city, 0, 1) + decode(src.country, ext.country, 0, 1) + decode(src.market, ext.market, 0, 1) +
            decode(src.employee_first_name, ext.employee_first_name, 0, 1) + decode(src.employee_last_name, ext.employee_last_name, 0,
            1) + decode(src.employee_email, ext.employee_email, 0, 1) + decode(src.employee_gender, ext.employee_gender, 0, 1) + decode(
            src.phone, ext.phone, 0, 1) + decode(src.department, ext.department, 0, 1) + decode(src.job_skill, ext.job_skill, 0, 1) +
            decode(src.employee_id, ext.employee_id, 0, 1) + decode(src.product_id, ext.product_id, 0, 1) + decode(src.category, ext.
            category, 0, 1) + decode(src.subcategory, ext.subcategory, 0, 1) + decode(src.product_name, ext.product_name, 0, 1) + decode(
            src.product_desc, ext.product_desc, 0, 1) + decode(src.sales, ext.sales, 0, 1) + decode(src.quantity, ext.quantity, 0, 1) +
            decode(src.cost, ext.cost, 0, 1) + decode(src.price, ext.price, 0, 1) + decode(src.payment_type, ext.payment_type, 0, 1) +
            decode(src.payment_id, ext.payment_id, 0, 1) + decode(src.start_date, ext.start_date, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            transaction_id,
            order_id,
            order_date,
            ship_date,
            ship_mode,
            customer_id,
            customer_first_name,
            customer_last_name,
            customer_email,
            customer_gender,
            "SEGMENT",
            city,
            country,
            market,
            employee_first_name,
            employee_last_name,
            employee_email,
            employee_gender,
            phone,
            department,
            job_skill,
            employee_id,
            product_id,
            category,
            subcategory,
            product_name,
            product_desc,
            sales,
            quantity,
            cost,
            price,
            payment_type,
            payment_id,
            start_date,
            insert_date,
            update_date )
        VALUES
            ( ext.transaction_id,
              ext.order_id,
              ext.order_date,
              ext.ship_date,
              ext.ship_mode,
              ext.customer_id,
              ext.customer_first_name,
              ext.customer_last_name,
              ext.customer_email,
              ext.customer_gender,
              ext."SEGMENT",
              ext.city,
              ext.country,
              ext.market,
              ext.employee_first_name,
              ext.employee_last_name,
              ext.employee_email,
              ext.employee_gender,
              ext.phone,
              ext.department,
              ext.job_skill,
              ext.employee_id,
              ext.product_id,
              ext.category,
              ext.subcategory,
              ext.product_name,
              ext.product_desc,
              ext.sales,
              ext.quantity,
              ext.cost,
              ext.price,
              ext.payment_type,
              ext.payment_id,
              ext.start_date,
              current_timestamp,
              current_timestamp );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(transaction_id)
        INTO row_count_after
        FROM
            sa_corporate.src_corporate;

        pkg_utl_logs.logg('Finish loading of SRC_CORPORATE table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading(sa_table_name, target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(transaction_id)
            INTO row_count_after
            FROM
                sa_corporate.src_corporate;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_src_consumer IS

        procedure_name    VARCHAR(200) := 'LOAD_SRC_CONSUMER';
        sa_table_name     VARCHAR(200) := 'CONSUMER_EXT';
        target_table_name VARCHAR(200) := 'SRC_CONSUMER';
    BEGIN
        pkg_utl_logs.logg('Start loading of SRC_CONSUMER table.', package_name, procedure_name);
        SELECT
            COUNT(transaction_id)
        INTO row_count_before
        FROM
            sa_consumer.src_consumer;

        MERGE /* + append */ INTO sa_consumer.src_consumer src
        USING sa_consumer.consumer_ext ext ON ( ext.transaction_id = src.transaction_id )
        WHEN MATCHED THEN UPDATE
        SET src.order_id = ext.order_id,
            src.order_date = ext.order_date,
            src.ship_date = ext.ship_date,
            src.ship_mode = ext.ship_mode,
            src.customer_id = ext.customer_id,
            src.customer_first_name = ext.customer_first_name,
            src.customer_last_name = ext.customer_last_name,
            src.customer_email = ext.customer_email,
            src.customer_gender = ext.customer_gender,
            src."SEGMENT" = ext."SEGMENT",
            src.city = ext.city,
            src.country = ext.country,
            src.market = ext.market,
            src.employee_first_name = ext.employee_first_name,
            src.employee_last_name = ext.employee_last_name,
            src.employee_email = ext.employee_email,
            src.employee_gender = ext.employee_gender,
            src.phone = ext.phone,
            src.department = ext.department,
            src.job_skill = ext.job_skill,
            src.employee_id = ext.employee_id,
            src.product_id = ext.product_id,
            src.category = ext.category,
            src.subcategory = ext.subcategory,
            src.product_name = ext.product_name,
            src.product_desc = ext.product_desc,
            src.sales = ext.sales,
            src.quantity = ext.quantity,
            src.cost = ext.cost,
            src.price = ext.price,
            src.payment_type = ext.payment_type,
            src.payment_id = ext.payment_id,
            src.start_date = ext.start_date,
            src.update_date = sysdate
        WHERE
            ( decode(src.order_id, ext.order_id, 0, 1) + decode(src.order_date, ext.order_date, 0, 1) + decode(src.ship_date, ext.ship_date,
            0, 1) + decode(src.ship_mode, ext.ship_mode, 0, 1) + decode(src.customer_id, ext.customer_id, 0, 1) + decode(src.customer_first_name,
            ext.customer_first_name, 0, 1) + decode(src.customer_last_name, ext.customer_last_name, 0, 1) + decode(src.customer_email,
            ext.customer_email, 0, 1) + decode(src.customer_gender, ext.customer_gender, 0, 1) + decode(src."SEGMENT", ext."SEGMENT",
            0, 1) + decode(src.city, ext.city, 0, 1) + decode(src.country, ext.country, 0, 1) + decode(src.market, ext.market, 0, 1) +
            decode(src.employee_first_name, ext.employee_first_name, 0, 1) + decode(src.employee_last_name, ext.employee_last_name, 0,
            1) + decode(src.employee_email, ext.employee_email, 0, 1) + decode(src.employee_gender, ext.employee_gender, 0, 1) + decode(
            src.phone, ext.phone, 0, 1) + decode(src.department, ext.department, 0, 1) + decode(src.job_skill, ext.job_skill, 0, 1) +
            decode(src.employee_id, ext.employee_id, 0, 1) + decode(src.product_id, ext.product_id, 0, 1) + decode(src.category, ext.
            category, 0, 1) + decode(src.subcategory, ext.subcategory, 0, 1) + decode(src.product_name, ext.product_name, 0, 1) + decode(
            src.product_desc, ext.product_desc, 0, 1) + decode(src.sales, ext.sales, 0, 1) + decode(src.quantity, ext.quantity, 0, 1) +
            decode(src.cost, ext.cost, 0, 1) + decode(src.price, ext.price, 0, 1) + decode(src.payment_type, ext.payment_type, 0, 1) +
            decode(src.payment_id, ext.payment_id, 0, 1) + decode(src.start_date, ext.start_date, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            transaction_id,
            order_id,
            order_date,
            ship_date,
            ship_mode,
            customer_id,
            customer_first_name,
            customer_last_name,
            customer_email,
            customer_gender,
            "SEGMENT",
            city,
            country,
            market,
            employee_first_name,
            employee_last_name,
            employee_email,
            employee_gender,
            phone,
            department,
            job_skill,
            employee_id,
            product_id,
            category,
            subcategory,
            product_name,
            product_desc,
            sales,
            quantity,
            cost,
            price,
            payment_type,
            payment_id,
            start_date,
            insert_date,
            update_date )
        VALUES
            ( ext.transaction_id,
              ext.order_id,
              ext.order_date,
              ext.ship_date,
              ext.ship_mode,
              ext.customer_id,
              ext.customer_first_name,
              ext.customer_last_name,
              ext.customer_email,
              ext.customer_gender,
              ext."SEGMENT",
              ext.city,
              ext.country,
              ext.market,
              ext.employee_first_name,
              ext.employee_last_name,
              ext.employee_email,
              ext.employee_gender,
              ext.phone,
              ext.department,
              ext.job_skill,
              ext.employee_id,
              ext.product_id,
              ext.category,
              ext.subcategory,
              ext.product_name,
              ext.product_desc,
              ext.sales,
              ext.quantity,
              ext.cost,
              ext.price,
              ext.payment_type,
              ext.payment_id,
              ext.start_date,
              current_timestamp,
              current_timestamp );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(transaction_id)
        INTO row_count_after
        FROM
            sa_consumer.src_consumer;

        pkg_utl_logs.logg('Finish loading of SRC_CONSUMER table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading(sa_table_name, target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(transaction_id)
            INTO row_count_after
            FROM
                sa_consumer.src_consumer;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

END;