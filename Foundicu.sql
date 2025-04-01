--Specification of the package
create or replace package foundicu as 
    procedure insert_loan(l_signature char);
    procedure insert_reservation(isbn_input varchar2,res_date date);
    procedure record_books_ret(in_siganture char);

    current_user varchar2(10);
    procedure set_current_user(p_user varchar2);
    function get_current_user return varchar2;
end;
/

--Package body, that will contain the implementation of the code for the procedures and cursors

create or replace package body foundicu as
    --Complete description of procedure insert_loan
    procedure insert_loan(l_signature char) is 
        --Declare local variables
            v_user_count number;
            v_ban_up2 date;
            v_user_id char(10);
            v_reservation_count number;
            v_loans number;
            v_copy_available number;
            v_loans_count number;
            v_user_town varchar2(50);
            v_user_province varchar2(50);
            v_count_services number;
            v_taskdate date;
            v_hour number;
            v_minutes number;
            v_time number;


        begin
            --Count how many times the user's id is in the table users. If count is 0, raise an exception
            select count(*) into v_user_count from users where user_id = current_user;
            if v_user_count = 0 then
                raise_application_error(-20001, 'Current user not found');
            else
                dbms_output.put_line('User found');
            end if;

            --Store the id of the user and the banned date (if it exists) in local varaibles
            select user_id, ban_up2 into v_user_id, v_ban_up2
            from users
            where user_id = current_user;

            --Check if there is a reservation for that user
            select count(*) into v_reservation_count 
            from loans 
            where signature = l_signature and user_id = v_user_id and type = 'R';

            --If v_reservation_count is bigger than 0, update the type and the stopdate of the loan
            if v_reservation_count > 0 then
                update loans
                set stopdate = sysdate, type = 'L'
                where signature = l_signature and user_id = v_user_id;
                
            --Otherwise, check if there are loans available in two weeks
            else

                --First check if there is a copy available
                select count(*) into v_copy_available
                from copies
                where signature = l_signature;

            if v_copy_available = 0 then
                raise_application_error(-20002, 'Copy not available');
            end if;
            
                --Now check if there are loans for that copy in the span of two weeks from today
                select count(*) into v_loans
                from loans
                where signature = l_signature
                and type = 'L'
                and (
                    ((stopdate between trunc(sysdate) and trunc(sysdate) + 14) and (return is null)) or
                    ((stopdate < trunc(sysdate) or stopdate > (sysdate) + 14) and (return is null))
                );
                
                --If the counter returns a value bigger than 0, this means that the book is loaned and will be loaned within the span of 2 weeks
                if v_loans > 0 then 
                    raise_application_error(-20003, 'Book currently loaned and will be loaned within 2 weeks');
                end if;

                --Now check if the user has reached the maximum amount of loans available and if he/she is banned
                select count(*) into v_loans_count
                from loans
                where user_id = v_user_id;
                --If v_loans_count is bigger than 2, raise an error
                if v_loans_count > 2 then
                    raise_application_error(-20004, 'User has reached the loan limit');
                end if;
                --If the user is banned, raise an error
                if v_ban_up2 is not null and v_ban_up2 > trunc(sysdate) then
                    raise_application_error(-20005, 'The user is banned of using the library services');
                end if;

                --If everything has worked correctly, inserts a new row in the loans table
                --Store in local variables the town and province of the user
                select town, province into v_user_town, v_user_province
                from users
                where user_id = v_user_id;

                --Store in a variable a counter with the services that match the sysdate and take place in the same town and province as the ones the user is in
                select count(*) into v_count_services
                from services
                where town = v_user_town and province = v_user_province and taskdate = trunc(sysdate);

                --If there are no services, then raise an error. Otherwise, continue the execution.
                if v_count_services = 0 then
                    raise_application_error(-20006, 'No services found');
                else
                    select taskdate into v_taskdate
                    from services
                    where town = v_user_town and province = v_user_province and taskdate = trunc(sysdate);
                end if;

                select to_number(to_char(sysdate, 'HH24')) into v_hour 
                from dual;

                select to_number(to_char(sysdate, 'MI')) into v_minutes
                from dual;

                v_time := v_hour * 60 + v_minutes;

                insert into loans(signature, user_id, stopdate, town, province, type, time)
                values (l_signature, v_user_id, v_taskdate, v_user_town, v_user_province, 'L', v_time);
            
            end if;
    end insert_loan;

    --Complete description of insert_reservation procedure
    procedure insert_reservation(isbn_input varchar2, res_date date) is
        --Declaration of local variables
        v_user_id char(10);
        v_ban_up2 date;
        v_user_counter number;
        v_borrow_count number;
        v_loans_2_weeks number;
        v_services date;
        v_user_town varchar2(50);
        v_user_province varchar2(50);
        v_services_counter number;
        v_taskdate date;
        v_isbn_count number;
        v_signature char(5);
        v_time number;

        begin
        --First insert into a local variable the number of times a user appears in table users
        select count(*) into v_user_counter
        from users
        where user_id = current_user;

        --If v_user_count is 0 then raise a mistake. The user is not in the database
        if v_user_counter = 0 then
            raise_application_error(-20007, 'No user found');
        end if;

        select user_id, ban_up2 into v_user_id, v_ban_up2
        from users
        where user_id = current_user;
    

        --Obtain the number of borrowed copies the user has
        select count(*) into v_borrow_count
        from loans
        where user_id = v_user_id;

        --Check the number of borrowed copies has not surpassed the limit
        if v_borrow_count > 2 then
            raise_application_error(-20008, 'The user has reached the limit'); 
        end if;

        if v_ban_up2 is not null and v_ban_up2 > trunc(res_date) then
            raise_application_error(-20009, 'The user is banned of using the library services');
        end if;

        select count(*) into v_isbn_count
        from copies 
        where isbn = isbn_input;

        if v_isbn_count then
            raise_application_error(-20010, 'There is not a copy with the provided isbn');
        end if;

        select signature into v_signature
        from copies
        where isbn = isbn_input;

        --Now check if there are loans for that copy in the span of two weeks from the input date
        select count(*) into v_loans
        from loans
        where signature = v_signature
        and type = 'L'
        and (
            ((stopdate between res_date - 14 and res_date + 14) and (return is null)) or
            ((stopdate < res_date - 14 or stopdate > res_date + 14) and (return is null))
        );
            
        --If the counter returns a value bigger than 0, this means that the book is loaned and will be loaned within the span of 2 weeks
        if v_loans > 0 then 
            raise_application_error(-20011, 'Book currently loaned and will not be loaned within 2 weeks');
        end if;

        select town, province into v_user_town, v_user_province
        from users
        where user_id = user;

        --Select the most recent service available for that user
        select count(*) into v_services_counter
        from services
        where town = v_user_town and province = v_user_province and taskdate >= res_date;

        --If v_services_counter is 0, there are no services available for that town and that province
        if v_services_counter = 0 then
            raise_application_error(-20012, 'No services available');
        end if;

        select taskdate into v_taskdate
            from services
            where town = v_user_town and province = v_user_province and taskdate >= res_date and rownum = 1
            order by taskdate asc;
        
        v_time := to_number(to_char(sysdate, 'HH24')) * 60 + to_number(to_char(sysdate, 'MI'));
        
        --Finally insert into the loans table the new entry
        insert into loans(signature, user_id, stopdate, town, province, type, time)
        values (v_signature, v_user_id, v_taskdate, v_user_town, v_user_province, 'R', v_time);
    end insert_reservation;

    --Complete description of record books retired procedure
    procedure record_books_ret(in_signature char) is
        --Declaration of local variables
        v_user_id char(10);
        v_user_count number;
        v_loans_count number;
        
        begin
        --Count if user is in users table
        select count(*) into v_user_count
        from users
        where user_id = current_user;

        --If v_user_count is 0 then raise an error
        if v_user_count = 0 then
          raise_application_error(-20013, 'Current user not found');
        end if;

        --Check if the user has loaned the book with signature provided
        select count(*) into v_loans_count
        from loans
        where signature = in_signature and user_id = current_user;

        if v_loans_count = 0 then
          raise_application_error(-20014, 'There are no loans for the given copy made by the user');
        end if;

        update loans
        set return = sysdate
        where signature = in_signature and user_id = current_user;
        end record_books_ret;


    -- Replace current user 
    procedure set_current_user(p_user varchar2) is
        begin current_user := p_user; 
    end set_current_user;
    
    -- Retrieve current user
    function get_current_user return varchar2 is begin 
        -- If no user is manually defined, use the predefined one
        if current_user is null then
            return user;
        else 
            return current_user;
        end if;    
    end get_current_user;
end foundicu;
/


