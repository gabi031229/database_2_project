ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

CREATE OR REPLACE VIEW v_parcel_overview AS
SELECT
    p.id                    AS parcel_id,
    p.tracking_code,
    p.status,
    p.created_at,

    sender.full_name        AS sender_name,
    sender.email            AS sender_email,

    receiver.full_name      AS receiver_name,
    receiver.email          AS receiver_email,

    pay.amount_huf,
    pay.method              AS payment_method,
    pay.status              AS payment_status

FROM parcel p
JOIN customer sender
    ON sender.id = p.sender_customer_id
JOIN customer receiver
    ON receiver.id = p.receiver_customer_id
LEFT JOIN payment pay
    ON pay.parcel_id = p.id;
    
/
SELECT * FROM v_parcel_overview;
/

CREATE OR REPLACE VIEW v_parcel_current_location AS
SELECT
    p.id            AS parcel_id,
    p.tracking_code,
    pl.locker_code,
    pl.city         AS locker_city,
    x.placed_at,
    x.operation,
    x.removed_at
FROM parcel p
LEFT JOIN (
    SELECT
        ppl.*,
        ROW_NUMBER() OVER (
            PARTITION BY ppl.parcel_id
            ORDER BY ppl.placed_at DESC, ppl.id DESC
        ) AS rn
    FROM parcel_parcel_locker ppl
) x
    ON x.parcel_id = p.id
   AND x.rn = 1
LEFT JOIN parcel_locker pl
    ON pl.id = x.parcel_locker_id;

/
SELECT * FROM v_parcel_current_location;

/
CREATE OR REPLACE VIEW v_tracking_history_detailed AS
SELECT
    te.id             AS tracking_event_id,
    te.event_time,
    te.event_type,
    te.notes,

    p.tracking_code,

    d.depot_code,
    pl.locker_code,

    c.full_name       AS courier_name

FROM tracking_event te
JOIN parcel p
    ON p.id = te.parcel_id
LEFT JOIN depot d
    ON d.id = te.depot_id
LEFT JOIN parcel_locker pl
    ON pl.id = te.parcel_locker_id
LEFT JOIN courier c
    ON c.id = te.courier_id;

SELECT *
FROM v_tracking_history_detailed
WHERE tracking_code = 'TRK900001'
ORDER BY event_time;
