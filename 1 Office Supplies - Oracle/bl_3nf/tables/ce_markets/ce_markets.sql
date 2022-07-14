CREATE TABLE ce_markets (
    market_id     NUMBER(9) NOT NULL,
    source_system VARCHAR2(20) NOT NULL,
    source_entity VARCHAR2(20) NOT NULL,
    source_id     VARCHAR2(20) NOT NULL,
    market        VARCHAR2(20) NOT NULL,
    insert_date   DATE NOT NULL,
    update_date   DATE NOT NULL,
    PRIMARY KEY ( market_id )
);