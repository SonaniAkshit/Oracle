create table student_chain (
    student_id number,
    student_name varchar2(2000)
)
tablespace users
storage(initial 10k next 20k);

-- analyze table
analyze table student_chain compute statistics;

select table_name, chain_cnt
from user_tables
where table_name = 'STUDENT_CHAIN';

insert into student_chain(student_id, student_name) values (1, 'Alice');
insert into student_chain(student_id, student_name) values (2, 'Bob');
insert into student_chain(student_id, student_name) values (3, 'Charlie');
insert into student_chain(student_id, student_name) values (4, 'David');
insert into student_chain(student_id, student_name) values (5, 'Emma');
insert into student_chain(student_id, student_name) values (6, 'Frank');
insert into student_chain(student_id, student_name) values (7, 'Grace');
insert into student_chain(student_id, student_name) values (8, 'Hannah');
insert into student_chain(student_id, student_name) values (9, 'Ian');
insert into student_chain(student_id, student_name) values (10, 'Jack');

update student_chain
        set student_name = rpad(student_name, 2000, 'X')
        where student_id = 1;

update student_chain
        set student_name = rpad(student_name, 2000, 'X')
        where student_id = 2;

update student_chain
        set student_name = rpad(student_name, 2000, 'X')
        where student_id = 3;

alter table student_chain add (student_name_clob clob);