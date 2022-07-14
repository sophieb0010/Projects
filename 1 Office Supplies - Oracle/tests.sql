SELECT
    source_id
FROM
    ce_cities
GROUP BY
    source_system,
    source_entity,
    source_id,
    city,
    country_id
HAVING
    COUNT(city_id) > 1;

SELECT
    source_id
FROM
    ce_countries
GROUP BY
    source_system,
    source_entity,
    source_id,
    country,
    market_id
HAVING
    COUNT(country_id) > 1;

SELECT
    source_id
FROM
    ce_markets
GROUP BY
    source_system,
    source_entity,
    source_id,
    market
HAVING
    COUNT(market_id) > 1;

SELECT
    source_id
FROM
    ce_customers
GROUP BY
    source_system,
    source_entity,
    source_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_gender
HAVING
    COUNT(customer_id) > 1;

SELECT
    source_id
FROM
    ce_employees
GROUP BY
    source_system,
    source_entity,
    source_id,
    employee_first_name,
    employee_last_name,
    employee_email,
    employee_gender,
    phone,
    department,
    job_skill
HAVING
    COUNT(employee_id) > 1;

SELECT
    source_id
FROM
    ce_payments
GROUP BY
    source_system,
    source_entity,
    source_id,
    payment_type,
    start_date,
    end_date,
    is_active
HAVING
    COUNT(payment_id) > 1;

SELECT
    source_id
FROM
    ce_products
GROUP BY
    source_system,
    source_entity,
    source_id,
    product_name,
    product_desc,
    product_subcategory_id
HAVING
    COUNT(product_id) > 1;

SELECT
    source_id
FROM
    ce_product_subcategories
GROUP BY
    source_system,
    source_entity,
    source_id,
    product_subcategory,
    product_category_id
HAVING
    COUNT(product_subcategory_id) > 1;

SELECT
    source_id
FROM
    ce_product_categories
GROUP BY
    source_system,
    source_entity,
    source_id,
    product_category
HAVING
    COUNT(product_category_id) > 1;

SELECT
    source_id
FROM
    ce_shippings
GROUP BY
    source_system,
    source_entity,
    source_id,
    shipping_mode
HAVING
    COUNT(shipping_id) > 1;

SELECT
    source_id
FROM
    ce_orders
GROUP BY
    source_system,
    source_entity,
    source_id,
    order_date,
    shipping_date,
    employee_id,
    shipping_id,
    customer_id,
    payment_id,
    city_id
HAVING
    COUNT(order_id) > 1;

SELECT
    source_id
FROM
    ce_sales
GROUP BY
    source_system,
    source_entity,
    source_id,
    price_dollars,
    costs_dollars,
    sales_units,
    sales_dollars,
    product_id,
    order_id
HAVING
    COUNT(sale_id) > 1;

SELECT
    source_id
FROM
    dim_cities
GROUP BY
    source_system,
    source_entity,
    source_id,
    city,
    country,
    market
HAVING
    COUNT(city_surr_id) > 1;

SELECT
    source_id
FROM
    dim_customers
GROUP BY
    source_system,
    source_entity,
    source_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_gender
HAVING
    COUNT(customer_surr_id) > 1;

SELECT
    source_id
FROM
    dim_employees
GROUP BY
    source_system,
    source_entity,
    source_id,
    employee_first_name,
    employee_last_name,
    employee_email,
    employee_gender,
    phone,
    department,
    job_skill
HAVING
    COUNT(employee_surr_id) > 1;

SELECT
    source_id
FROM
    dim_payments_scd
GROUP BY
    source_system,
    source_entity,
    source_id,
    payment_type,
    start_date,
    end_date,
    is_active
HAVING
    COUNT(payment_surr_id) > 1;

SELECT
    source_id
FROM
    dim_products
GROUP BY
    source_system,
    source_entity,
    source_id,
    product_name,
    product_desc,
    product_subcategory,
    product_category
HAVING
    COUNT(product_surr_id) > 1;

SELECT
    order_date_id
FROM
    fct_sales
GROUP BY
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
    fct_sales_dollars
HAVING
    COUNT(insert_date) > 1;

SELECT
    COUNT(transaction_id)
FROM
    sa_consumer.src_consumer
WHERE
    'SRC_CONSUMER'
    || ' '
    || TRIM(transaction_id) NOT IN (
        SELECT
            TRIM(source_entity)
            || ' '
            || TRIM(source_id)
        FROM
            ce_sales
    );

SELECT
    COUNT(transaction_id)
FROM
    sa_corporate.src_corporate
WHERE
    'SRC_CORPORATE'
    || ' '
    || TRIM(transaction_id) NOT IN (
        SELECT
            TRIM(source_entity)
            || ' '
            || TRIM(source_id)
        FROM
            ce_sales
    );

SELECT
    COUNT(transaction_id)
FROM
    sa_consumer.src_consumer
WHERE
    'SRC_CONSUMER'
    || ' '
    || TRIM(transaction_id) NOT IN (
        SELECT
            TRIM(s.source_entity)
            || ' '
            || TRIM(s.source_id)
        FROM
                 fct_sales f
            INNER JOIN ce_orders o ON f.order_id = o.order_id
            INNER JOIN ce_sales  s ON s.order_id = o.order_id
    );

SELECT
    COUNT(transaction_id)
FROM
    sa_corporate.src_corporate
WHERE
    'SRC_CORPORATE'
    || ' '
    || TRIM(transaction_id) NOT IN (
        SELECT
            TRIM(s.source_entity)
            || ' '
            || TRIM(s.source_id)
        FROM
                 fct_sales f
            INNER JOIN ce_orders o ON f.order_id = o.order_id
            INNER JOIN ce_sales  s ON s.order_id = o.order_id
    );