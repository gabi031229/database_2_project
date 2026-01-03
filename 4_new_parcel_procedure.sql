ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

CREATE OR REPLACE PROCEDURE create_parcel_order (
    p_tracking_code        IN  parcel.tracking_code%TYPE,
    p_sender_customer_id   IN  parcel.sender_customer_id%TYPE,
    p_receiver_customer_id IN  parcel.receiver_customer_id%TYPE,
    p_weight_kg            IN  parcel.weight_kg%TYPE,
    p_size_category        IN  parcel.size_category%TYPE,
    p_declared_value_huf   IN  parcel.declared_value_huf%TYPE,

    p_init_depot_code      IN  depot.depot_code%TYPE DEFAULT NULL,
    p_init_courier_code    IN  courier.courier_code%TYPE DEFAULT NULL,

    p_payment_amount_huf   IN  payment.amount_huf%TYPE DEFAULT NULL,
    p_payment_method       IN  payment.method%TYPE DEFAULT NULL,
    p_payment_status       IN  payment.status%TYPE DEFAULT NULL,

    o_parcel_id            OUT parcel.id%TYPE
) IS
    v_depot_id   depot.id%TYPE;
    v_courier_id courier.id%TYPE;
BEGIN
    IF p_sender_customer_id = p_receiver_customer_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'Sender and receiver cannot be the same customer.');
    END IF;

    DECLARE v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM customer WHERE id = p_sender_customer_id;
        IF v_cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Sender customer not found.');
        END IF;

        SELECT COUNT(*) INTO v_cnt FROM customer WHERE id = p_receiver_customer_id;
        IF v_cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Receiver customer not found.');
        END IF;
    END;

    INSERT INTO parcel (
        tracking_code,
        sender_customer_id,
        receiver_customer_id,
        weight_kg,
        size_category,
        declared_value_huf,
        status
    ) VALUES (
        p_tracking_code,
        p_sender_customer_id,
        p_receiver_customer_id,
        p_weight_kg,
        p_size_category,
        p_declared_value_huf,
        'CREATED'
    )
    RETURNING id INTO o_parcel_id;

    IF p_payment_amount_huf IS NOT NULL THEN
        INSERT INTO payment (
            parcel_id,
            amount_huf,
            method,
            status,
            paid_at
        ) VALUES (
            o_parcel_id,
            p_payment_amount_huf,
            NVL(p_payment_method, 'CARD'),
            NVL(p_payment_status, 'PENDING'),
            CASE WHEN NVL(p_payment_status, 'PENDING') = 'PAID' THEN SYSTIMESTAMP ELSE NULL END
        );
    END IF;

    v_depot_id := NULL;
    v_courier_id := NULL;

    IF p_init_depot_code IS NOT NULL THEN
        SELECT id INTO v_depot_id
        FROM depot
        WHERE depot_code = p_init_depot_code;
    END IF;

    IF p_init_courier_code IS NOT NULL THEN
        SELECT id INTO v_courier_id
        FROM courier
        WHERE courier_code = p_init_courier_code;
    END IF;

    INSERT INTO tracking_event (
        parcel_id,
        event_type,
        depot_id,
        courier_id,
        notes
    ) VALUES (
        o_parcel_id,
        'CREATED',
        v_depot_id,
        v_courier_id,
        'Order created'
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Duplicate value (e.g., tracking_code already exists).');
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Depot or courier code not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

commit;
