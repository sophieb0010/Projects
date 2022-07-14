INSERT INTO ce_sales (
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
    update_date
) VALUES (
    - 1,
    'SA_CONSUMER',
    'SRC_CONSUMER',
    'N/A',
    - 1,
    - 1,
    - 1,
    - 1,
    - 1,
    - 1,
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

INSERT INTO ce_sales (
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
    update_date
) VALUES (
    - 2,
    'SA_CORPORATE',
    'SRC_CORPORATE',
    'N/A',
    - 2,
    - 2,
    - 2,
    - 2,
    - 2,
    - 2,
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

COMMIT;