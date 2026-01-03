ALTER SESSION SET CURRENT_SCHEMA = DELIVERY_HANDLER;

BEGIN
    FOR s IN (
        SELECT sequence_name
        FROM user_sequences
        WHERE sequence_name IN (
            'CUSTOMER_SEQ',
            'DEPOT_SEQ',
            'PARCEL_LOCKER_SEQ',
            'COURIER_SEQ',
            'PARCEL_SEQ',
            'PARCEL_PARCEL_LOCKER_SEQ',
            'TRACKING_EVENT_SEQ',
            'PAYMENT_SEQ'
        )
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                    RAISE;
                END IF;
        END;
    END LOOP;
END;
/


CREATE SEQUENCE customer_seq START WITH 13400 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE depot_seq START WITH 27000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE parcel_locker_seq START WITH 2900 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE courier_seq START WITH 34500 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE parcel_seq START WITH 86200 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE parcel_parcel_locker_seq START WITH 45600 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE tracking_event_seq START WITH 11000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE payment_seq START WITH 55000 INCREMENT BY 1 NOCACHE;
/

CREATE OR REPLACE TRIGGER customer_bi
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT customer_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;

    IF :NEW.created_at IS NULL THEN
        :NEW.created_at := SYSTIMESTAMP;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER depot_bi
BEFORE INSERT ON depot
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT depot_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER parcel_locker_bi
BEFORE INSERT ON parcel_locker
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT parcel_locker_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;

    IF :NEW.created_at IS NULL THEN
        :NEW.created_at := SYSTIMESTAMP;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER courier_bi
BEFORE INSERT ON courier
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT courier_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER parcel_bi
BEFORE INSERT ON parcel
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT parcel_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;

    IF :NEW.created_at IS NULL THEN
        :NEW.created_at := SYSTIMESTAMP;
    END IF;

    IF :NEW.updated_at IS NULL THEN
        :NEW.updated_at := :NEW.created_at;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER parcel_parcel_locker_bi
BEFORE INSERT ON parcel_parcel_locker
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT parcel_parcel_locker_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;

    IF :NEW.placed_at IS NULL THEN
        :NEW.placed_at := SYSTIMESTAMP;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER tracking_event_bi
BEFORE INSERT ON tracking_event
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT tracking_event_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;

    IF :NEW.event_time IS NULL THEN
        :NEW.event_time := SYSTIMESTAMP;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER payment_bi
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT payment_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/


CREATE OR REPLACE TRIGGER parcel_bu
BEFORE UPDATE ON parcel
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

