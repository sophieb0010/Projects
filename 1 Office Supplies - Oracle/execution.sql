CREATE OR REPLACE PROCEDURE execution_first IS
BEGIN
    pkg_src_load.load_src_corporate;
    pkg_src_load.load_src_consumer;
    pkg_3nf_load.load_ce_markets;
    pkg_3nf_load.load_ce_countries;
    pkg_3nf_load.load_ce_cities;
    pkg_3nf_load.load_ce_product_categories;
    pkg_3nf_load.load_ce_product_subcategories;
    pkg_3nf_load.load_ce_products;
    pkg_3nf_load.load_ce_customers;
    pkg_3nf_load.load_ce_employees;
    pkg_3nf_load.load_ce_payments;
    pkg_3nf_load.load_ce_shippings;
    pkg_3nf_load.load_ce_orders;
    pkg_3nf_load.load_ce_sales;
    pkg_dm_load.load_dim_cities;
    pkg_dm_load.load_dim_customers;
    pkg_dm_load.load_dim_dates;
    pkg_dm_load.load_dim_employees;
    pkg_dm_load.load_dim_payments;
    pkg_dm_load.load_dim_products;
    pkg_dm_load.load_dim_shippings;
    pkg_dm_load.load_fct_sales(TO_DATE('01/01/2011', 'DD/MM/YYYY'), TO_DATE('01/01/2015', 'DD/MM/YYYY'));

END;


CREATE OR REPLACE PROCEDURE execution_second IS
BEGIN
    pkg_src_load.load_src_corporate;
    pkg_src_load.load_src_consumer;
    pkg_3nf_load.load_ce_markets;
    pkg_3nf_load.load_ce_countries;
    pkg_3nf_load.load_ce_cities;
    pkg_3nf_load.load_ce_product_categories;
    pkg_3nf_load.load_ce_product_subcategories;
    pkg_3nf_load.load_ce_products;
    pkg_3nf_load.load_ce_customers;
    pkg_3nf_load.load_ce_employees;
    pkg_3nf_load.load_ce_payments;
    pkg_3nf_load.load_ce_shippings;
    pkg_3nf_load.load_ce_orders;
    pkg_3nf_load.load_ce_sales;
    pkg_dm_load.load_dim_cities;
    pkg_dm_load.load_dim_customers;
    pkg_dm_load.load_dim_dates;
    pkg_dm_load.load_dim_employees;
    pkg_dm_load.load_dim_payments;
    pkg_dm_load.load_dim_products;
    pkg_dm_load.load_dim_shippings;
    pkg_dm_load.load_fct_sales_reg;
END;

exec execution_first;
-- change sources 

exec execution_second;