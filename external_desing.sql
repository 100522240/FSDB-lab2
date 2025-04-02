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
        IF :NEW.post_text IS NOT NULL THEN
            -- Update or insert post
            MERGE INTO Posts p
            USING (SELECT :NEW.loan_id AS loan_id FROM dual) src
            ON (p.loan_id = src.loan_id)
            WHEN MATCHED THEN
                UPDATE SET p.post_text = :NEW.post_text, 
                        p.post_date = SYSDATE
            WHEN NOT MATCHED THEN
                INSERT (loan_id, post_text, post_date, likes, dislikes)
                VALUES (:NEW.loan_id, :NEW.post_text, SYSDATE, 0, 0);
        END IF;
    END;
    /



CREATE OR REPLACE VIEW my_reservations AS
    SELECT *
    FROM loans j JOIN Copies c on l.signature = c.signature
    WHERE user_id = foundicu.get_current_user()
    AND type = "R";

CREATE OR REPLACE TRIGGER trg_manage_my_reservations
    INSTEAD OF INSERT OR UPDATE OR DELETE ON my_reservations
    FOR EACH ROW
    BEGIN
        IF INSERTING THEN
            -- Check book availability before inserting
            INSERT INTO Reservations (reservation_id, user_id, isbn, reserve_date, expiry_date)
            VALUES (:NEW.reservation_id, foundicu.get_current_user(), :NEW.isbn, :NEW.reserve_date, :NEW.expiry_date);
        ELSIF UPDATING THEN
            -- Allow date changes only if book is available
            UPDATE Reservations 
            SET reserve_date = :NEW.reserve_date, 
                expiry_date = :NEW.expiry_date
            WHERE reservation_id = :OLD.reservation_id;
        ELSIF DELETING THEN
            DELETE FROM Reservations WHERE reservation_id = :OLD.reservation_id;
        END IF;
    END;
    /
