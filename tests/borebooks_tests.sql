--Disable constraints and triggers in the tables that we are going to modify
alter table copies disable constraint fk_copies_editions;
alter table copies disable constraint ck_condition;
alter table editions disable constraint uk_editions;
alter table editions disable constraint fk_editions_books;
alter trigger trg_manage_deteriorated disable;

--Insert into the tables values that will ensure us their appearance in the final query
insert into books(title, author) values('Batman vs Superman', 'John Doe');

insert into editions(isbn, title, author, language, national_lib_id) values('ISBN001', 'Batman vs Superman', 'John Doe', 'Spanish', '101');
insert into editions(isbn, title, author, language, national_lib_id) values('ISBN002', 'Batman vs Superman', 'John Doe', 'English', '101');
insert into editions(isbn, title, author, language, national_lib_id) values('ISBN003', 'Batman vs Superman', 'John Doe', 'French', '101');

insert into copies(signature, isbn) values('Sign1', 'ISBN001');
insert into copies(signature, isbn) values('Sign2', 'ISBN002');
insert into copies(signature, isbn) values('Sign3', 'ISBN003');

--Run the query. After that, delete all the new values and re-enable the constraints and triggers

delete from copies where signature in('Sign1', 'Sign2', 'Sign3');
delete from editions where title = 'Batman vs Superman' and author = 'John Doe';
delete from books where title = 'Batman vs Superman' and author = 'John Doe';

alter table copies enable constraint fk_copies_editions;
alter table copies enable constraint ck_condition;
alter table editions enable constraint uk_editions;
alter table editions enable constraint fk_editions_books;
alter trigger trg_manage_deteriorated enable;





