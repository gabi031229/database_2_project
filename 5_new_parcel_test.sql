ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;
DECLARE
    v_parcel_id parcel.id%TYPE;
BEGIN
    create_parcel_order(
        p_tracking_code        => 'TRK900001',
        p_sender_customer_id   => 13400,
        p_receiver_customer_id => 13401,
        p_weight_kg            => 1.25,
        p_size_category        => 'M',
        p_declared_value_huf   => 12000,

        p_init_depot_code      => 'DEP-BP',
        p_init_courier_code    => 'CR-001',

        p_payment_amount_huf   => 1990,
        p_payment_method       => 'CARD',
        p_payment_status       => 'PAID',

        o_parcel_id            => v_parcel_id
    );
END;
/
