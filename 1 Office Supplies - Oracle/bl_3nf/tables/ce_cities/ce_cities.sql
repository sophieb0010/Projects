CREATE TABLE ce_cities (
    city_id       NUMBER(9) NOT NULL,
    source_system VARCHAR2(20) NOT NULL,
    source_entity VARCHAR2(20) NOT NULL,
    source_id     VARCHAR2(60) NOT NULL,
    city          VARCHAR2(40) NOT NULL,
    country_id    NUMBER(9) NOT NULL,
    insert_date   DATE NOT NULL,
    update_date   DATE NOT NULL,
    PRIMARY KEY ( city_id ),
    FOREIGN KEY ( country_id )
        REFERENCES ce_countries ( country_id )
);