Rem Our objective:

Rem Per Department, an indication for each job how many employees are in that job 
Rem http://technology.amis.nl/blog/?p=1197


select deptno
     , sum( decode( job, 'CLERK', 1 ) ) Clerk
     , sum( decode( job, 'MANAGER', 1 ) ) Manager
     , sum( decode( job, 'SALESMAN', 1 ) ) Salesman
from emp
group by deptno
/

pause

Rem now we would like to have a dynamic pivot, that is: where we do not have to change the query if and when a new job is added

column analyst format  a10
column clerk format  a10
column manager format  a10
column president format  a10



select * from table( pivot(  'select deptno, job, decode (count(1),0,null, count(1)) count_job from emp group by deptno, job' ) )
/

pause

insert into emp
( empno, deptno, job, ename)
values
( 1111, 40, 'SALESMAN', 'JORIS')
/
insert into emp
( empno, deptno, job, ename)
values
( 1112, 30, 'QUIZMSTER', 'ALEX')
/

select * from table( pivot(  'select deptno, job, decode (count(1),0,null, count(1+0)) count_job from emp group by deptno, job' ) )


pause


/

column analyst clear
column clerk clear
column manager clear
column president clear