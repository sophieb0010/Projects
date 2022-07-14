INSERT INTO ce_product_categories (
    product_category_id,
    source_system,
    source_entity,
    source_id,
    product_category,
    insert_date,
    update_date
) VALUES (
    - 1,
    'SA_CONSUMER',
    'SRC_CONSUMER',
    'N/A',
    'N/A',
    TO_DATE('01-01-2011', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);


INSERT INTO ce_product_categories (
    product_category_id,
    source_system,
    source_entity,
    source_id,
    product_category,
    insert_date,
    update_date
) VALUES (
    - 2,
    'SA_CORPORATE',
    'SRC_CORPORATE',
    'N/A',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

COMMIT;