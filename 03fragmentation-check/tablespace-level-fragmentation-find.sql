-- dba_free_space
select tablespace_name,
       sum(bytes)/1024/1024 as free_mb,
       count(*) as free_extents
from dba_free_space
group by tablespace_name
order by tablespace_name;

select tablespace_name,
       max(bytes)/1024/1024 as largest_free_extent_mb
from dba_free_space
group by tablespace_name;

-- dba_extents
select tablespace_name,
       count(*) as total_extents,
       sum(bytes)/1024/1024 as total_size_mb,
       min(bytes)/1024/1024 as smallest_extent_mb,
       max(bytes)/1024/1024 as largest_extent_mb
from dba_extents
group by tablespace_name
order by tablespace_name;

-- check free space on tablespace level
select distinct *
from (
    select  tablespace_name,
           count(*) as num_extents,
           sum(bytes)/1024/1024 as total_mb,
           min(bytes)/1024/1024 as smallest_extent_mb,
           max(bytes)/1024/1024 as largest_extent_mb,
           'ALLOCATED' as type
    from dba_extents
    group by tablespace_name

    union all

    select tablespace_name,
           count(*) as num_extents,
           sum(bytes)/1024/1024 as total_mb,
           min(bytes)/1024/1024 as smallest_extent_mb,
           max(bytes)/1024/1024 as largest_extent_mb,
           'FREE' as type
    from dba_free_space
    group by tablespace_name
)
order by tablespace_name, type;

-- fix tablespace fragmentation
alter tablespace users coalesce;
