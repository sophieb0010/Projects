INSERT INTO ce_payments (
    payment_id,
    source_system,
    source_entity,
    source_id,
    payment_type,
    start_date,
    end_date,
    is_active,
    insert_date
) VALUES (
    - 1,
    'SA_CONSUMER',
    'SRC_CONSUMER',
    'N/A',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-9999', 'DD-MM-YYYY'),
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

INSERT INTO ce_payments (
    payment_id,
    source_system,
    source_entity,
    source_id,
    payment_type,
    start_date,
    end_date,
    is_active,
    insert_date
) VALUES (
    - 2,
    'SA_CORPORATE',
    'SRC_CORPORATE',
    'N/A',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-9999', 'DD-MM-YYYY'),
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

COMMIT;