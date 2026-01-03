ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

-- parcel historyjának mentése a felhasználó adataival, snapshottal és technikai mezõkkel
CREATE OR REPLACE TRIGGER parcel_aud_trg
AFTER INSERT OR UPDATE OR DELETE ON parcel
FOR EACH ROW
BEGIN
  INSERT INTO parcel_h (
    hist_id, hist_on, hist_by, hist_action,
    id, tracking_code, sender_customer_id, receiver_customer_id, weight_kg,
    size_category, declared_value_huf, status,
    created_on, created_by, updated_on, updated_by, dml_flag, version
  ) VALUES (
    parcel_h_seq.NEXTVAL,
    SYSTIMESTAMP,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    CASE
      WHEN INSERTING THEN 'I'
      WHEN UPDATING THEN 'U'
      ELSE 'D'
    END,
    CASE WHEN DELETING THEN :OLD.id ELSE :NEW.id END,
    CASE WHEN DELETING THEN :OLD.tracking_code ELSE :NEW.tracking_code END,
    CASE WHEN DELETING THEN :OLD.sender_customer_id ELSE :NEW.sender_customer_id END,
    CASE WHEN DELETING THEN :OLD.receiver_customer_id ELSE :NEW.receiver_customer_id END,
    CASE WHEN DELETING THEN :OLD.weight_kg ELSE :NEW.weight_kg END,
    CASE WHEN DELETING THEN :OLD.size_category ELSE :NEW.size_category END,
    CASE WHEN DELETING THEN :OLD.declared_value_huf ELSE :NEW.declared_value_huf END,
    CASE WHEN DELETING THEN :OLD.status ELSE :NEW.status END,
    CASE WHEN DELETING THEN :OLD.created_on ELSE :NEW.created_on END,
    CASE WHEN DELETING THEN :OLD.created_by ELSE :NEW.created_by END,
    CASE WHEN DELETING THEN :OLD.updated_on ELSE :NEW.updated_on END,
    CASE WHEN DELETING THEN :OLD.updated_by ELSE :NEW.updated_by END,
    CASE WHEN DELETING THEN :OLD.dml_flag ELSE :NEW.dml_flag END,
    CASE WHEN DELETING THEN :OLD.version ELSE :NEW.version END
  );
END;
/
commit;
