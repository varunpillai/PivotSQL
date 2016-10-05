Rem Our objective:

rem a matrix with all cities as columns and as rows
rem and in the cells the distances between the cities

drop table cities
/

drop table connections
/


set linesize 400


create table cities
( id    number(5)
, name  varchar2(30)
)
/

create table connections
( from_id number(5)
, to_id   number(5)
, distance number(5)
)
/

insert into cities
( id, name)
values
( 1, 'AMSTERDAM')
/
insert into cities
( id, name)
values
( 2, 'UTRECHT')
/
insert into cities
( id, name)
values
( 3, 'THE HAGUE')
/
insert into cities
( id, name)
values
( 4, 'ROTTERDAM')
/

insert into connections
( from_id , to_id , distance )
values
( 1, 2, 25)
/
insert into connections
( from_id , to_id , distance )
values
( 1, 3, 25)
/
insert into connections
( from_id , to_id , distance )
values
( 1, 4, 22)
/
insert into connections
( from_id , to_id , distance )
values
( 2, 3, 45)
/
insert into connections
( from_id , to_id , distance )
values
( 2, 4, 15)
/
insert into connections
( from_id , to_id , distance )
values
( 3, 4, 35)
/

create or replace view city_connections
as
select from_city.name from_city
,      to_city.name   to_city
,      conn.distance  distance
from   cities from_city
,      connections conn
,      cities to_city
where  conn.from_id = from_city.id
and    conn.to_id = to_city.id
union
select from_city.name from_city
,      to_city.name   to_city
,      conn.distance  distance
from   cities from_city
,      connections conn
,      cities to_city
where  conn.to_id = from_city.id
and    conn.from_id = to_city.id
/

set echo on

select *
from   city_connections
/


pause

col from_city format a12
cl scr

select * from table( pivot(  'select * from city_connections' ) )
/

pause

insert into cities
( id, name)
values
( 5, 'NIEUWEGEIN')
/
insert into connections
( from_id , to_id , distance )
values
( 5, 2, 5)
/
pause

select * from table( pivot(  'select *  from city_connections' ) )
/

