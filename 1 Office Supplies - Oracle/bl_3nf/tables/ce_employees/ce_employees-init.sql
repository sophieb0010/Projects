INSERT INTO ce_employees (
    employee_id,
    source_system,
    source_entity,
    source_id,
    employee_first_name,
    employee_last_name,
    employee_email,
    employee_gender,
    phone,
    department,
    job_skill,
    insert_date,
    update_date
) VALUES (
    - 1,
    'SA_CONSUMER',
    'SRC_CONSUMER',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

INSERT INTO ce_employees (
    employee_id,
    source_system,
    source_entity,
    source_id,
    employee_first_name,
    employee_last_name,
    employee_email,
    employee_gender,
    phone,
    department,
    job_skill,
    insert_date,
    update_date
) VALUES (
    - 2,
    'SA_CORPORATE',
    'SRC_CORPORATE',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    TO_DATE('01-01-1970', 'DD-MM-YYYY'),
    TO_DATE('01-01-1970', 'DD-MM-YYYY')
);

COMMIT;