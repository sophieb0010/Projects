CREATE UNIQUE INDEX cor_idx ON
    src_corporate (
        transaction_id
    );

CREATE UNIQUE INDEX con_idx ON
    src_consumer (
        transaction_id
    );

CREATE BITMAP INDEX cor_mar_idx ON
    src_corporate (
        market
    );

CREATE BITMAP INDEX con_mar_idx ON
    src_consumer (
        market
    );

CREATE BITMAP INDEX cor_co_idx ON
    src_corporate (
        country,
        market
    );

CREATE BITMAP INDEX con_co_idx ON
    src_consumer (
        country,
        market
    );

CREATE BITMAP INDEX cor_ci_idx ON
    src_corporate (
        city,
        country,
        market
    );

CREATE BITMAP INDEX con_ci_idx ON
    src_consumer (
        city,
        country,
        market
    );

CREATE BITMAP INDEX cor_ca_idx ON
    src_corporate (
        category
    );

CREATE BITMAP INDEX con_ca_idx ON
    src_consumer (
        category
    );

CREATE BITMAP INDEX cor_sub_idx ON
    src_corporate (
        subcategory,
        category
    );

CREATE BITMAP INDEX con_sub_idx ON
    src_consumer (
        subcategory,
        category
    );

CREATE BITMAP INDEX cor_pr_idx ON
    src_corporate (
        product_id,
        product_name,
        product_desc
    );

CREATE BITMAP INDEX con_pr_idx ON
    src_consumer (
        product_id,
        product_name,
        product_desc
    );

CREATE BITMAP INDEX cor_cus_idx ON
    src_corporate (
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_email,
        customer_gender
    );

CREATE BITMAP INDEX con_cus_idx ON
    src_consumer (
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_email,
        customer_gender
    );

CREATE BITMAP INDEX cor_emp_idx ON
    src_corporate (
        employee_id,
        employee_first_name,
        employee_last_name,
        employee_email,
        employee_gender,
        phone,
        department,
        job_skill
    );

CREATE BITMAP INDEX con_emp_idx ON
    src_consumer (
        employee_id,
        employee_first_name,
        employee_last_name,
        employee_email,
        employee_gender,
        phone,
        department,
        job_skill
    );

CREATE BITMAP INDEX cor_pay_idx ON
    src_corporate (
        payment_id,
        payment_type,
        start_date
    );

CREATE BITMAP INDEX con_pay_idx ON
    src_consumer (
        payment_id,
        payment_type,
        start_date
    );

CREATE BITMAP INDEX cor_sh_idx ON
    src_corporate (
        ship_mode
    );

CREATE BITMAP INDEX con_sh_idx ON
    src_consumer (
        ship_mode
    );

exec dbms_stats.gather_table_stats( user, 'SRC_CONSUMER', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CONSUMER_EXT', cascade=>true );

exec dbms_stats.gather_table_stats( user, 'SRC_CORPORATE', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CORPORATE_EXT', cascade=>true );

exec dbms_stats.gather_table_stats( user, 'CE_MARKETS', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_COUNTRIES', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_CITIES', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_PRODUCT_CATEGORIES', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_PRODUCT_SUBCATEGORIES', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_PRODUCTS', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_CUSTOMERS', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_EMPLOYEES', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_PAYMENTS', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_ORDERS', cascade=>true );
exec dbms_stats.gather_table_stats( user, 'CE_SALES', cascade=>true );