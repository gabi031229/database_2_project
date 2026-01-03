ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;
CREATE OR REPLACE PACKAGE pkg_parcel AS
  PROCEDURE create_order(p_order IN parcel_order_t, o_parcel_id OUT NUMBER);
  PROCEDURE update_status(p_parcel_id IN NUMBER, p_new_status IN VARCHAR2);
END pkg_parcel;
/
CREATE OR REPLACE PACKAGE BODY pkg_parcel AS

  PROCEDURE create_order(p_order IN parcel_order_t, o_parcel_id OUT NUMBER) IS
  BEGIN
    INSERT INTO parcel(
      tracking_code, sender_customer_id, receiver_customer_id,
      weight_kg, size_category, declared_value_huf, status
    ) VALUES (
      p_order.tracking_code, p_order.sender_customer_id, p_order.receiver_customer_id,
      p_order.weight_kg, p_order.size_category, p_order.declared_value_huf, 'CREATED'
    )
    RETURNING id INTO o_parcel_id;

    IF p_order.payment_amount_huf IS NOT NULL THEN
      INSERT INTO payment(parcel_id, amount_huf, method, status, paid_at)
      VALUES (o_parcel_id, p_order.payment_amount_huf, NVL(p_order.payment_method,'CARD'), 'PENDING', NULL);
    END IF;

    INSERT INTO tracking_event(parcel_id, event_type, notes)
    VALUES (o_parcel_id, 'CREATED', 'Order created');

    COMMIT;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      pkg_log.error('PKG_PARCEL', 'CREATE_ORDER', 'PARCEL', o_parcel_id);
      ROLLBACK;
      RAISE;
    WHEN OTHERS THEN
      pkg_log.error('PKG_PARCEL', 'CREATE_ORDER', 'PARCEL', o_parcel_id);
      ROLLBACK;
      RAISE;
  END;

  PROCEDURE update_status(p_parcel_id IN NUMBER, p_new_status IN VARCHAR2) IS
  BEGIN
    UPDATE parcel
      SET status = p_new_status
    WHERE id = p_parcel_id;

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Parcel not found');
    END IF;

    INSERT INTO tracking_event(parcel_id, event_type, notes)
    VALUES (p_parcel_id, 'SCANNED_AT_DEPOT', 'Status changed to ' || p_new_status);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_log.error('PKG_PARCEL', 'UPDATE_STATUS', 'PARCEL', p_parcel_id);
      ROLLBACK;
      RAISE;
  END;

END pkg_parcel;
/
