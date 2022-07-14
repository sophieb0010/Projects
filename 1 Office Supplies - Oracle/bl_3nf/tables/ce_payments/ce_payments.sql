CREATE TABLE ce_payments (
    payment_id    NUMBER(9) NOT NULL,
    source_system VARCHAR2(20) NOT NULL,
    source_entity VARCHAR2(20) NOT NULL,
    source_id     VARCHAR2(20) NOT NULL,
    payment_type  VARCHAR2(20) NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    is_active     VARCHAR2(20) NOT NULL,
    insert_date   DATE NOT NULL,
    PRIMARY KEY ( payment_id,
                  start_date )
);