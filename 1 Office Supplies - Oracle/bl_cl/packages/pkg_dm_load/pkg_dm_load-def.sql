CREATE OR REPLACE PACKAGE pkg_dm_load AUTHID definer IS
    PROCEDURE load_dim_cities;

    PROCEDURE load_dim_customers;

    PROCEDURE load_dim_dates;

    PROCEDURE load_dim_employees;

    PROCEDURE load_dim_payments;

    PROCEDURE load_dim_products;

    PROCEDURE load_dim_shippings;

    PROCEDURE load_fct_sales (
        in_start_date DATE,
        in_end_date   DATE
    );

    PROCEDURE load_fct_sales_reg;

END;