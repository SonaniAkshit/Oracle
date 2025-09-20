--check empty blocks in a table
analyze table fragdemo compute statistics;

select table_name, blocks, empty_blocks
from user_tables
where table_name='FRAGDEMO';

--check rows per block
select dbms_rowid.rowid_block_number(rowid) as block_no,
       count(*) as rows_in_block
from fragdemo
group by dbms_rowid.rowid_block_number(rowid)
order by block_no;

--check allocated vs used blocks
with used as (
  select count(distinct dbms_rowid.rowid_block_number(rowid)) as used_blocks
  from fragdemo
),
alloc as (
  select blocks as allocated_blocks
  from user_segments
  where segment_name='FRAGDEMO'
)
select a.allocated_blocks,
       u.used_blocks,
       (a.allocated_blocks - u.used_blocks) as fragmented_blocks
from alloc a, used u;
