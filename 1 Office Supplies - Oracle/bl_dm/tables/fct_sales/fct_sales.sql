CREATE TABLE fct_sales (
    order_date_id     DATE NOT NULL,
    shipping_date_id  DATE NOT NULL,
    city_surr_id      NUMBER(9) NOT NULL,
    shipping_surr_id  NUMBER(9) NOT NULL,
    payment_surr_id   NUMBER(9) NOT NULL,
    employee_surr_id  NUMBER(9) NOT NULL,
    product_surr_id   NUMBER(9) NOT NULL,
    customer_surr_id  NUMBER(9) NOT NULL,
    order_id          NUMBER(9) NOT NULL,
    fct_price_dollars NUMBER(9, 2) NOT NULL,
    fct_costs_dollars NUMBER(9, 2) NOT NULL,
    fct_sales_units   NUMBER(9) NOT NULL,
    fct_sales_dollars NUMBER(9, 2) NOT NULL,
    insert_date       DATE NOT NULL,
    update_date       DATE NOT NULL
)
    PARTITION BY RANGE (
        order_date_id
    )
    ( PARTITION p201101
        VALUES LESS THAN ( TO_DATE('01/02/2011', 'DD/MM/YYYY') ),
    PARTITION p201102
        VALUES LESS THAN ( TO_DATE('01/03/2011', 'DD/MM/YYYY') ),
    PARTITION p201103
        VALUES LESS THAN ( TO_DATE('01/04/2011', 'DD/MM/YYYY') ),
    PARTITION p201104
        VALUES LESS THAN ( TO_DATE('01/05/2011', 'DD/MM/YYYY') ),
    PARTITION p201105
        VALUES LESS THAN ( TO_DATE('01/06/2011', 'DD/MM/YYYY') ),
    PARTITION p201106
        VALUES LESS THAN ( TO_DATE('01/07/2011', 'DD/MM/YYYY') ),
    PARTITION p201107
        VALUES LESS THAN ( TO_DATE('01/08/2011', 'DD/MM/YYYY') ),
    PARTITION p201108
        VALUES LESS THAN ( TO_DATE('01/09/2011', 'DD/MM/YYYY') ),
    PARTITION p201109
        VALUES LESS THAN ( TO_DATE('01/10/2011', 'DD/MM/YYYY') ),
    PARTITION p201110
        VALUES LESS THAN ( TO_DATE('01/11/2011', 'DD/MM/YYYY') ),
    PARTITION p201111
        VALUES LESS THAN ( TO_DATE('01/12/2011', 'DD/MM/YYYY') ),
    PARTITION p201112
        VALUES LESS THAN ( TO_DATE('01/01/2012', 'DD/MM/YYYY') ),
    PARTITION p201201
        VALUES LESS THAN ( TO_DATE('01/02/2012', 'DD/MM/YYYY') ),
    PARTITION p201202
        VALUES LESS THAN ( TO_DATE('01/03/2012', 'DD/MM/YYYY') ),
    PARTITION p201203
        VALUES LESS THAN ( TO_DATE('01/04/2012', 'DD/MM/YYYY') ),
    PARTITION p201204
        VALUES LESS THAN ( TO_DATE('01/05/2012', 'DD/MM/YYYY') ),
    PARTITION p201205
        VALUES LESS THAN ( TO_DATE('01/06/2012', 'DD/MM/YYYY') ),
    PARTITION p201206
        VALUES LESS THAN ( TO_DATE('01/07/2012', 'DD/MM/YYYY') ),
    PARTITION p201207
        VALUES LESS THAN ( TO_DATE('01/08/2012', 'DD/MM/YYYY') ),
    PARTITION p201208
        VALUES LESS THAN ( TO_DATE('01/09/2012', 'DD/MM/YYYY') ),
    PARTITION p201209
        VALUES LESS THAN ( TO_DATE('01/10/2012', 'DD/MM/YYYY') ),
    PARTITION p201210
        VALUES LESS THAN ( TO_DATE('01/11/2012', 'DD/MM/YYYY') ),
    PARTITION p201211
        VALUES LESS THAN ( TO_DATE('01/12/2012', 'DD/MM/YYYY') ),
    PARTITION p201212
        VALUES LESS THAN ( TO_DATE('01/01/2013', 'DD/MM/YYYY') ),
    PARTITION p201301
        VALUES LESS THAN ( TO_DATE('01/02/2013', 'DD/MM/YYYY') ),
    PARTITION p201302
        VALUES LESS THAN ( TO_DATE('01/03/2013', 'DD/MM/YYYY') ),
    PARTITION p201303
        VALUES LESS THAN ( TO_DATE('01/04/2013', 'DD/MM/YYYY') ),
    PARTITION p201304
        VALUES LESS THAN ( TO_DATE('01/05/2013', 'DD/MM/YYYY') ),
    PARTITION p201305
        VALUES LESS THAN ( TO_DATE('01/06/2013', 'DD/MM/YYYY') ),
    PARTITION p201306
        VALUES LESS THAN ( TO_DATE('01/07/2013', 'DD/MM/YYYY') ),
    PARTITION p201307
        VALUES LESS THAN ( TO_DATE('01/08/2013', 'DD/MM/YYYY') ),
    PARTITION p201308
        VALUES LESS THAN ( TO_DATE('01/09/2013', 'DD/MM/YYYY') ),
    PARTITION p201309
        VALUES LESS THAN ( TO_DATE('01/10/2013', 'DD/MM/YYYY') ),
    PARTITION p201310
        VALUES LESS THAN ( TO_DATE('01/11/2013', 'DD/MM/YYYY') ),
    PARTITION p201311
        VALUES LESS THAN ( TO_DATE('01/12/2013', 'DD/MM/YYYY') ),
    PARTITION p201312
        VALUES LESS THAN ( TO_DATE('01/01/2014', 'DD/MM/YYYY') ),
    PARTITION p201401
        VALUES LESS THAN ( TO_DATE('01/02/2014', 'DD/MM/YYYY') ),
    PARTITION p201402
        VALUES LESS THAN ( TO_DATE('01/03/2014', 'DD/MM/YYYY') ),
    PARTITION p201403
        VALUES LESS THAN ( TO_DATE('01/04/2014', 'DD/MM/YYYY') ),
    PARTITION p201404
        VALUES LESS THAN ( TO_DATE('01/05/2014', 'DD/MM/YYYY') ),
    PARTITION p201405
        VALUES LESS THAN ( TO_DATE('01/06/2014', 'DD/MM/YYYY') ),
    PARTITION p201406
        VALUES LESS THAN ( TO_DATE('01/07/2014', 'DD/MM/YYYY') ),
    PARTITION p201407
        VALUES LESS THAN ( TO_DATE('01/08/2014', 'DD/MM/YYYY') ),
    PARTITION p201408
        VALUES LESS THAN ( TO_DATE('01/09/2014', 'DD/MM/YYYY') ),
    PARTITION p201409
        VALUES LESS THAN ( TO_DATE('01/10/2014', 'DD/MM/YYYY') ),
    PARTITION p201410
        VALUES LESS THAN ( TO_DATE('01/11/2014', 'DD/MM/YYYY') ),
    PARTITION p201411
        VALUES LESS THAN ( TO_DATE('01/12/2014', 'DD/MM/YYYY') ),
    PARTITION p201412
        VALUES LESS THAN ( TO_DATE('01/01/2015', 'DD/MM/YYYY') )
    );