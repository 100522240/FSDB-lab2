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

--Test my_reservations view

