ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

CREATE TABLE app_log (
  id            NUMBER PRIMARY KEY,
  log_on        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  level_code    VARCHAR2(10) NOT NULL, -- INFO / WARN / ERROR
  module_name   VARCHAR2(100),
  action_name   VARCHAR2(100),
  entity_name   VARCHAR2(50),
  entity_id     NUMBER,
  err_code      NUMBER,
  err_message   VARCHAR2(4000),
  backtrace     VARCHAR2(4000)
);

CREATE SEQUENCE app_log_seq START WITH 100000 INCREMENT BY 1 NOCACHE NOCYCLE;
