ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

INSERT INTO customer (full_name, email, phone, city, postal_code)
VALUES ('Kovács Péter', 'kovacs.peter@test.hu', '+361111111', 'Budapest', '1111');

INSERT INTO customer (full_name, email, phone, city, postal_code)
VALUES ('Nagy Anna', 'nagy.anna@test.hu', '+362222222', 'Pécs', '7621');

INSERT INTO customer (full_name, email, phone, city, postal_code)
VALUES ('Szabó Gábor', 'szabo.gabor@test.hu', '+363333333', 'Szeged', '6720');

INSERT INTO depot (depot_code, name, city)
VALUES ('DEP-BP', 'Budapest Central Depot', 'Budapest');

INSERT INTO depot (depot_code, name, city)
VALUES ('DEP-PE', 'Pécs Sorting Depot', 'Pécs');

INSERT INTO parcel_locker (locker_code, name, city, street_address, depot_id)
VALUES (
    'LOCK-BP-01',
    'Blaha Locker',
    'Budapest',
    'Blaha Lujza tér 1',
    (SELECT id FROM depot WHERE depot_code = 'DEP-BP')
);

INSERT INTO parcel_locker (locker_code, name, city, street_address, depot_id)
VALUES (
    'LOCK-PE-01',
    'Árkád Locker',
    'Pécs',
    'Bajcsy-Zsilinszky u. 11',
    (SELECT id FROM depot WHERE depot_code = 'DEP-PE')
);

INSERT INTO courier (courier_code, full_name, phone)
VALUES ('CR-001', 'Tóth László', '+364444444');

INSERT INTO courier (courier_code, full_name, phone)
VALUES ('CR-002', 'Varga Zoltán', '+365555555');


INSERT INTO parcel (
    tracking_code,
    sender_customer_id,
    receiver_customer_id,
    weight_kg,
    size_category,
    declared_value_huf,
    status
)
VALUES (
    'TRK000001',
    (SELECT id FROM customer WHERE email = 'kovacs.peter@test.hu'),
    (SELECT id FROM customer WHERE email = 'nagy.anna@test.hu'),
    2.50,
    'M',
    15000,
    'IN_TRANSIT'
);

INSERT INTO parcel (
    tracking_code,
    sender_customer_id,
    receiver_customer_id,
    weight_kg,
    size_category,
    declared_value_huf,
    status
)
VALUES (
    'TRK000002',
    (SELECT id FROM customer WHERE email = 'szabo.gabor@test.hu'),
    (SELECT id FROM customer WHERE email = 'kovacs.peter@test.hu'),
    0.80,
    'S',
    5000,
    'IN_LOCKER'
);

INSERT INTO parcel_parcel_locker (
    parcel_id,
    parcel_locker_id,
    operation
)
VALUES (
    (SELECT id FROM parcel WHERE tracking_code = 'TRK000002'),
    (SELECT id FROM parcel_locker WHERE locker_code = 'LOCK-BP-01'),
    'DROPOFF'
);


INSERT INTO tracking_event (
    parcel_id,
    event_type,
    depot_id,
    courier_id,
    notes
)
VALUES (
    (SELECT id FROM parcel WHERE tracking_code = 'TRK000001'),
    'SCANNED_AT_DEPOT',
    (SELECT id FROM depot WHERE depot_code = 'DEP-BP'),
    (SELECT id FROM courier WHERE courier_code = 'CR-001'),
    'Parcel scanned at Budapest depot'
);

INSERT INTO tracking_event (
    parcel_id,
    event_type,
    parcel_locker_id,
    notes
)
VALUES (
    (SELECT id FROM parcel WHERE tracking_code = 'TRK000002'),
    'ARRIVED_LOCKER',
    (SELECT id FROM parcel_locker WHERE locker_code = 'LOCK-BP-01'),
    'Parcel placed into locker'
);

INSERT INTO payment (
    parcel_id,
    amount_huf,
    method,
    status,
    paid_at
)
VALUES (
    (SELECT id FROM parcel WHERE tracking_code = 'TRK000001'),
    1990,
    'CARD',
    'PAID',
    SYSTIMESTAMP
);

INSERT INTO payment (
    parcel_id,
    amount_huf,
    method,
    status
)
VALUES (
    (SELECT id FROM parcel WHERE tracking_code = 'TRK000002'),
    2490,
    'COD',
    'PENDING'
);


commit;