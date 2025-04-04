/*Perform the tests for the first procedure*/
--Test the first error, when the user is not in the database
exec foundicu.set_current_user(user);
exec foundicu.insert_loan('RI645');

--Now provide a valid user. For that, we will create first a new user
alter trigger trg_insert_history_tables disable;
alter table users disable constraint fk_users_municipalities;
insert into users(user_id, id_card, name, surname1, surname2, birthdate, town, province, address, type, phone) 
values('USER100235', 'ESPA-768594032652', 'Jose Maria', 'Gutierrez', 'Hernandez', to_date('29-MAR-1989', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'Avenida del Pepino, 17', 'L', 678678999);

exec foundicu.set_current_user('USER100235');
--Check for the second error, when there are no copies available
exec foundicu.insert_loan('SIGN1');

--Insert into loans an edition the user provided has reserved. First of all, disable the references constraints in loans
alter table loans disable constraint fk_loans_users;
alter table loans disable constraint fk_loans_copies;
alter table loans disable constraint fk_loans_services;
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100235', sysdate, 'Valdepeñas del Iregua', 'Soria', 'R', 0);

exec foundicu.insert_loan('SIGN1');

--Check that it has worked fine
select * from loans where signature = 'SIGN1';

--Delete the inserted loan for making easier the next steps
delete from loans where signature = 'SIGN1';

--Check that there is a loan but it is loaned in the span of 2 weeks. Add also a copy of that signature
alter table copies disable constraint fk_copies_editions;
alter table copies disable constraint ck_condition;
insert into copies(signature, isbn, condition) values('SIGN1', 'ISBN0010', 'G');
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100238', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);

exec foundicu.insert_loan('SIGN1');

delete from copies where signature = 'SIGN1';
delete from loans where signature = 'SIGN1';

--Insert into loans more than 2 copies that the user has loaned

insert into copies(signature, isbn, condition) values('SIGN1', 'ISBN0010', 'G');
insert into copies(signature, isbn, condition) values('SIGN2', 'ISBN0010', 'G');
insert into copies(signature, isbn, condition) values('SIGN3', 'ISBN0010', 'G');

insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN2', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN3', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);

exec foundicu.insert_loan('SIGN1');

delete from copies where signature in ('SIGN1', 'SIGN2', 'SIGN3');
delete from loans where signature in ('SIGN1', 'SIGN2', 'SIGN3');

--Check the error of the user banned from using the services of the library
update users 
set ban_up2 = to_date('10-APR-2025', 'DD-MON-YYYY')
where user_id = 'USER100235';
insert into copies(signature, isbn, condition) values('SIGN1', 'ISBN0010', 'G');
exec foundicu.insert_loan('SIGN1');

update users 
set ban_up2 = null
where user_id = 'USER100235';

--Now check that there are no services available
exec foundicu.insert_loan('SIGN1');

--Now do the case where everything works fine. For that, we have to create a service for that day, town and provice
alter table services disable constraint fk_services_stops;
alter table services disable constraint fk_services_asgn_bus;
alter table services disable constraint fk_services_asgn_drv;

insert into services(town, province, bus, taskdate, passport) values ('Valdepeñas del Iregua', 'Soria', 'BUS00123', trunc(sysdate), 'XDXDXD-1287942687');

exec foundicu.insert_loan('SIGN1');

select * from loans where signature = 'SIGN1';

--After all the tests for the first procedure have been performed, delete all the rows added and re-enable the constraints
delete from loans where signature = 'SIGN1';
delete from services where town = 'Valdepeñas del Iregua';
delete from users where user_id = 'USER100235';
delete from copies where signature = 'SIGN1';
alter table loans enable constraint fk_loans_users;
alter table loans enable constraint fk_loans_copies;
alter table loans enable constraint fk_loans_services;
alter table services enable constraint fk_services_stops;
alter table services enable constraint fk_services_asgn_bus;
alter table services enable constraint fk_services_asgn_drv;
alter table copies enable constraint fk_copies_editions;
alter table copies enable constraint ck_condition;
alter table users enable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables enable;


/*Perform the tests for the second procedure*/
--Test when current user is not in the database
exec foundicu.set_current_user(user);
exec foundicu.insert_reservation('84-242-0333-X', trunc(sysdate));

--Test when the user has reached the borrowing limit
alter table users disable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables disable;
alter table loans disable constraint fk_loans_users;
alter table loans disable constraint fk_loans_copies;
alter table loans disable constraint fk_loans_services;

