-- 1️⃣ Tablespace Fragmentation

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

-- UNION ALL Both
SELECT tablespace_name,
       num_extents,
       total_mb,
       smallest_extent_mb,
       largest_extent_mb,
       type
FROM (
    SELECT tablespace_name,
           COUNT(*) AS num_extents,
           SUM(bytes)/1024/1024 AS total_mb,
           MIN(bytes)/1024/1024 AS smallest_extent_mb,
           MAX(bytes)/1024/1024 AS largest_extent_mb,
           'ALLOCATED' AS type
    FROM dba_extents
    GROUP BY tablespace_name
    UNION ALL
    SELECT tablespace_name,
           COUNT(*) AS num_extents,
           SUM(bytes)/1024/1024 AS total_mb,
           MIN(bytes)/1024/1024 AS smallest_extent_mb,
           MAX(bytes)/1024/1024 AS largest_extent_mb,
           'FREE' AS type
    FROM dba_free_space
    GROUP BY tablespace_name
)
ORDER BY tablespace_name, type;


-- 2️⃣ Chainrow

drop table student_chain purge;

-- create table
create table student_chain (
    student_id      number,
    student_name    varchar2(20),
    student_address varchar2(4000)
)
tablespace stud
storage(initial 10k next 20k);

-- insert 20 rows
insert into student_chain values (1, 'raj', 'ahmedabad');
insert into student_chain values (2, 'kunal', 'surat');
insert into student_chain values (3, 'manish', 'vadodara');
insert into student_chain values (4, 'ravi', 'bhavnagar');
insert into student_chain values (5, 'rohan', 'jamnagar');
insert into student_chain values (6, 'manan', 'anand');
insert into student_chain values (7, 'vivek', 'mehsana');
insert into student_chain values (8, 'sagar', 'gandhinagar');
insert into student_chain values (9, 'chirag', 'navsari');
insert into student_chain values (10, 'yash', 'junagadh');
insert into student_chain values (11, 'pratik', 'palanpur');
insert into student_chain values (12, 'jay', 'valsad');
insert into student_chain values (13, 'mehul', 'bharuch');
insert into student_chain values (14, 'tushar', 'amreli');
insert into student_chain values (15, 'hiren', 'morbi');
insert into student_chain values (16, 'deep', 'dahod');
insert into student_chain values (17, 'ankit', 'porbandar');
insert into student_chain values (18, 'rahul', 'kutch');
insert into student_chain values (19, 'neel', 'vadnagar');
insert into student_chain values (20, 'kiran', 'palitana');
commit;

-- update 20 rows with padded addresses to create row chaining
update student_chain set student_address = rpad('house no. 12, shree krupa society, near laxmi narayan temple, ashram road, ahmedabad, gujarat, india - 380009. ', 4000, 'x') where student_id = 1;
update student_chain set student_address = rpad('b-504, gokul residency, near iscon temple, sg highway, satellite, ahmedabad, gujarat, india - 380015. ', 4000, 'x') where student_id = 2;
update student_chain set student_address = rpad('jay ambe apartments, flat no. 21, near polytechnic char rasta, ambawadi, ahmedabad, gujarat, india - 380006. ', 4000, 'x') where student_id = 3;
update student_chain set student_address = rpad('shivam complex, 2nd floor, opp. hdfc bank, maninagar east, ahmedabad, gujarat, india - 380008. ', 4000, 'x') where student_id = 4;
update student_chain set student_address = rpad('a-101, shiv residency, near railway station, jamnagar, gujarat, india - 361001. ', 4000, 'x') where student_id = 5;
update student_chain set student_address = rpad('b-202, manan apartments, anand, gujarat, india - 388001. ', 4000, 'x') where student_id = 6;
update student_chain set student_address = rpad('c-303, vivek tower, mehsana, gujarat, india - 384001. ', 4000, 'x') where student_id = 7;
update student_chain set student_address = rpad('d-404, sagar residency, gandhinagar, gujarat, india - 382010. ', 4000, 'x') where student_id = 8;
update student_chain set student_address = rpad('e-505, chirag flats, navsari, gujarat, india - 396445. ', 4000, 'x') where student_id = 9;
update student_chain set student_address = rpad('f-606, yash enclave, junagadh, gujarat, india - 362001. ', 4000, 'x') where student_id = 10;
update student_chain set student_address = rpad('g-707, pratik heights, palanpur, gujarat, india - 385001. ', 4000, 'x') where student_id = 11;
update student_chain set student_address = rpad('h-808, jay apartments, valsad, gujarat, india - 396001. ', 4000, 'x') where student_id = 12;
update student_chain set student_address = rpad('i-909, mehul villa, bharuch, gujarat, india - 392001. ', 4000, 'x') where student_id = 13;
update student_chain set student_address = rpad('j-1010, tushar residency, amreli, gujarat, india - 365601. ', 4000, 'x') where student_id = 14;
update student_chain set student_address = rpad('k-1111, hiren complex, morbi, gujarat, india - 363641. ', 4000, 'x') where student_id = 15;
update student_chain set student_address = rpad('l-1212, deep enclave, dahod, gujarat, india - 389151. ', 4000, 'x') where student_id = 16;
update student_chain set student_address = rpad('m-1313, ankit towers, porbandar, gujarat, india - 360575. ', 4000, 'x') where student_id = 17;
update student_chain set student_address = rpad('n-1414, rahul residency, kutch, gujarat, india - 370001. ', 4000, 'x') where student_id = 18;
update student_chain set student_address = rpad('o-1515, neel flats, vadnagar, gujarat, india - 384355. ', 4000, 'x') where student_id = 19;
update student_chain set student_address = rpad('p-1616, kiran residency, palitana, gujarat, india - 364270. ', 4000, 'x') where student_id = 20;

commit;

-- analyze and check row chain of table
analyze table student_chain compute statistics;

select table_name, chain_cnt
from user_tables
where table_name = 'STUDENT_CHAIN';

-- solve problem
create table student_chain_new (
    student_id      number,
    student_name    varchar2(20),
    student_address clob
)    
tablespace stud
storage(initial 10k next 20k);

-- copy data from old table
insert into student_chain_new(student_id, student_name, student_address)
select student_id, student_name, student_address
from student_chain;

commit;

-- check chaining count
analyze table student_chain_new compute statistics;

select table_name, chain_cnt
from user_tables
where table_name = 'STUDENT_CHAIN_NEW';
