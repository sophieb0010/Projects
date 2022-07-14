INSERT INTO ce_product_subcategories (
    product_subcategory_id,
    source_system,
    source_entity,
    source_id,
    product_subcategory,
    product_category_id,
    insert_date,
    update_date
) VALUES (
    - 1,
    'SA_CONSUMER',
    'SRC_CONSUMER',
    'N/A, N/A',
    'N/A',
    - 1,
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

INSERT INTO ce_product_subcategories (
    product_subcategory_id,
    source_system,
    source_entity,
    source_id,
    product_subcategory,
    product_category_id,
    insert_date,
    update_date
) VALUES (
    - 2,
    'SA_CORPORATE',
    'SRC_CORPORATE',
    'N/A, N/A',
    'N/A',
    - 2,
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

COMMIT;