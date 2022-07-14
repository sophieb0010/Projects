CREATE TABLE ce_sales (
    sale_id       NUMBER(9) NOT NULL,
    source_system VARCHAR2(20) NOT NULL,
    source_entity VARCHAR2(20) NOT NULL,
    source_id     VARCHAR2(20) NOT NULL,
    price_dollars NUMBER(9, 2) NOT NULL,
    costs_dollars NUMBER(9, 2) NOT NULL,
    sales_units   NUMBER(9) NOT NULL,
    sales_dollars NUMBER(9, 2) NOT NULL,
    product_id    NUMBER(9) NOT NULL,
    order_id      NUMBER(9) NOT NULL,
    insert_date   TIMESTAMP NOT NULL,
    update_date   TIMESTAMP NOT NULL,
    PRIMARY KEY ( sale_id ),
    FOREIGN KEY ( product_id )
        REFERENCES ce_products ( product_id ),
    CONSTRAINT ce_sales_fk FOREIGN KEY ( order_id )
        REFERENCES ce_orders ( order_id )
)
    PARTITION BY REFERENCE ( ce_sales_fk );