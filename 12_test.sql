ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

DECLARE
  v_order     parcel_order_t;
  v_parcel_id NUMBER;
BEGIN
  v_order := parcel_order_t(
    tracking_code        => 'TEST_TRK_001',
    sender_customer_id   => (SELECT id FROM customer WHERE ROWNUM = 1),
    receiver_customer_id => (SELECT id FROM customer WHERE ROWNUM = 2),
    weight_kg            => 1.50,
    size_category        => 'M',
    declared_value_huf   => 12000,
    payment_amount_huf   => 1990,
    payment_method       => 'CARD'
  );

  pkg_parcel.create_order(
    p_order     => v_order,
    o_parcel_id => v_parcel_id
  );

  DBMS_OUTPUT.PUT_LINE('New parcel created with ID = ' || v_parcel_id);
END;
/
