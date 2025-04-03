--Try to modify my_data to check that it is read only
exec foundicu.set_current_user('9249616071');

update my_data set name = 'Julio Cesar Chavez' where user_id = '9249616071';
insert into my_data(name, town) values('Paquito el Chocolatero', 'Matalascañas');
delete from my_data where user_id = '9249616071';

--Test my_loans view
select * from my_loans;
--Try modifying the text
update my_loans
set text = 'Good book, but I wanted more action.'
where signature = 'XI817';

insert into my_loans(text) values('But in which chapter the main character dies?');
delete from my_loans where signature = 'XI817';

--Test my_reservations view. For that we will create a new user a new copies and loans
alter table users disable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables disable;
alter table loans disable constraint fk_loans_users;
alter table loans disable constraint fk_loans_copies;
alter table loans disable constraint fk_loans_services;
alter table copies disable constraint fk_copies_editions;
alter table copies disable constraint ck_condition;

insert into users(user_id, id_card, name, surname1, surname2, birthdate, town, province, address, type, phone) 
values('USER100235', 'ESPA-768594032652', 'Jose Maria', 'Gutierrez', 'Hernandez', to_date('29-MAR-1989', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'Avenida del Pepino, 17', 'L', 678678999);

insert into loans(signature, user_id, stopdate, town, province, type, time) values('SIGN1', 'USER100235', to_date('01-APR-2025', 'DD-MON-YYYY'), 'Valdepeñas del Iregua', 'Soria', 'R', 0);

insert into copies(signature, isbn, condition) values('SIGN1', 'ISBN-0001', 'G');
--Change current user for the one that we have just created
exec foundicu.set_current_user('USER100235');

--Try to see that the view has been created correctly
select * from my_reservations;

--Test when trying to insert data
insert into my_reservations(signature, stopdate, town, province, time, type, return)
values('SIGN2', sysdate, 'Aldeanueva de Los Ramos', 'Jaén', 7908, 'R', null);

select * from loans where signature = 'SIGN2';

--Test when trying to update data
update my_reservations set stopdate = to_date('12-MAR-2026', 'DD-MON-YYYY'), return = to_date('29-MAR-2026', 'DD-MON-YYYY') where signature = 'SIGN1';

select * from loans where signature = 'SIGN1';

--Test when deleting data
delete from my_reservations where signature = 'SIGN1';
select * from loans where signature = 'SIGN1';

--Delete the introduced data and re-enable the constraints

delete from loans where signature in ('SIGN1', 'SIGN2');
delete from users where user_id = 'USER100235';
delete from copies where signature = 'SIGN1';

alter table loans enable constraint fk_loans_users;
alter table loans enable constraint fk_loans_copies;
alter table loans enable constraint fk_loans_services;
alter table copies enable constraint fk_copies_editions;
alter table copies enable constraint ck_condition;
alter table users enable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables enable;