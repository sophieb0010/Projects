CREATE OR REPLACE PACKAGE BODY pkg_dm_load IS

    error_code       VARCHAR(200) := 'N/A';
    error_message    VARCHAR(200) := 'N/A';
    package_name     VARCHAR(200) := 'PKG_DM_LOAD';
    row_count_before NUMBER;
    row_count_after  NUMBER;
    rows_affected    NUMBER := 0;

    PROCEDURE load_dim_cities IS
        procedure_name    VARCHAR(200) := 'LOAD_DIM_CITIES';
        target_table_name VARCHAR(200) := 'DIM_CITIES';
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_CITIES table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_cities;

        MERGE  INTO dim_cities dim
        USING (
                  SELECT   DISTINCT
                      'BL_3NF'    AS source_system,
                      'CE_CITIES' AS source_entity,
                      ce.city_id  AS source_id,
                      city,
                      country,
                      market
                  FROM
                      ce_cities ce
                      LEFT JOIN ce_countries USING ( country_id )
                      LEFT JOIN ce_markets USING ( market_id )
              )
        src ON ( dim.source_system = src.source_system
                 AND dim.source_entity = src.source_entity
                 AND dim.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET dim.city = src.city,
            dim.country = src.country,
            dim.market = src.market,
            dim.update_date = sysdate
        WHERE
            ( decode(dim.city, src.city, 0, 1) + decode(dim.country, src.country, 0, 1) + decode(dim.market, src.market, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            city_surr_id,
            source_system,
            source_entity,
            source_id,
            city,
            country,
            market,
            insert_date,
            update_date )
        VALUES
            ( dim_cities_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.city,
            src.country,
            src.market,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_cities;

        pkg_utl_logs.logg('Finish loading of DIM_CITIES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_CITIES', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_cities;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_dim_customers IS
        procedure_name    VARCHAR(200) := 'LOAD_DIM_CUSTOMERS';
        target_table_name VARCHAR(200) := 'DIM_COUNTRIES';
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_CUSTOMERS table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_customers;

        MERGE  INTO dim_customers dim
        USING (
                  SELECT   DISTINCT
                      'BL_3NF'       AS source_system,
                      'CE_CUSTOMERS' AS source_entity,
                      customer_id    AS source_id,
                      customer_first_name,
                      customer_last_name,
                      customer_email,
                      customer_gender
                  FROM
                      ce_customers
              )
        src ON ( dim.source_system = src.source_system
                 AND dim.source_entity = src.source_entity
                 AND dim.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET dim.customer_first_name = src.customer_first_name,
            dim.customer_last_name = src.customer_last_name,
            dim.customer_email = src.customer_email,
            dim.customer_gender = src.customer_gender,
            dim.update_date = sysdate
        WHERE
            ( decode(dim.customer_first_name, src.customer_first_name, 0, 1) + decode(dim.customer_last_name, src.customer_last_name,
            0, 1) + decode(dim.customer_email, src.customer_email, 0, 1) + decode(dim.customer_gender, src.customer_gender, 0, 1) ) >
            0
        WHEN NOT MATCHED THEN
        INSERT (
            customer_surr_id,
            source_system,
            source_entity,
            source_id,
            customer_first_name,
            customer_last_name,
            customer_email,
            customer_gender,
            insert_date,
            update_date )
        VALUES
            ( dim_customers_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.customer_first_name,
            src.customer_last_name,
            src.customer_email,
            src.customer_gender,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_customers;

        pkg_utl_logs.logg('Finish loading of DIM_CUSTOMERS table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_CUSTOMERS', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_customers;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_dim_dates IS
        procedure_name    VARCHAR(200) := 'LOAD_DIM_DATES';
        target_table_name VARCHAR(200) := 'DIM_DATES';
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_DATES table.', package_name, procedure_name);
        EXECUTE IMMEDIATE 'truncate table bl_dm.dim_dates';
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_dates;

        INSERT INTO dim_dates
            SELECT  
                to_date(to_char(currdate, 'DD/MM/YYYY'), 'DD/MM/YYYY')     AS date_id,
                to_number(TRIM(LEADING '0' FROM to_char(currdate, 'D')))   AS day_num_of_week,
                to_char(currdate, 'Day')                                   AS day_name,
                to_number(TRIM(LEADING '0' FROM to_char(currdate, 'DD')))  AS day_num_of_month,
                to_number(TRIM(LEADING '0' FROM to_char(currdate, 'DDD'))) AS day_num_of_year,
                to_number(TRIM(LEADING '0' FROM to_char(currdate, 'WW')))  AS week_num_of_year,
                to_number(TRIM(LEADING '0' FROM to_char(currdate, 'MM')))  AS month_num_of_year,
                to_char(currdate, 'Month')                                 AS month_name,
                to_number(to_char(currdate, 'Q'))                          AS quarter_num,
                to_number(to_char(currdate, 'YYYY'))                       AS year_num,
                to_date(to_char(current_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') AS insert_date,
                to_date(to_char(current_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') AS update_date
            FROM
                (
                    SELECT  
                        level                                                               AS n,
                        TO_DATE('31/12/1969', 'DD/MM/YYYY') + numtodsinterval(level, 'day') AS currdate
                    FROM
                        dual
                    CONNECT BY
                        level <= 21915
                )
            ORDER BY
                currdate;

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_dates;

        pkg_utl_logs.logg('Finish loading of DIM_DATES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('DIM_DATES', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_dates;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_dim_employees IS
        procedure_name    VARCHAR(200) := 'LOAD_DIM_EMPLOYEES';
        target_table_name VARCHAR(200) := 'DIM_EMPLOYEES';
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_EMPLOYEES table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_employees;

        MERGE  INTO dim_employees dim
        USING (
                  SELECT   DISTINCT
                      'BL_3NF'       AS source_system,
                      'CE_EMPLOYEES' AS source_entity,
                      employee_id    AS source_id,
                      employee_first_name,
                      employee_last_name,
                      employee_email,
                      employee_gender,
                      phone,
                      department,
                      job_skill
                  FROM
                      ce_employees
              )
        src ON ( dim.source_system = src.source_system
                 AND dim.source_entity = src.source_entity
                 AND dim.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET dim.employee_first_name = src.employee_first_name,
            dim.employee_last_name = src.employee_last_name,
            dim.employee_email = src.employee_email,
            dim.employee_gender = src.employee_gender,
            dim.phone = src.phone,
            dim.department = src.department,
            dim.job_skill = src.job_skill,
            dim.update_date = sysdate
        WHERE
            ( decode(dim.employee_first_name, src.employee_first_name, 0, 1) + decode(dim.employee_last_name, src.employee_last_name,
            0, 1) + decode(dim.employee_email, src.employee_email, 0, 1) + decode(dim.employee_gender, src.employee_gender, 0, 1) + decode(
            dim.phone, src.phone, 0, 1) + decode(dim.department, src.department, 0, 1) + decode(dim.job_skill, src.job_skill, 0, 1) ) >
            0
        WHEN NOT MATCHED THEN
        INSERT (
            employee_surr_id,
            source_system,
            source_entity,
            source_id,
            employee_first_name,
            employee_last_name,
            employee_email,
            employee_gender,
            phone,
            department,
            job_skill,
            insert_date,
            update_date )
        VALUES
            ( dim_employees_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.employee_first_name,
            src.employee_last_name,
            src.employee_email,
            src.employee_gender,
            src.phone,
            src.department,
            src.job_skill,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_employees;

        pkg_utl_logs.logg('Finish loading of DIM_EMPLOYEES table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_EMPLOYEES', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_employees;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_dim_payments IS
        procedure_name    VARCHAR(200) := 'LOAD_DIM_PAYMENTS_SCD';
        target_table_name VARCHAR(200) := 'DIM_PAYMENTS_SCD';
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_PAYMENTS_SCD table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_payments_scd;

        MERGE  INTO dim_payments_scd dim
        USING (
                  SELECT   DISTINCT
                      'BL_3NF'      AS source_system,
                      'CE_PAYMENTS' AS source_entity,
                      payment_id    AS source_id,
                      payment_type,
                      start_date,
                      end_date,
                      is_active
                  FROM
                      ce_payments
              )
        src ON ( dim.source_system = src.source_system
                 AND dim.source_entity = src.source_entity
                 AND dim.source_id = src.source_id
                 AND dim.start_date = src.start_date )
        WHEN MATCHED THEN UPDATE
        SET dim.payment_type = src.payment_type,
            dim.end_date = src.end_date,
            dim.is_active = src.is_active
        WHERE
            ( decode(dim.payment_type, src.payment_type, 0, 1) + decode(dim.end_date, src.end_date, 0, 1) + decode(dim.is_active, src.
            is_active, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            payment_surr_id,
            source_system,
            source_entity,
            source_id,
            payment_type,
            start_date,
            end_date,
            is_active,
            insert_date )
        VALUES
            ( dim_payments_scd_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.payment_type,
            src.start_date,
            src.end_date,
            src.is_active,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_payments_scd;

        pkg_utl_logs.logg('Finish loading of DIM_PAYMENTS_SCD table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_PAYMENTS', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_payments_scd;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_dim_products IS

        procedure_name    VARCHAR(200) := 'LOAD_DIM_PRODUCTS';
        target_table_name VARCHAR(200) := 'DIM_PRODUCTS';
        rows_count        NUMBER;
        TYPE cur_type IS REF CURSOR;
        cur               cur_type;
        TYPE c IS
            TABLE OF dim_products%rowtype;
        cc                c;
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_PRODUCTS table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_products;

        rows_affected := 0;
        OPEN cur FOR SELECT   DISTINCT
                         NULL          AS product_surr_id,
                         'BL_3NF'      source_system,
                         'CE_PRODUCTS' AS source_entity,
                         product_id    AS source_id,
                         product_name,
                         product_desc,
                         product_subcategory,
                         product_category,
                         NULL          AS insert_date,
                         NULL          AS update_date
                     FROM
                         ce_products ce
                         LEFT JOIN ce_product_subcategories USING ( product_subcategory_id )
                         LEFT JOIN ce_product_categories USING ( product_category_id );

        LOOP
            EXIT WHEN cur%notfound;
            FETCH cur
            BULK COLLECT INTO cc LIMIT 1000;
            FORALL idx IN cc.first..cc.last
                MERGE  INTO dim_products dim
                USING (
                          SELECT  
                              cc(idx).source_system AS source_system,
                              cc(idx).source_entity AS source_entity,
                              cc(idx).source_id     AS source_id,
                              cc(idx).product_name,
                              cc(idx).product_desc,
                              cc(idx).product_subcategory,
                              cc(idx).product_category
                          FROM
                              dual
                      )
                src ON ( dim.source_system = src.source_system
                         AND dim.source_entity = src.source_entity
                         AND dim.source_id = src.source_id )
                WHEN MATCHED THEN UPDATE
                SET dim.product_name = cc(idx).product_name,
                    dim.product_desc = cc(idx).product_desc,
                    dim.product_subcategory = cc(idx).product_subcategory,
                    dim.product_category = cc(idx).product_category,
                    update_date = sysdate
                WHERE
                    ( decode(dim.product_name, cc(idx).product_name, 0, 1) + decode(dim.product_desc, cc(idx).product_desc, 0, 1) + decode(
                    dim.product_subcategory, cc(idx).product_subcategory, 0, 1) + decode(dim.product_category, cc(idx).product_category,
                    0, 1) ) > 0
                WHEN NOT MATCHED THEN
                INSERT (
                    product_surr_id,
                    source_system,
                    source_entity,
                    source_id,
                    product_name,
                    product_desc,
                    product_subcategory,
                    product_category,
                    insert_date,
                    update_date )
                VALUES
                    ( dim_products_seq.NEXTVAL,
                    cc(idx).source_system,
                    cc(idx).source_entity,
                    cc(idx).source_id,
                    cc(idx).product_name,
                    cc(idx).product_desc,
                    cc(idx).product_subcategory,
                    cc(idx).product_category,
                    sysdate,
                    sysdate );

            rows_count := SQL%rowcount;
            rows_affected := rows_affected + rows_count;
        END LOOP;

        CLOSE cur;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_products;

        pkg_utl_logs.logg('Finish loading of DIM_PRODUCTS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_PRODUCTS', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_products;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_dim_shippings IS
        procedure_name    VARCHAR(200) := 'LOAD_DIM_SHIPPINGS';
        target_table_name VARCHAR(200) := 'DIM_SHIPPINGS';
    BEGIN
        pkg_utl_logs.logg('Start loading of DIM_SHIPPINGS table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            dim_shippings;

        MERGE  INTO dim_shippings dim
        USING (
                  SELECT   DISTINCT
                      'BL_3NF'       AS source_system,
                      'CE_SHIPPINGS' AS source_entity,
                      shipping_id    AS source_id,
                      shipping_mode
                  FROM
                      ce_shippings
              )
        src ON ( dim.source_system = src.source_system
                 AND dim.source_entity = src.source_entity
                 AND dim.source_id = src.source_id )
        WHEN NOT MATCHED THEN
        INSERT (
            shipping_surr_id,
            source_system,
            source_entity,
            source_id,
            shipping_mode,
            insert_date,
            update_date )
        VALUES
            ( dim_shippings_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.shipping_mode,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            dim_shippings;

        pkg_utl_logs.logg('Finish loading of DIM_SHIPPINGS table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_SHIPPINGS', target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                dim_shippings;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_fct_sales (
        in_start_date DATE,
        in_end_date   DATE
    ) IS

        procedure_name         VARCHAR(200) := 'LOAD_FCT_SALES';
        partition_name         VARCHAR(20);
        start_date             DATE;
        end_date               DATE;
        neww                   DATE;
        v_target_table_name    VARCHAR(200) := 'FCT_SALES';
        v_previous_loaded_date TIMESTAMP;
        rows_count             NUMBER;
    BEGIN
        pkg_utl_logs.logg('Start loading of FCT_SALES table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            fct_sales;

        SELECT  
            MAX(previous_loaded_date)
        INTO v_previous_loaded_date
        FROM
            prm_mta_incremental_load l
        WHERE
                l.target_table_name = v_target_table_name
            AND sa_table_name = 'CE_SALES';

        rows_affected := 0;
        start_date := in_start_date;
        end_date := in_end_date;
        neww := start_date;
        WHILE neww < end_date LOOP
            partition_name := 'P'
                              || to_char(neww, 'YYYY')
                              || to_char(neww, 'MM');

            INSERT INTO /* +append */ tbl_exchange ce (
                order_date_id,
                shipping_date_id,
                city_surr_id,
                shipping_surr_id,
                payment_surr_id,
                employee_surr_id,
                product_surr_id,
                customer_surr_id,
                order_id,
                fct_price_dollars,
                fct_costs_dollars,
                fct_sales_units,
                fct_sales_dollars,
                insert_date,
                update_date
            )
                SELECT   DISTINCT
                    d.date_id     AS order_date_id,
                    dd.date_id    AS shipping_date_id,
                    city_surr_id,
                    shipping_surr_id,
                    payment_surr_id,
                    employee_surr_id,
                    product_surr_id,
                    customer_surr_id,
                    o.order_id,
                    price_dollars AS fct_price_dollars,
                    costs_dollars AS fct_costs_dollars,
                    sales_units   AS fct_sales_units,
                    sales_dollars AS fct_sales_dollars,
                    sysdate       AS insert_date,
                    sysdate       AS update_date
                FROM
                    ce_sales         sa
                    LEFT JOIN ce_orders        o ON o.order_id = sa.order_id
                    LEFT JOIN dim_dates        d ON d.date_id = o.order_date
                    LEFT JOIN dim_dates        dd ON dd.date_id = o.shipping_date
                    LEFT JOIN dim_cities       c ON c.source_id = o.city_id
                    LEFT JOIN dim_shippings    s ON s.source_id = o.shipping_id
                    LEFT JOIN dim_payments_scd p ON p.source_id = o.payment_id
                                                    AND o.order_date >= p.start_date
                                                    AND o.order_date < p.end_date
                    LEFT JOIN dim_employees    e ON e.source_id = o.employee_id
                    LEFT JOIN dim_products     pp ON pp.source_id = sa.product_id
                    LEFT JOIN dim_customers    cc ON cc.source_id = o.customer_id
                WHERE
                        o.order_date >= neww
                    AND o.order_date < add_months(neww, 1)
                    AND ( sa.insert_date > v_previous_loaded_date
                          OR sa.update_date > v_previous_loaded_date
                          OR v_previous_loaded_date IS NULL );

            neww := add_months(neww, 1);
            rows_count := SQL%rowcount;
            rows_affected := rows_affected + rows_count;
            EXECUTE IMMEDIATE 'alter table bl_dm.fct_sales exchange partition '
                              || partition_name
                              || ' with table bl_cl.tbl_exchange';
        END LOOP;

        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            fct_sales;

        pkg_utl_logs.logg('Finish loading of FCT_SALES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_SALES', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                fct_sales;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_fct_sales_reg IS

        procedure_name         VARCHAR(200) := 'LOAD_FCT_SALES_REG';
        v_target_table_name    VARCHAR(200) := 'FCT_SALES';
        v_previous_loaded_date TIMESTAMP;
    BEGIN
        pkg_utl_logs.logg('Start loading of FCT_SALES table.', package_name, procedure_name);
        SELECT  
            COUNT(*)
        INTO row_count_before
        FROM
            fct_sales;

        SELECT  
            MAX(previous_loaded_date)
        INTO v_previous_loaded_date
        FROM
            prm_mta_incremental_load l
        WHERE
                l.target_table_name = v_target_table_name
            AND sa_table_name = 'CE_SALES';

        INSERT INTO fct_sales ce (
            order_date_id,
            shipping_date_id,
            city_surr_id,
            shipping_surr_id,
            payment_surr_id,
            employee_surr_id,
            product_surr_id,
            customer_surr_id,
            order_id,
            fct_price_dollars,
            fct_costs_dollars,
            fct_sales_units,
            fct_sales_dollars,
            insert_date,
            update_date
        )
            SELECT   DISTINCT
                d.date_id     AS order_date_id,
                dd.date_id    AS shipping_date_id,
                city_surr_id,
                shipping_surr_id,
                payment_surr_id,
                employee_surr_id,
                product_surr_id,
                customer_surr_id,
                o.order_id,
                price_dollars AS fct_price_dollars,
                costs_dollars AS fct_costs_dollars,
                sales_units   AS fct_sales_units,
                sales_dollars AS fct_sales_dollars,
                sysdate       AS insert_date,
                sysdate       AS update_date
            FROM
                ce_sales         sa
                LEFT JOIN ce_orders        o ON o.order_id = sa.order_id
                LEFT JOIN dim_dates        d ON d.date_id = o.order_date
                LEFT JOIN dim_dates        dd ON dd.date_id = o.shipping_date
                LEFT JOIN dim_cities       c ON c.source_id = o.city_id
                LEFT JOIN dim_shippings    s ON s.source_id = o.shipping_id
                LEFT JOIN dim_payments_scd p ON p.source_id = o.payment_id
                                                AND o.order_date >= p.start_date
                                                AND o.order_date < p.end_date
                LEFT JOIN dim_employees    e ON e.source_id = o.employee_id
                LEFT JOIN dim_products     pp ON pp.source_id = sa.product_id
                LEFT JOIN dim_customers    cc ON cc.source_id = o.customer_id
            WHERE
                sa.insert_date > v_previous_loaded_date
                OR sa.update_date > v_previous_loaded_date
                OR v_previous_loaded_date IS NULL;

        rows_affected := SQL%rowcount;
        SELECT  
            COUNT(*)
        INTO row_count_after
        FROM
            fct_sales;

        pkg_utl_logs.logg('Finish loading of FCT_SALES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('CE_SALES', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT  
                COUNT(*)
            INTO row_count_after
            FROM
                fct_sales;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

END;