--Trigger that checks that the user trying to write a post is not a library
create or replace trigger trg_prevent_institutional_posts
before update or insert on posts
for each row
Declare
    v_name varchar2(80);
begin
    --Insert into a local variable the number of the current user in package foundicu
    select name into v_name
    from users
    where user_id = foundicu.get_current_user;

    --If the name starts with the word 'Biblioteca', then raise an error
    if v_name like 'Biblioteca%' then
        raise_application_error(-20015, 'Municipal libraries cannot write posts');
    end if;
end;
/

--Trigger for checking the condition of a copy is set to deteriorated
create or replace trigger trg_manage_deteriorated
before update on copies
for each row
begin
    --Check if the condition is deteriorated ('D')
    if :NEW.condition = 'D' THEN
        --If so, then set the deregistered date to the actual date
        :NEW.DEREGISTERED := sysdate;
    end if;
end;
/

--Create history table for users
create table user_history (
    USER_ID            CHAR(10),
    ID_CARD            CHAR(17) NOT NULL,
    NAME               VARCHAR2(80) NOT NULL,
    SURNAME1           VARCHAR2(80) NOT NULL,
    SURNAME2           VARCHAR2(80),
    BIRTHDATE          DATE NOT NULL,
    TOWN               VARCHAR2(50) NOT NULL,
    PROVINCE           VARCHAR2(22) NOT NULL,
    ADDRESS            VARCHAR2(150) NOT NULL,
    EMAIL              VARCHAR2(100),
    PHONE              NUMBER(9) NOT NULL,
    TYPE               CHAR(1) NOT NULL,
    BAN_UP2            DATE
);

--Create history table for loans
create table loan_history (
    SIGNATURE          CHAR(5),
    USER_ID            CHAR(10),
    STOPDATE           DATE,
    TOWN               VARCHAR2(50) NOT NULL,
    PROVINCE           VARCHAR2(22) NOT NULL,
    TYPE               CHAR(1) NOT NULL,
    TIME               NUMBER(5) default(0) NOT NULL,
    RETURN             DATE
);

--Create trigger for inserting into history tables the data of the user before deleting
create or replace trigger trg_insert_history_tables
before delete on users
for each row
begin
    --Insert into the user_history table the values of the user that is going to be removed
    insert into user_history (USER_ID, ID_CARD, NAME, SURNAME1, SURNAME2, BIRTHDATE, TOWN,
    PROVINCE, ADDRESS, EMAIL, PHONE, TYPE, BAN_UP2) 
    values (:OLD.USER_ID, :OLD.ID_CARD, :OLD.NAME, :OLD.SURNAME1, :OLD.SURNAME2, :OLD.BIRTHDATE, :OLD.TOWN,
    :OLD.PROVINCE, :OLD.ADDRESS, :OLD.EMAIL, :OLD.PHONE, :OLD.TYPE, :OLD.BAN_UP2);
    
    --Insert into loan_history table the loans of the user that is going to be removed
    insert into loan_history (SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME, RETURN)
    select l.signature, l.user_id, l.stopdate, l.town, l.province, l.type, l.time, l.return
    from loans l
    where l.user_id = :OLD.user_id;

    --Delete the loans of the user that is going to be removed
    delete from loans where user_id = :OLD.user_id;
end;
/


