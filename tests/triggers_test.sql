/*Test that the first trigger works correctly*/
--Create a user that is a library
alter table users disable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables disable;
alter table posts disable constraint fk_posts_loans;
alter table posts disable constraint ck_posts_dates ;

insert into users(user_id, id_card, name, surname1, birthdate, town, province, address, type, phone) 
values('USER789235', 'ESPA-768594080695', 'Biblioteca Nacional', 'San Esteban', to_date('16-JUN-1905', 'DD-MON-YYYY'), 'San Esteban de las Amapolas', 'Huelva', 'Calle Cristo Rey s/n', 'L', 678676459);

--Check that when a library cannot write a post
exec foundicu.set_current_user('USER789235');
insert into posts(signature, user_id, stopdate, post_date, text, likes, dislikes) values('LSB29', 'USER789235', to_date('24-OCT-2023', 'DD-MON-YYYY'), sysdate, 'Good book overall, but there were many extra pages.', 23, 9);

--Delete and re-enable the constraints and triggers
delete from users where user_id = 'USER789235';
alter table users enable constraint fk_users_municipalities;
alter trigger trg_insert_history_tables enable;
alter table posts enable constraint fk_posts_loans;
alter table posts enable constraint ck_posts_dates ;

/*Create a copy and update it to be deteriorated*/
alter table copies disable constraint fk_copies_editions;
insert into copies(signature, isbn, condition) values('SIGN1', 'ISBN-0001', 'G');

update copies set condition = 'D' where signature = 'SIGN1';

select * from copies where signature = 'SIGN1';

--Delete the test copy and re-enable the constraint
delete from copies where signature = 'SIGN1';
alter table copies enable constraint fk_copies_editions;

/*Check that before deleting a user, his/her data and all the loans assigned to that person are stored in the history tables*/
--0488743850 ESP>>340488743850 Gerardo Oscar                                                                    Gomez                                                                                                                                                             24-AUG-77 Villanieves                                        León                   Road Santa Ines 90, 69742                                                                           , Villanieves                                                                                                                                            555202308 P
delete from users where user_id = '0488743850';

select * from user_history;
select * from loan_history;