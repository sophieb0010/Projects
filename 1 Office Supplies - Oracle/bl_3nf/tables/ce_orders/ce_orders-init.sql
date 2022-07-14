INSERT INTO ce_orders (
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
    update_date
) VALUES (
    - 1,
    'SA_CONSUMER',
    'SRC_CONSUMER',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    - 1,
    - 1,
    - 1,
    - 1,
    - 1,
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

INSERT INTO ce_orders (
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
    update_date
) VALUES (
    - 2,
    'SA_CORPORATE',
    'SRC_CORPORATE',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    - 2,
    - 2,
    - 2,
    - 2,
    - 2,
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

COMMIT;