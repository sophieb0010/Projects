CREATE TABLE ce_product_subcategories (
    product_subcategory_id NUMBER(9) NOT NULL,
    source_system          VARCHAR2(20) NOT NULL,
    source_entity          VARCHAR2(25) NOT NULL,
    source_id              VARCHAR2(40) NOT NULL,
    product_subcategory    VARCHAR2(40) NOT NULL,
    product_category_id    NUMBER(9) NOT NULL,
    insert_date            DATE NOT NULL,
    update_date            DATE NOT NULL,
    PRIMARY KEY ( product_subcategory_id ),
    FOREIGN KEY ( product_category_id )
        REFERENCES ce_product_categories ( product_category_id )
);