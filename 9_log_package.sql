ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

CREATE OR REPLACE PACKAGE pkg_log AS
  PROCEDURE info(p_module VARCHAR2, p_action VARCHAR2, p_msg VARCHAR2);
  PROCEDURE error(
    p_module VARCHAR2,
    p_action VARCHAR2,
    p_entity VARCHAR2 DEFAULT NULL,
    p_entity_id NUMBER DEFAULT NULL
  );
END pkg_log;
/
CREATE OR REPLACE PACKAGE BODY pkg_log AS
  PROCEDURE info(p_module VARCHAR2, p_action VARCHAR2, p_msg VARCHAR2) IS
  BEGIN
    INSERT INTO app_log(id, level_code, module_name, action_name, err_message)
    VALUES (app_log_seq.NEXTVAL, 'INFO', p_module, p_action, p_msg);
  END;

  PROCEDURE error(
    p_module VARCHAR2,
    p_action VARCHAR2,
    p_entity VARCHAR2 DEFAULT NULL,
    p_entity_id NUMBER DEFAULT NULL
  ) IS
  BEGIN
    INSERT INTO app_log(
      id, level_code, module_name, action_name, entity_name, entity_id,
      err_code, err_message, backtrace
    ) VALUES (
      app_log_seq.NEXTVAL, 'ERROR', p_module, p_action, p_entity, p_entity_id,
      SQLCODE, SUBSTR(SQLERRM, 1, 4000),
      SUBSTR(DBMS_UTILITY.format_error_backtrace, 1, 4000)
    );
  END;
END pkg_log;
/