insert into users(user_id, id_card, name, surname1, surname2, birthdate, town, province, address, type, phone) 
values('USER100235', 'ESPA-768594032652', 'Jose Maria', 'Gutierrez', 'Hernandez', to_date('29-MAR-1989', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'Avenida del Pepino, 17', 'L', 678678999);

insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN2', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN3', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);

exec foundicu.set_current_user('USER100235');
exec foundicu.insert_reservation('84-242-0333-X', trunc(sysdate));

delete from loans where signature in ('SIGN2', 'SIGN3');

--Test when the user is banned of using the library services
update users 
set ban_up2 = to_date('10-APR-2025', 'DD-MON-YYYY')
where user_id = 'USER100235';
exec foundicu.insert_reservation('84-242-0333-X', trunc(sysdate));

update users 
set ban_up2 = null
where user_id = 'USER100235';

--Test when there is not a copy of the input isbn
exec foundicu.insert_reservation('ISBN-01', trunc(sysdate));

--Insert a copy with the isbn valid but all the loans are reserved and will not be available in 2 weeks
alter table copies disable constraint fk_copies_editions;
alter table copies disable constraint ck_condition;

insert into copies(signature, isbn, condition) values('SIGN1', 'ISBN-0001', 'G');

insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100254', to_date('01-MAR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100265', to_date('09-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100278', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);

exec foundicu.insert_reservation('ISBN-0001', trunc(sysdate));

delete from loans where signature = 'SIGN1';

--Test the error when there are no services

exec foundicu.insert_reservation('ISBN-0001', trunc(sysdate));

--Test when everything works fine
alter table services disable constraint fk_services_stops;
alter table services disable constraint fk_services_asgn_bus;
alter table services disable constraint fk_services_asgn_drv;

insert into services(town, province, bus, taskdate, passport) values ('Valdepeñas del Iregua', 'Soria', 'BUS00123', to_date('04-APR-2025', 'DD-MON-YYYY'), 'XDXDXD-1287942687');
insert into services(town, province, bus, taskdate, passport) values ('Valdepeñas del Iregua', 'Soria', 'BUS00123', to_date('08-APR-2025', 'DD-MON-YYYY'), 'XDXDXD-1287942687');
insert into services(town, province, bus, taskdate, passport) values ('Valdepeñas del Iregua', 'Soria', 'BUS00123', to_date('10-APR-2025', 'DD-MON-YYYY'), 'XDXDXD-1287942687');

exec foundicu.insert_reservation('ISBN-0001', trunc(sysdate));

select * from loans where signature = 'SIGN1';

--Delete all the data introduced for testing and re-enable the trigger
delete from loans where signature = 'SIGN1';
delete from services where town = 'Valdepeñas del Iregua';
delete from users where user_id = 'USER100235';
delete from copies where signature = 'SIGN1';
alter table loans enable constraint fk_loans_users;
alter table loans enable constraint fk_loans_copies;
alter table loans enable constraint fk_loans_services;
alter table services enable constraint fk_services_stops;
alter table services enable constraint fk_services_asgn_bus;
alter table services enable constraint fk_services_asgn_drv;
alter table copies enable constraint fk_copies_editions;
alter table copies enable constraint ck_condition;
alter table users enable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables enable;


/*Now test the third procedure*/
--Test when the current user is not in the database
exec foundicu.set_current_user(user);
exec foundicu.record_books_ret('SIGN1');

--Test when there is no loan made by the user with the input provided
alter table users disable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables disable;

insert into users(user_id, id_card, name, surname1, surname2, birthdate, town, province, address, type, phone) 
values('USER100235', 'ESPA-768594032652', 'Jose Maria', 'Gutierrez', 'Hernandez', to_date('29-MAR-1989', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'Avenida del Pepino, 17', 'L', 678678999);

exec foundicu.set_current_user('USER100235');
exec foundicu.record_books_ret('SIGN1');

--Test when everything works fine
alter table loans disable constraint fk_loans_users;
alter table loans disable constraint fk_loans_copies;
alter table loans disable constraint fk_loans_services;
insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100235', to_date('01-MAR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'L', 0);

exec foundicu.record_books_ret('SIGN1');

select * from loans where signature = 'SIGN1';

--Delete all the data introduced for testing
delete from loans where signature = 'SIGN1';
delete from users where user_id = 'USER100235';
alter table loans enable constraint fk_loans_users;
alter table loans enable constraint fk_loans_copies;
alter table loans enable constraint fk_loans_services;
alter table users enable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables enable;