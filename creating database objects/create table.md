**1. Create a sequence**
First, a sequence will be created to generate unique product IDs. 

```sql
 create sequence p_id_seq
    increment by 1
    minvalue 1
    maxvalue 10
    start with 1;
```

**Find your tablespace**
```sql
 select DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE from user_users;

DEFAULT_TABLESPACE             TEMPORARY_TABLESPACE
------------------------------ ------------------------------
USERS                          TEMP
```

**2. Create the products table**
```sql 

CREATE TABLE products (
    p_id          NUMBER(10) PRIMARY KEY,
    p_name        VARCHAR2(100) NOT NULL,
    price               NUMBER(10, 2) NOT NULL,
    stock     NUMBER(10) NOT NULL
)
tablespace users
storage(
    initial 10k
    next 20k
    minextents 1
    maxextents 3
);

```

- TABLESPACE users: This specifies the tablespace where the table's data will be physically stored. A tablespace is a logical storage unit within a database.

- STORAGE (...): This is the storage clause, which is used in Oracle databases to control how space is allocated for the table.

**The STORAGE Clause Properties**

The STORAGE clause defines the physical storage parameters for the table. Here is a breakdown of each property:

- INITIAL 10k: This is the size of the first extent (a contiguous block of disk space) that the database allocates for the table when it is first created. In this case, it allocates 10 kilobyte.

- NEXT 20K: This is the size of the second extent and all subsequent extents that are allocated to the table when more space is needed. In this case, each new extent will be 20 kilobytes.

- MINEXTENTS 1: This specifies the minimum number of extents to be allocated for the table at creation. The table will always have at least one extent.

- MAXEXTENTS 3: This sets the 3 number of extents that the database can allocate for the table. 3 means the database can continue to add extents as needed until it hits a 3 limit or runs out of disk space.

**3. insert records on product table**

###### method 1:

```sql
INSERT INTO products VALUES (p_id_seq.NEXTVAL, 'Laptop Pro X', 'Powerful laptop for professionals.', 1200.00, 50);

```
###### method 2:

```sql 
insert into products values(p_id_seq.nextval,'&p_name',&price,&stock);
```

```
ERROR at line 1:
ORA-01950: no privileges on tablespace 'USERS'
```

```sql
CONNECT sys/your_sys_password AS SYSDBA;
-- Or: CONNECT system/your_system_password;
```

```sql
show pdbs;
```
```
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 XEPDB1                         READ WRITE NO
```
```sql
alter session set container='xepdb1';
```
```sql
ALTER USER extrauser QUOTA 100M ON USERS;
```

then insert

```sql
old   1: insert into products values(p_id_seq.nextval,'&p_name',&price,&stock)
new   1: insert into products values(p_id_seq.nextval,'dell latitude 5400',36000,20)

1 row created.
```

```sql
select * from products;
```