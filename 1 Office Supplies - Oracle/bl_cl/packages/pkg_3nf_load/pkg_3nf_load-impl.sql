CREATE OR REPLACE PACKAGE BODY pkg_3nf_load IS

    error_code               VARCHAR(200) := 'N/A';
    error_message            VARCHAR(200) := 'N/A';
    package_name             VARCHAR(200) := 'PKG_3NF_LOAD';
    row_count_before         NUMBER;
    row_count_after          NUMBER;
    rows_affected            NUMBER;
    cor_previous_loaded_date TIMESTAMP;
    con_previous_loaded_date TIMESTAMP;

    PROCEDURE load_ce_markets IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_MARKETS';
        v_target_table_name VARCHAR(200) := 'CE_MARKETS';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_MARKETS table.', package_name, procedure_name);
        SELECT
            COUNT(market_id)
        INTO row_count_before
        FROM
            ce_markets;

        MERGE INTO ce_markets ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                  AS source_system,
                  'SRC_CORPORATE'                 AS source_entity,
                  nvl(upper(TRIM(market)), 'N/A') AS source_id,
                  nvl(upper(TRIM(market)), 'N/A') AS market
              FROM
                  sa_corporate.src_corporate c
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(upper(TRIM(market)), 'N/A'),
                  nvl(upper(TRIM(market)), 'N/A')
              FROM
                  sa_consumer.src_consumer cc
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN NOT MATCHED THEN
        INSERT (
            market_id,
            source_system,
            source_entity,
            source_id,
            market,
            insert_date,
            update_date )
        VALUES
            ( ce_markets_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.market,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(market_id)
        INTO row_count_after
        FROM
            ce_markets;

        pkg_utl_logs.logg('Finish loading of CE_MARKETS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(market_id)
            INTO row_count_after
            FROM
                ce_markets;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_countries IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_COUNTRIES';
        v_target_table_name VARCHAR(200) := 'CE_COUNTRIES';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_COUNTRIES table.', package_name, procedure_name);
        SELECT
            COUNT(country_id)
        INTO row_count_before
        FROM
            ce_countries;

        MERGE INTO ce_countries ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                       AS source_system,
                  'SRC_CORPORATE'                      AS source_entity,
                  nvl(initcap(TRIM(c.country)), 'N/A')
                  || ', '
                  || nvl(upper(TRIM(c.market)), 'N/A') AS source_id,
                  nvl(initcap(TRIM(c.country)), 'N/A') AS country,
                  ca.market_id
              FROM
                  sa_corporate.src_corporate c
                  LEFT JOIN ce_markets                 ca ON ca.source_system = 'SA_CORPORATE'
                                             AND ca.source_entity = 'SRC_CORPORATE'
                                             AND ca.source_id = nvl(upper(TRIM(c.market)), 'N/A')
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(initcap(TRIM(cc.country)), 'N/A')
                  || ', '
                  || nvl(upper(TRIM(cc.market)), 'N/A'),
                  nvl(initcap(TRIM(cc.country)), 'N/A'),
                  caa.market_id
              FROM
                  sa_consumer.src_consumer cc
                  LEFT JOIN ce_markets               caa ON 'SA_CONSUMER' = caa.source_system
                                              AND 'SRC_CONSUMER' = caa.source_entity
                                              AND caa.source_id = nvl(upper(TRIM(cc.market)), 'N/A')
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.market_id = src.market_id,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.market_id, src.market_id, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            country_id,
            source_system,
            source_entity,
            source_id,
            country,
            market_id,
            insert_date,
            update_date )
        VALUES
            ( ce_countries_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.country,
            src.market_id,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(country_id)
        INTO row_count_after
        FROM
            ce_countries;

        pkg_utl_logs.logg('Finish loading of CE_COUNTRIES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(country_id)
            INTO row_count_after
            FROM
                ce_countries;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_cities IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_CITIES';
        v_target_table_name VARCHAR(200) := 'CE_CITIES';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_CITIES table.', package_name, procedure_name);
        SELECT
            COUNT(city_id)
        INTO row_count_before
        FROM
            ce_cities;

        MERGE INTO ce_cities ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                       AS source_system,
                  'SRC_CORPORATE'                      AS source_entity,
                  nvl(initcap(TRIM(c.city)), 'N/A')
                  || ', '
                  || nvl(initcap(TRIM(c.country)), 'N/A')
                  || ', '
                  || nvl(upper(TRIM(c.market)), 'N/A') AS source_id,
                  nvl(initcap(TRIM(city)), 'N/A')      AS city,
                  country_id,
                  sysdate                              AS insert_date,
                  sysdate                              AS update_date
              FROM
                  sa_corporate.src_corporate c
                  LEFT JOIN ce_countries               ca ON ca.source_system = 'SA_CORPORATE'
                                               AND ca.source_entity = 'SRC_CORPORATE'
                                               AND ca.source_id = nvl(initcap(TRIM(c.country)), 'N/A')
                                                                  || ', '
                                                                  || nvl(upper(TRIM(c.market)), 'N/A')
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER'  AS source_system,
                  'SRC_CONSUMER' AS source_entity,
                  nvl(initcap(TRIM(cc.city)), 'N/A')
                  || ', '
                  || nvl(initcap(TRIM(cc.country)), 'N/A')
                  || ', '
                  || nvl(upper(TRIM(cc.market)), 'N/A'),
                  nvl(initcap(TRIM(city)), 'N/A'),
                  country_id,
                  sysdate        AS insert_date,
                  sysdate        AS update_date
              FROM
                  sa_consumer.src_consumer cc
                  LEFT JOIN ce_countries             caa ON caa.source_system = 'SA_CONSUMER'
                                                AND caa.source_entity = 'SRC_CONSUMER'
                                                AND caa.source_id = nvl(initcap(TRIM(cc.country)), 'N/A')
                                                                    || ', '
                                                                    || nvl(upper(TRIM(cc.market)), 'N/A')
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.country_id = src.country_id,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.country_id, src.country_id, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            city_id,
            source_system,
            source_entity,
            source_id,
            city,
            country_id,
            insert_date,
            update_date )
        VALUES
            ( ce_cities_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.city,
            src.country_id,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(city_id)
        INTO row_count_after
        FROM
            ce_cities;

        pkg_utl_logs.logg('Finish loading of CE_CITIES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(city_id)
            INTO row_count_after
            FROM
                ce_cities;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_product_categories IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_PRODUCT_CATEGORIES';
        v_target_table_name VARCHAR(200) := 'CE_PRODUCT_CATEGORIES';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_PRODUCT_CATEGORIES table.', package_name, procedure_name);
        SELECT
            COUNT(product_category_id)
        INTO row_count_before
        FROM
            ce_product_categories;

        MERGE INTO ce_product_categories ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                      AS source_system,
                  'SRC_CORPORATE'                     AS source_entity,
                  nvl(initcap(TRIM(category)), 'N/A') AS source_id,
                  nvl(initcap(TRIM(category)), 'N/A') AS product_category
              FROM
                  sa_corporate.src_corporate c
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(initcap(TRIM(category)), 'N/A'),
                  nvl(initcap(TRIM(category)), 'N/A')
              FROM
                  sa_consumer.src_consumer cc
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN NOT MATCHED THEN
        INSERT (
            product_category_id,
            source_system,
            source_entity,
            source_id,
            product_category,
            insert_date,
            update_date )
        VALUES
            ( ce_product_categories_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.product_category,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(product_category_id)
        INTO row_count_after
        FROM
            ce_product_categories;

        pkg_utl_logs.logg('Finish loading of CE_PRODUCT_CATEGORIES table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(product_category_id)
            INTO row_count_after
            FROM
                ce_product_categories;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_product_subcategories IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_PRODUCT_SUBCATEGORIES';
        v_target_table_name VARCHAR(200) := 'CE_PRODUCT_SUBCATEGORIES';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_PRODUCT_SUBCATEGORIES table.', package_name, procedure_name);
        SELECT
            COUNT(product_subcategory_id)
        INTO row_count_before
        FROM
            ce_product_subcategories;

        MERGE INTO ce_product_subcategories ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                           AS source_system,
                  'SRC_CORPORATE'                          AS source_entity,
                  nvl(initcap(TRIM(subcategory)), 'N/A')
                  || ', '
                  || nvl(initcap(TRIM(c.category)), 'N/A') AS source_id,
                  nvl(initcap(TRIM(subcategory)), 'N/A')   AS product_subcategory,
                  ca.product_category_id
              FROM
                  sa_corporate.src_corporate c
                  LEFT JOIN ce_product_categories      ca ON ca.source_system = 'SA_CORPORATE'
                                                        AND ca.source_entity = 'SRC_CORPORATE'
                                                        AND ca.source_id = nvl(initcap(TRIM(c.category)), 'N/A')
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(initcap(TRIM(subcategory)), 'N/A')
                  || ', '
                  || nvl(initcap(TRIM(cc.category)), 'N/A'),
                  nvl(initcap(TRIM(subcategory)), 'N/A'),
                  caa.product_category_id
              FROM
                  sa_consumer.src_consumer cc
                  LEFT JOIN ce_product_categories    caa ON 'SA_CONSUMER' = caa.source_system
                                                         AND 'SRC_CONSUMER' = caa.source_entity
                                                         AND caa.source_id = nvl(initcap(TRIM(cc.category)), 'N/A')
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.product_category_id = src.product_category_id,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.product_category_id, src.product_category_id, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            product_subcategory_id,
            source_system,
            source_entity,
            source_id,
            product_subcategory,
            product_category_id,
            insert_date,
            update_date )
        VALUES
            ( ce_product_subcategories_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.product_subcategory,
            src.product_category_id,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(product_subcategory_id)
        INTO row_count_after
        FROM
            ce_product_subcategories;

        pkg_utl_logs.logg('Finish loading of CE_PRODUCT_SUBCATEGORIES table.', package_name, procedure_name, row_count_after - row_count_before,
        rows_affected -(row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(product_subcategory_id)
            INTO row_count_after
            FROM
                ce_product_subcategories;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_products IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_PRODUCTS';
        v_target_table_name VARCHAR(200) := 'CE_PRODUCTS';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_PRODUCTS table.', package_name, procedure_name);
        SELECT
            COUNT(product_id)
        INTO row_count_before
        FROM
            ce_products;

        MERGE INTO ce_products ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                          AS source_system,
                  'SRC_CORPORATE'                         AS source_entity,
                  TRIM(product_id)                        AS source_id,
                  nvl(initcap(TRIM(product_name)), 'N/A') AS product_name,
                  nvl(initcap(TRIM(product_desc)), 'N/A') AS product_desc,
                  ca.product_subcategory_id               AS product_subcategory_id
              FROM
                  sa_corporate.src_corporate c
                  LEFT JOIN ce_product_subcategories   ca ON ca.source_system = 'SA_CORPORATE'
                                                           AND ca.source_entity = 'SRC_CORPORATE'
                                                           AND ca.source_id = nvl(initcap(TRIM(c.subcategory)), 'N/A')
                                                                              || ', '
                                                                              || nvl(initcap(TRIM(c.category)), 'N/A')
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER'    AS source_system,
                  'SRC_CONSUMER'   AS source_entity,
                  TRIM(product_id) AS source_id,
                  nvl(initcap(TRIM(product_name)), 'N/A'),
                  nvl(initcap(TRIM(product_desc)), 'N/A'),
                  caa.product_subcategory_id
              FROM
                  sa_consumer.src_consumer cc
                  LEFT JOIN ce_product_subcategories caa ON caa.source_system = 'SA_CONSUMER'
                                                            AND caa.source_entity = 'SRC_CONSUMER'
                                                            AND caa.source_id = nvl(initcap(TRIM(cc.subcategory)), 'N/A')
                                                                                || ', '
                                                                                || nvl(initcap(TRIM(cc.category)), 'N/A')
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.product_name = src.product_name,
            ce.product_desc = src.product_desc,
            ce.product_subcategory_id = src.product_subcategory_id,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.product_name, src.product_name, 0, 1) + decode(ce.product_desc, src.product_desc, 0, 1) + decode(ce.product_subcategory_id,
            src.product_subcategory_id, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            product_id,
            source_system,
            source_entity,
            source_id,
            product_name,
            product_desc,
            product_subcategory_id,
            insert_date,
            update_date )
        VALUES
            ( ce_product_subcategories_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.product_name,
            src.product_desc,
            src.product_subcategory_id,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(product_id)
        INTO row_count_after
        FROM
            ce_products;

        pkg_utl_logs.logg('Finish loading of CE_PRODUCTS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(product_id)
            INTO row_count_after
            FROM
                ce_products;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_customers IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_CUSTOMERS';
        v_target_table_name VARCHAR(200) := 'CE_CUSTOMERS';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_CUSTOMERS table.', package_name, procedure_name);
        SELECT
            COUNT(customer_id)
        INTO row_count_before
        FROM
            ce_customers;

        MERGE INTO ce_customers ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                                 AS source_system,
                  'SRC_CORPORATE'                                AS source_entity,
                  nvl(TRIM(customer_id), 'N/A')                  AS source_id,
                  nvl(initcap(TRIM(customer_first_name)), 'N/A') AS customer_first_name,
                  nvl(initcap(TRIM(customer_last_name)), 'N/A')  AS customer_last_name,
                  nvl(lower(TRIM(customer_email)), 'N/A')        AS customer_email,
                  nvl(upper(TRIM(customer_gender)), 'N/A')       AS customer_gender
              FROM
                  sa_corporate.src_corporate c
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(TRIM(customer_id), 'N/A'),
                  nvl(initcap(TRIM(customer_first_name)), 'N/A'),
                  nvl(initcap(TRIM(customer_last_name)), 'N/A'),
                  nvl(lower(TRIM(customer_email)), 'N/A'),
                  nvl(upper(TRIM(customer_gender)), 'N/A')
              FROM
                  sa_consumer.src_consumer cc
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.customer_first_name = src.customer_first_name,
            ce.customer_last_name = src.customer_last_name,
            ce.customer_email = src.customer_email,
            ce.customer_gender = src.customer_gender,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.customer_first_name, src.customer_first_name, 0, 1) + decode(ce.customer_last_name, src.customer_last_name, 0,
            1) + decode(ce.customer_email, src.customer_email, 0, 1) + decode(ce.customer_gender, src.customer_gender, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            customer_id,
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
            ( ce_customers_seq.NEXTVAL,
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
            COUNT(customer_id)
        INTO row_count_after
        FROM
            ce_customers;

        pkg_utl_logs.logg('Finish loading of CE_CUSTOMERS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(customer_id)
            INTO row_count_after
            FROM
                ce_customers;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_employees IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_EMPLOYEES';
        v_target_table_name VARCHAR(200) := 'CE_EMPLOYEES';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_EMPLOYEES table.', package_name, procedure_name);
        SELECT
            COUNT(employee_id)
        INTO row_count_before
        FROM
            ce_employees;

        MERGE INTO ce_employees ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                                 AS source_system,
                  'SRC_CORPORATE'                                AS source_entity,
                  nvl(TRIM(employee_id), 'N/A')                  AS source_id,
                  nvl(initcap(TRIM(employee_first_name)), 'N/A') AS employee_first_name,
                  nvl(initcap(TRIM(employee_last_name)), 'N/A')  AS employee_last_name,
                  nvl(lower(TRIM(employee_email)), 'N/A')        AS employee_email,
                  nvl(upper(TRIM(employee_gender)), 'N/A')       AS employee_gender,
                  nvl(TRIM(phone), 'N/A')                        AS phone,
                  nvl(initcap(TRIM(department)), 'N/A')          AS department,
                  nvl(initcap(TRIM(job_skill)), 'N/A')           AS job_skill
              FROM
                  sa_corporate.src_corporate c
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(TRIM(employee_id), 'N/A'),
                  nvl(initcap(TRIM(employee_first_name)), 'N/A') AS employee_first_name,
                  nvl(initcap(TRIM(employee_last_name)), 'N/A')  AS employee_last_name,
                  nvl(lower(TRIM(employee_email)), 'N/A')        AS employee_email,
                  nvl(upper(TRIM(employee_gender)), 'N/A')       AS employee_gender,
                  nvl(TRIM(phone), 'N/A')                        AS phone,
                  nvl(initcap(TRIM(department)), 'N/A')          AS department,
                  nvl(initcap(TRIM(job_skill)), 'N/A')           AS job_skill
              FROM
                  sa_consumer.src_consumer cc
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.employee_first_name = src.employee_first_name,
            ce.employee_last_name = src.employee_last_name,
            ce.employee_email = src.employee_email,
            ce.employee_gender = src.employee_gender,
            ce.phone = src.phone,
            ce.department = src.department,
            ce.job_skill = src.job_skill,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.employee_first_name, src.employee_first_name, 0, 1) + decode(ce.employee_last_name, src.employee_last_name, 0,
            1) + decode(ce.employee_email, src.employee_email, 0, 1) + decode(ce.employee_gender, src.employee_gender, 0, 1) + decode(
            ce.phone, src.phone, 0, 1) + decode(ce.department, src.department, 0, 1) + decode(ce.job_skill, src.job_skill, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            employee_id,
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
            ( ce_employees_seq.NEXTVAL,
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
            COUNT(employee_id)
        INTO row_count_after
        FROM
            ce_employees;

        pkg_utl_logs.logg('Finish loading of CE_EMPLOYEES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(employee_id)
            INTO row_count_after
            FROM
                ce_employees;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_payments IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_PAYMENTS';
        v_target_table_name VARCHAR(200) := 'CE_PAYMENTS';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_PAYMENTS table.', package_name, procedure_name);
        SELECT
            COUNT(payment_id)
        INTO row_count_before
        FROM
            ce_payments;

        MERGE INTO ce_payments ce
        USING ( SELECT DISTINCT
                  t.source_id     AS merge_key,
                  ceee.payment_id AS payment_id,
                  t.*
              FROM
                  (
                      SELECT DISTINCT
                          'SA_CORPORATE'                          AS source_system,
                          'SRC_CORPORATE'                         AS source_entity,
                          nvl((TRIM(payment_id)), 'N/A')          AS source_id,
                          nvl(initcap(TRIM(payment_type)), 'N/A') AS payment_type,
                          start_date                              AS start_date,
                          TO_DATE('01-01-9999', 'DD-MM-YYYY')     AS end_date,
                          'Y'                                     AS is_active
                      FROM
                          sa_corporate.src_corporate
                      UNION ALL
                      SELECT DISTINCT
                          'SA_CONSUMER'                           AS source_system,
                          'SRC_CONSUMER'                          AS source_entity,
                          nvl((TRIM(payment_id)), 'N/A')          AS source_id,
                          nvl(initcap(TRIM(payment_type)), 'N/A') AS payment_type,
                          start_date                              AS start_date,
                          TO_DATE('01-01-9999', 'DD-MM-YYYY')     AS end_date,
                          'Y'                                     AS is_active
                      FROM
                          sa_consumer.src_consumer
                  )           t
                  LEFT JOIN ce_payments ceee ON ceee.source_system = t.source_system
                                                AND ceee.source_entity = t.source_entity
                                                AND ceee.source_id = t.source_id
              WHERE
                  t.source_id NOT IN (
                      SELECT
                          source_id
                      FROM
                          ce_payments
                      WHERE
                          is_active = 'N'
                  )
              UNION ALL
              SELECT
                  NULL AS merge_key,
                  cee.payment_id,
                  tt.*
              FROM
                  (
                      SELECT DISTINCT
                          'SA_CORPORATE'                          AS source_system,
                          'SRC_CORPORATE'                         AS source_entity,
                          nvl((TRIM(payment_id)), 'N/A')          AS source_id,
                          nvl(initcap(TRIM(payment_type)), 'N/A') AS payment_type,
                          start_date                              AS start_date,
                          TO_DATE('01-01-9999', 'DD-MM-YYYY')     AS end_date,
                          'Y'                                     AS is_active
                      FROM
                          sa_corporate.src_corporate
                      UNION ALL
                      SELECT DISTINCT
                          'SA_CONSUMER'                           AS source_system,
                          'SRC_CONSUMER'                          AS source_entity,
                          nvl((TRIM(payment_id)), 'N/A')          AS source_id,
                          nvl(initcap(TRIM(payment_type)), 'N/A') AS payment_type,
                          start_date                              AS start_date,
                          TO_DATE('01-01-9999', 'DD-MM-YYYY')     AS end_date,
                          'Y'                                     AS is_active
                      FROM
                          sa_consumer.src_consumer
                  )           tt
                  LEFT JOIN ce_payments cee ON cee.source_system = tt.source_system
                                               AND cee.source_entity = tt.source_entity
                                               AND cee.source_id = tt.source_id
              WHERE
                      cee.is_active = 'Y'
                  AND tt.payment_type <> cee.payment_type
                  AND tt.source_id NOT IN (
                      SELECT
                          source_id
                      FROM
                          ce_payments
                      WHERE
                          is_active = 'N'
                  )
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.merge_key )
        WHEN MATCHED THEN UPDATE
        SET is_active = 'N',
            end_date = src.start_date
        WHERE
                ce.is_active = 'Y'
            AND src.payment_type <> ce.payment_type
        WHEN NOT MATCHED THEN
        INSERT (
            payment_id,
            source_system,
            source_entity,
            source_id,
            payment_type,
            start_date,
            end_date,
            is_active,
            insert_date )
        VALUES
            ( nvl(src.payment_id, ce_payments_seq.NEXTVAL),
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
            COUNT(payment_id)
        INTO row_count_after
        FROM
            ce_payments;

        pkg_utl_logs.logg('Finish loading of CE_PAYMENTS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(payment_id)
            INTO row_count_after
            FROM
                ce_payments;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_shippings IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_SHIPPINGS';
        v_target_table_name VARCHAR(200) := 'CE_SHIPPINGS';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_SHIPPINGS table.', package_name, procedure_name);
        SELECT
            COUNT(shipping_id)
        INTO row_count_before
        FROM
            ce_shippings;

        MERGE INTO ce_shippings ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                       AS source_system,
                  'SRC_CORPORATE'                      AS source_entity,
                  nvl(initcap(TRIM(ship_mode)), 'N/A') AS source_id,
                  nvl(initcap(TRIM(ship_mode)), 'N/A') AS shipping_mode
              FROM
                  sa_corporate.src_corporate c
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(initcap(TRIM(ship_mode)), 'N/A') AS source_id,
                  nvl(initcap(TRIM(ship_mode)), 'N/A') AS shipping_mode
              FROM
                  sa_consumer.src_consumer cc
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN NOT MATCHED THEN
        INSERT (
            shipping_id,
            source_system,
            source_entity,
            source_id,
            shipping_mode,
            insert_date,
            update_date )
        VALUES
            ( ce_shippings_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.shipping_mode,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(shipping_id)
        INTO row_count_after
        FROM
            ce_shippings;

        pkg_utl_logs.logg('Finish loading of CE_SHIPPINGS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(shipping_id)
            INTO row_count_after
            FROM
                ce_shippings;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_orders IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_ORDERS';
        v_target_table_name VARCHAR(200) := 'CE_ORDERS';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_ORDERS table.', package_name, procedure_name);
        SELECT
            COUNT(order_id)
        INTO row_count_before
        FROM
            ce_orders;

        SELECT
            MAX(previous_loaded_date)
        INTO cor_previous_loaded_date
        FROM
            prm_mta_incremental_load l
        WHERE
                l.target_table_name = v_target_table_name
            AND sa_table_name = 'SRC_CORPORATE';

        SELECT
            MAX(previous_loaded_date)
        INTO con_previous_loaded_date
        FROM
            prm_mta_incremental_load l
        WHERE
                l.target_table_name = v_target_table_name
            AND sa_table_name = 'SRC_CONSUMER';

        MERGE /* + append */ INTO ce_orders ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'               AS source_system,
                  'SRC_CORPORATE'              AS source_entity,
                  nvl(TRIM(order_id), 'N/A')   AS source_id,
                  nvl(TRIM(order_date), 'N/A') AS order_date,
                  nvl(TRIM(ship_date), 'N/A')  AS shipping_date,
                  e.employee_id,
                  s.shipping_id,
                  c.customer_id,
                  p.payment_id,
                  cc.city_id
              FROM
                  sa_corporate.src_corporate cor
                  LEFT JOIN ce_employees               e ON e.source_system = 'SA_CORPORATE'
                                              AND e.source_entity = 'SRC_CORPORATE'
                                              AND e.source_id = nvl(TRIM(cor.employee_id), 'N/A')
                  LEFT JOIN ce_shippings               s ON s.source_system = 'SA_CORPORATE'
                                              AND s.source_entity = 'SRC_CORPORATE'
                                              AND s.source_id = nvl(initcap(TRIM(cor.ship_mode)), 'N/A')
                  LEFT JOIN ce_customers               c ON c.source_system = 'SA_CORPORATE'
                                              AND c.source_entity = 'SRC_CORPORATE'
                                              AND c.source_id = nvl(TRIM(cor.customer_id), 'N/A')
                  LEFT JOIN ce_payments                p ON p.source_system = 'SA_CORPORATE'
                                             AND p.source_entity = 'SRC_CORPORATE'
                                             AND p.source_id = nvl(TRIM(cor.payment_id), 'N/A')
                                             AND p.start_date = cor.start_date
                  LEFT JOIN ce_cities                  cc ON cc.source_system = 'SA_CORPORATE'
                                            AND cc.source_entity = 'SRC_CORPORATE'
                                            AND cc.source_id = nvl(initcap(TRIM(cor.city)), 'N/A')
                                                               || ', '
                                                               || nvl(initcap(TRIM(cor.country)), 'N/A')
                                                               || ', '
                                                               || nvl(upper(TRIM(cor.market)), 'N/A')
              WHERE
                  cor.insert_date > cor_previous_loaded_date
                  OR cor.update_date > cor_previous_loaded_date
                  OR cor_previous_loaded_date IS NULL
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(TRIM(order_id), 'N/A')   AS source_id,
                  nvl(TRIM(order_date), 'N/A') AS order_date,
                  nvl(TRIM(ship_date), 'N/A')  AS shipping_date,
                  ee.employee_id,
                  ss.shipping_id,
                  ccc.customer_id,
                  pp.payment_id,
                  cccc.city_id
              FROM
                  sa_consumer.src_consumer con
                  LEFT JOIN ce_employees             ee ON ee.source_system = 'SA_CONSUMER'
                                               AND ee.source_entity = 'SRC_CONSUMER'
                                               AND ee.source_id = nvl(TRIM(con.employee_id), 'N/A')
                  LEFT JOIN ce_shippings             ss ON ss.source_system = 'SA_CONSUMER'
                                               AND ss.source_entity = 'SRC_CONSUMER'
                                               AND ss.source_id = nvl(initcap(TRIM(con.ship_mode)), 'N/A')
                  LEFT JOIN ce_customers             ccc ON ccc.source_system = 'SA_CONSUMER'
                                                AND ccc.source_entity = 'SRC_CONSUMER'
                                                AND ccc.source_id = nvl(TRIM(con.customer_id), 'N/A')
                  LEFT JOIN ce_payments              pp ON pp.source_system = 'SA_CONSUMER'
                                              AND pp.source_entity = 'SRC_CONSUMER'
                                              AND pp.source_id = nvl(TRIM(con.payment_id), 'N/A')
                                              AND pp.start_date = con.start_date
                  LEFT JOIN ce_cities                cccc ON cccc.source_system = 'SA_CONSUMER'
                                              AND cccc.source_entity = 'SRC_CONSUMER'
                                              AND cccc.source_id = nvl(initcap(TRIM(con.city)), 'N/A')
                                                                   || ', '
                                                                   || nvl(initcap(TRIM(con.country)), 'N/A')
                                                                   || ', '
                                                                   || nvl(upper(TRIM(con.market)), 'N/A')
              WHERE
                  con.insert_date > con_previous_loaded_date
                  OR con.update_date > con_previous_loaded_date
                  OR con_previous_loaded_date IS NULL
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.order_date = src.order_date,
            ce.shipping_date = src.shipping_date,
            ce.employee_id = src.employee_id,
            ce.shipping_id = src.shipping_id,
            ce.customer_id = src.customer_id,
            ce.payment_id = src.payment_id,
            ce.city_id = src.city_id,
            ce.update_date = sysdate
        WHERE
            ( decode(ce.order_date, src.order_date, 0, 1) + decode(ce.shipping_date, src.shipping_date, 0, 1) + decode(ce.employee_id,
            src.employee_id, 0, 1) + decode(ce.shipping_id, src.shipping_id, 0, 1) + decode(ce.customer_id, src.customer_id, 0, 1) + decode(
            ce.payment_id, src.payment_id, 0, 1) + decode(ce.city_id, src.city_id, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            order_id,
            source_system,
            source_entity,
            source_id,
            order_date,
            shipping_date,
            employee_id,
            shipping_id,
            customer_id,
            payment_id,
            city_id,
            insert_date,
            update_date )
        VALUES
            ( ce_orders_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.order_date,
            src.shipping_date,
            src.employee_id,
            src.shipping_id,
            src.customer_id,
            src.payment_id,
            src.city_id,
            sysdate,
            sysdate );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(order_id)
        INTO row_count_after
        FROM
            ce_orders;

        pkg_utl_logs.logg('Finish loading of CE_ORDERS table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(order_id)
            INTO row_count_after
            FROM
                ce_orders;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

    PROCEDURE load_ce_sales IS
        procedure_name      VARCHAR(200) := 'LOAD_CE_SALES';
        v_target_table_name VARCHAR(200) := 'CE_SALES';
    BEGIN
        pkg_utl_logs.logg('Start loading of CE_SALES table.', package_name, procedure_name);
        SELECT
            COUNT(sale_id)
        INTO row_count_before
        FROM
            ce_sales;

        SELECT
            MAX(previous_loaded_date)
        INTO cor_previous_loaded_date
        FROM
            prm_mta_incremental_load l
        WHERE
                l.target_table_name = v_target_table_name
            AND sa_table_name = 'SRC_CORPORATE';

        SELECT
            MAX(previous_loaded_date)
        INTO con_previous_loaded_date
        FROM
            prm_mta_incremental_load l
        WHERE
                l.target_table_name = v_target_table_name
            AND sa_table_name = 'SRC_CONSUMER';

        MERGE INTO ce_sales ce
        USING ( SELECT DISTINCT
                  'SA_CORPORATE'                   AS source_system,
                  'SRC_CORPORATE'                  AS source_entity,
                  nvl(TRIM(transaction_id), 'N/A') AS source_id,
                  nvl(TRIM(price), 'N/A')          AS price_dollars,
                  nvl(TRIM(cost), 'N/A')           AS costs_dollars,
                  nvl(TRIM(quantity), 'N/A')       AS sales_units,
                  nvl(TRIM(sales), 'N/A')          AS sales_dollars,
                  e.product_id,
                  s.order_id
              FROM
                  sa_corporate.src_corporate cor
                  LEFT JOIN ce_products                e ON e.source_system = 'SA_CORPORATE'
                                             AND e.source_entity = 'SRC_CORPORATE'
                                             AND e.source_id = nvl(TRIM(cor.product_id), 'N/A')
                  LEFT JOIN ce_orders                  s ON s.source_system = 'SA_CORPORATE'
                                           AND s.source_entity = 'SRC_CORPORATE'
                                           AND s.source_id = nvl(TRIM(cor.order_id), 'N/A')
              WHERE
                  cor.insert_date > cor_previous_loaded_date
                  OR cor.update_date > cor_previous_loaded_date
                  OR cor_previous_loaded_date IS NULL
              UNION ALL
              SELECT DISTINCT
                  'SA_CONSUMER',
                  'SRC_CONSUMER',
                  nvl(TRIM(transaction_id), 'N/A'),
                  nvl(TRIM(price), 'N/A'),
                  nvl(TRIM(cost), 'N/A'),
                  nvl(TRIM(quantity), 'N/A'),
                  nvl(TRIM(sales), 'N/A'),
                  ee.product_id,
                  ss.order_id
              FROM
                  sa_consumer.src_consumer con
                  LEFT JOIN ce_products              ee ON ee.source_system = 'SA_CONSUMER'
                                              AND ee.source_entity = 'SRC_CONSUMER'
                                              AND ee.source_id = nvl(TRIM(con.product_id), 'N/A')
                  LEFT JOIN ce_orders                ss ON ss.source_system = 'SA_CONSUMER'
                                            AND ss.source_entity = 'SRC_CONSUMER'
                                            AND ss.source_id = nvl(TRIM(con.order_id), 'N/A')
              WHERE
                  con.insert_date > con_previous_loaded_date
                  OR con.update_date > con_previous_loaded_date
                  OR con_previous_loaded_date IS NULL
              )
        src ON ( ce.source_system = src.source_system
                 AND ce.source_entity = src.source_entity
                 AND ce.source_id = src.source_id )
        WHEN MATCHED THEN UPDATE
        SET ce.price_dollars = src.price_dollars,
            ce.costs_dollars = src.costs_dollars,
            ce.sales_units = src.sales_units,
            ce.sales_dollars = src.sales_dollars,
            ce.product_id = src.product_id,
            ce.order_id = src.order_id,
            ce.update_date = current_timestamp
        WHERE
            ( decode(ce.price_dollars, src.price_dollars, 0, 1) + decode(ce.costs_dollars, src.costs_dollars, 0, 1) + decode(ce.sales_units,
            src.sales_units, 0, 1) + decode(ce.sales_dollars, src.sales_dollars, 0, 1) + decode(ce.product_id, src.product_id, 0, 1) +
            decode(ce.order_id, src.order_id, 0, 1) ) > 0
        WHEN NOT MATCHED THEN
        INSERT (
            sale_id,
            source_system,
            source_entity,
            source_id,
            price_dollars,
            costs_dollars,
            sales_units,
            sales_dollars,
            product_id,
            order_id,
            insert_date,
            update_date )
        VALUES
            ( ce_sales_seq.NEXTVAL,
            src.source_system,
            src.source_entity,
            src.source_id,
            src.price_dollars,
            src.costs_dollars,
            src.sales_units,
            src.sales_dollars,
            src.product_id,
            src.order_id,
            current_timestamp,
            current_timestamp );

        rows_affected := SQL%rowcount;
        SELECT
            COUNT(sale_id)
        INTO row_count_after
        FROM
            ce_sales;

        pkg_utl_logs.logg('Finish loading of CE_SALES table.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
        row_count_after - row_count_before));

        pkg_prm_mta.loading('SRC_CORPORATE', v_target_table_name, package_name, procedure_name);
        pkg_prm_mta.loading('SRC_CONSUMER', v_target_table_name, package_name, procedure_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            rows_affected := SQL%rowcount;
            SELECT
                COUNT(sale_id)
            INTO row_count_after
            FROM
                ce_sales;

            error_code := sqlcode;
            error_message := sqlerrm;
            pkg_utl_logs.logg('Error encountered.', package_name, procedure_name, row_count_after - row_count_before, rows_affected -(
            row_count_after - row_count_before),
                             error_code, error_message);

            ROLLBACK;
    END;

END;