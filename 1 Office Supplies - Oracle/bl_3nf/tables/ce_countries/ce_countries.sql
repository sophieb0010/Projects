CREATE TABLE ce_countries (
    country_id    NUMBER(9) NOT NULL,
    source_system VARCHAR2(20) NOT NULL,
    source_entity VARCHAR2(20) NOT NULL,
    source_id     VARCHAR2(40) NOT NULL,
    country       VARCHAR2(40) NOT NULL,
    market_id     NUMBER(9) NOT NULL,
    insert_date   DATE NOT NULL,
    update_date   DATE NOT NULL,
    PRIMARY KEY ( country_id ),
    FOREIGN KEY ( market_id )
        REFERENCES ce_markets ( market_id )
);