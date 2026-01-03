ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;
CREATE OR REPLACE TYPE parcel_order_t AS OBJECT (
  tracking_code        VARCHAR2(40),
  sender_customer_id   NUMBER,
  receiver_customer_id NUMBER,
  weight_kg            NUMBER,
  size_category        VARCHAR2(20),
  declared_value_huf   NUMBER,
  payment_amount_huf   NUMBER,
  payment_method       VARCHAR2(20)
);
/
