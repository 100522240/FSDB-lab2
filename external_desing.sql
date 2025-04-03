CREATE OR REPLACE VIEW my_data AS
    SELECT *
    FROM Users
    WHERE user_id = foundicu.get_current_user()
    with read only;



CREATE OR REPLACE VIEW my_loans AS
    SELECT distinct l.signature, l.stopdate, l.return, 
        p.post_date, p.likes, p.dislikes, p.text
    FROM Loans l
    LEFT JOIN Posts p ON l.user_id = p.user_id
    WHERE l.user_id = foundicu.get_current_user();

CREATE OR REPLACE TRIGGER trg_update_my_loans
INSTEAD OF UPDATE ON my_loans
FOR EACH ROW
BEGIN
    IF :NEW.text IS NOT NULL THEN
        -- First, try updating the existing post
        UPDATE Posts
        SET text = :NEW.text,
            post_date = SYSDATE
        WHERE signature = :NEW.signature;
        
        -- If no rows were updated, insert a new post
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO Posts (user_id, signature, text, stopdate, post_date, likes, dislikes)
            VALUES (foundicu.get_current_user, :NEW.signature, :NEW.text, :OLD.stopdate, SYSDATE, 0, 0);
        END IF;
    END IF;
END;
/

create or replace trigger trg_cancel_insertion
instead of insert on my_loans
for each row
begin
    raise_application_error(-20052, 'User cannot insert into views');
end;
/

create or replace trigger trg_cancel_deletion
instead of delete on my_loans
for each row
begin
    raise_application_error(-20080, 'User cannot delete from the view');
end;
/

CREATE OR REPLACE VIEW my_reservations AS
    SELECT l.signature, l.stopdate, l.return, l.user_id, c.isbn, l.time, l.type, l.town, l.province
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
            INSERT INTO loans (signature, user_id, stopdate, town, province, time, type, return)
            VALUES (:NEW.signature, foundicu.get_current_user(), :NEW.stopdate, :NEW.town, :NEW.province, :NEW.time, :NEW.type, :NEW.return);
        ELSIF UPDATING THEN
            -- Allow date changes only if book is available
            UPDATE loans
            SET stopdate = :NEW.stopdate, return = :NEW.return
            WHERE signature = :OLD.signature;
        ELSIF DELETING THEN
            DELETE FROM loans WHERE signature = :OLD.signature;
        END IF;
    END;
    /
