CREATE TABLE ce_products (
    product_id             NUMBER(9) NOT NULL,
    source_system          VARCHAR2(20) NOT NULL,
    source_entity          VARCHAR2(20) NOT NULL,
    source_id              VARCHAR2(20) NOT NULL,
    product_name           VARCHAR2(120) NOT NULL,
    product_desc           VARCHAR2(60) NOT NULL,
    product_subcategory_id NUMBER(9) NOT NULL,
    insert_date            DATE NOT NULL,
    update_date            DATE NOT NULL,
    PRIMARY KEY ( product_id ),
    FOREIGN KEY ( product_subcategory_id )
        REFERENCES ce_product_subcategories ( product_subcategory_id )
);