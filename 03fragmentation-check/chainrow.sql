-- drop and recreate table
drop table chain_demo purge;

create table chain_demo (
    id number,
    big_col1 varchar2(4000),
    big_col2 varchar2(4000)
)
tablespace users
storage (initial 10k next 20k pctincrease 0);

-- insert rows larger than block
insert into chain_demo values (1, rpad('x', 4000, 'x'), rpad('y', 4000, 'y'));
insert into chain_demo values (2, rpad('a', 4000, 'a'), rpad('b', 4000, 'b'));
commit;

-- analyze
analyze table chain_demo compute statistics;

select table_name, chain_cnt
from user_tables
where table_name = 'CHAIN_DEMO';

-- solve chaining
create table chain_demo2 (
    id number,
    big_col clob
);

insert into chain_demo2(id, big_col)
select id, big_col1 || big_col2
from chain_demo;
commit;

-- re analyze
analyze table chain_demo2 compute statistics;

select table_name, chain_cnt
from user_tables
where table_name like 'CHAIN_DEMO%';
