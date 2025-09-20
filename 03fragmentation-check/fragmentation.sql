-- create table
drop table fragdemo purge;

create table fragdemo (
    id number,
    name varchar2(100)
)
tablespace users
storage (initial 10k next 20k pctincrease 0);

-- create fragmentation
begin
  for i in 1..1000 loop
    insert into fragdemo values (i, rpad('a',100,'a'));
  end loop;
  commit;
end;
/

-- delete every alternate row
delete from fragdemo where mod(id,2)=0;
commit;

-- analyze fragmentation
analyze table fragdemo compute statistics;
select table_name, blocks, empty_blocks, chain_cnt
from user_tables
where table_name = 'FRAGDEMO';

-- segment analyze
select segment_name, bytes/1024/1024 as mb_allocated, blocks
from user_segments
where segment_name = 'FRAGDEMO';

-- check rows per block
select dbms_rowid.rowid_block_number(rowid) as block_no,
       count(*) as rows_in_block
from fragdemo
group by dbms_rowid.rowid_block_number(rowid)
order by block_no;

-- solve fragmentation
alter table fragdemo move;
alter table fragdemo enable row movement;
alter table fragdemo shrink space;
