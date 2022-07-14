CREATE OR REPLACE PACKAGE pkg_3nf_load AUTHID definer IS
    PROCEDURE load_ce_markets;

    PROCEDURE load_ce_countries;

    PROCEDURE load_ce_cities;

    PROCEDURE load_ce_product_categories;

    PROCEDURE load_ce_product_subcategories;

    PROCEDURE load_ce_products;

    PROCEDURE load_ce_customers;

    PROCEDURE load_ce_employees;

    PROCEDURE load_ce_payments;

    PROCEDURE load_ce_shippings;

    PROCEDURE load_ce_orders;

    PROCEDURE load_ce_sales;

END;