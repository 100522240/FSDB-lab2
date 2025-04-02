--Disable constraints for making easier the in
alter table assign_drv disable constraint fk_assign_drv_drivers;
alter table assign_drv disable constraint fk_assign_drv_routes;
alter table services disable constraint fk_services_stops;
alter table services disable constraint fk_services_asgn_bus;
alter table services disable constraint fk_services_asgn_drv;
alter table loans disable constraint fk_loans_users;
alter table loans disable constraint fk_loans_copies;
alter table loans disable constraint fk_loans_services;

--Insert values that will differ on the default values
insert into drivers(passport, email, fullname, birthdate, phone, address, cont_start)
values('ABCDEFGHI98767812', 'JohnJones@hotmail.ru', 'John Jones Gutierrez', to_date('20-MAR-1968', 'DD-MON-YYYY'), 666633333, 'Avenida de las rosas, Huesca', to_date('10-FEB-2019', 'DD-MON-YYYY'));

insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('13-MAR-2019', 'DD-MON-YYYY'));
insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('28-MAR-2019', 'DD-MON-YYYY'));
insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('02-SEP-2019', 'DD-MON-YYYY'));
insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('28-NOV-2019', 'DD-MON-YYYY'));
insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('13-MAR-2021', 'DD-MON-YYYY'));
insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('20-JUN-2021', 'DD-MON-YYYY'));
insert into assign_drv(passport, taskdate) values('ABCDEFGHI98767812', to_date('14-FEB-2023', 'DD-MON-YYYY'));

insert into services(town, province, bus, taskdate, passport) values('Alcolea del Monte', 'Huesca', 'BUS0001', to_date('13-MAR-2019', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');
insert into services(town, province, bus, taskdate, passport) values('Alcolea del Pinar', 'Teruel', 'BUS0014', to_date('28-MAR-2019', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');
insert into services(town, province, bus, taskdate, passport) values('Sotomontes del Piquillo', 'Huesca', 'BUS0022', to_date('02-SEP-2019', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');
insert into services(town, province, bus, taskdate, passport) values('Agoncillo', 'La Rioja', 'BUS0014', to_date('28-NOV-2019', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');
insert into services(town, province, bus, taskdate, passport) values('Villarroya de Abajo', 'Guadalajara', 'BUS0130', to_date('13-MAR-2021', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');
insert into services(town, province, bus, taskdate, passport) values('Villarroya de Arriba', 'Guadalajara', 'BUS1908', to_date('20-JUN-2021', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');
insert into services(town, province, bus, taskdate, passport) values('Alcázar del Duero', 'Navarra', 'BUS0014', to_date('14-FEB-2023', 'DD-MON-YYYY'), 'ABCDEFGHI98767812');

insert into loans(signature, stopdate, user_id, town, province, type, time, return) values('SIGN1', to_date('13-MAR-2019', 'DD-MON-YYYY'), 'IDMON90874', 'Alcolea del Monte', 'Huesca', 'L', 4590, to_date('13-NOV-2019', 'DD-MON-YYYY'));
insert into loans(signature, stopdate, user_id, town, province, type, time, return) values('SIGN2', to_date('28-MAR-2019', 'DD-MON-YYYY'),'IDMON90874', 'Alcolea del Pinar', 'Teruel', 'L', 7800, to_date('10-DEC-2019', 'DD-MON-YYYY'));
insert into loans(signature, stopdate, user_id, town, province, type, time, return) values('SIGN3', to_date('02-SEP-2019', 'DD-MON-YYYY'), 'IDMON90874', 'Sotomontes del Piquillo', 'Huesca', 'L', 6870, to_date('13-NOV-2019', 'DD-MON-YYYY'));
insert into loans(signature, stopdate, user_id, town, province, type, time, return) values('SIGN4', to_date('28-NOV-2019', 'DD-MON-YYYY'), 'IDMON90874', 'Agoncillo', 'La Rioja', 'L', 4590, to_date('13-DEC-2019', 'DD-MON-YYYY'));
insert into loans(signature, stopdate, user_id, town, province, type, time, return) values('SIGN5', to_date('13-MAR-2021', 'DD-MON-YYYY'), 'IDMON90874', 'Villarroya de Abajo', 'Guadalajara', 'L', 780, to_date('17-MAR-2021', 'DD-MON-YYYY'));
insert into loans(signature, stopdate, user_id, town, province, type, time, return) values('SIGN6', to_date('20-JUN-2021', 'DD-MON-YYYY'), 'IDMON90874', 'Villarroya de Arriba', 'Guadalajara', 'L', 780, to_date('29-NOV-2021', 'DD-MON-YYYY'));
insert into loans(signature, stopdate, user_id, town, province, type, time) values('SIGN7', to_date('14-FEB-2023', 'DD-MON-YYYY'), 'IDMON90874', 'Alcázar del Duero', 'Navarra', 'L', 4590);

--Run the query. Then delete all the tables that were created
delete from loans where signature in ('SIGN1', 'SIGN2', 'SIGN3', 'SIGN4', 'SIGN5', 'SIGN6', 'SIGN7');
delete from services where passport = 'ABCDEFGHI98767812';
delete from assign_drv where passport = 'ABCDEFGHI98767812';
delete from drivers where passport = 'ABCDEFGHI98767812';

--Re-enable the constraints
alter table loans enable constraint fk_loans_users;
alter table loans enable constraint fk_loans_copies;
alter table loans enable constraint fk_loans_services;
alter table services enable constraint fk_services_stops;
alter table services enable constraint fk_services_asgn_bus;
alter table services enable constraint fk_services_asgn_drv;
alter table assign_drv enable constraint fk_assign_drv_drivers;
alter table assign_drv enable constraint fk_assign_drv_routes;


