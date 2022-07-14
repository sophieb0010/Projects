CREATE OR REPLACE PACKAGE pkg_src_load AUTHID definer IS
    PROCEDURE load_src_consumer;

    PROCEDURE load_src_corporate;

END;