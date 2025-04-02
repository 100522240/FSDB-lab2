CREATE OR REPLACE VIEW my_data AS
    SELECT *
    FROM Users
    WHERE user_id = foundicu.get_current_user();



CREATE OR REPLACE VIEW my_loans AS
    SELECT l.signature, l.stopdate, l.return, 
        p.text, p.post_date, p.likes, p.dislikes
    FROM Loans l
    LEFT JOIN Posts p ON l.user_id = p.user_id
    WHERE l.user_id = foundicu.get_current_user();

CREATE OR REPLACE TRIGGER trg_update_my_loans
    INSTEAD OF UPDATE ON my_loans
    FOR EACH ROW
    BEGIN
        IF :NEW.text IS NOT NULL THEN
            -- Update or insert post
            MERGE INTO Posts p
            USING (SELECT :NEW.signature AS signature FROM dual) src
            ON (p.signature = src.signature)
            WHEN MATCHED THEN
                UPDATE SET p.text = :NEW.text, 
                        p.post_date = SYSDATE
            WHEN NOT MATCHED THEN
                INSERT into posts (singature, text, post_date, likes, dislikes)
                VALUES (:NEW.signature, :NEW.text, SYSDATE, 0, 0);
        END IF;
    END;
    /



CREATE OR REPLACE VIEW my_reservations AS
    SELECT 
    l.signature,
    l.stopdate,
    l.return,
    l.user_id,
    c.isbn

    FROM loans l
    JOIN copies c on l.signature = c.signature
    WHERE l.user_id = foundicu.get_current_user()
    AND l.type = 'R';

CREATE OR REPLACE TRIGGER trg_manage_my_reservations
    INSTEAD OF INSERT OR UPDATE OR DELETE ON my_reservations
    FOR EACH ROW
    BEGIN
        IF INSERTING THEN
            -- Check book availability before inserting
            INSERT INTO loans (signature, user_id, stopdate, time, type, return)
            VALUES (:NEW.signature, foundicu.get_current_user(), :NEW.stopdate, :NEW.time, :NEW.type, :NEW.return);
        ELSIF UPDATING THEN
            -- Allow date changes only if book is available
            UPDATE loans
            SET stopdate = :NEW.stopdate, 
                return = :NEW.return
            WHERE signature = :OLD.signature;
        ELSIF DELETING THEN
            DELETE FROM loan WHERE signature = :OLD.signature;
        END IF;
    END;
    /
