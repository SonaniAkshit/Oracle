## 🔹 Objective

Export full schema and Import in the scott schema of the 
database. And also explain each parameter with Export and 
Import. And Load external data into your schema with the help 
of all the three methods

### ©️ Code(Creating objects)

```sql
-- Use your own tablespace names if needed (here: STUD and TEMP)
-- Drop objects first (to avoid conflicts)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE dept CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE emp CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- 1. Create Tables
------------------------------------------------------------
CREATE TABLE dept (
    deptno NUMBER(3) PRIMARY KEY,
    dname  VARCHAR2(30),
    loc    VARCHAR2(30)
)
TABLESPACE users
STORAGE (INITIAL 10K NEXT 20K MAXEXTENTS 3);

CREATE TABLE emp (
    empno   NUMBER(4) PRIMARY KEY,
    ename   VARCHAR2(30),
    job     VARCHAR2(20),
    mgr     NUMBER(4),
    hiredate DATE,
    sal     NUMBER(8,2),
    comm    NUMBER(8,2),
    deptno  NUMBER(3) REFERENCES dept(deptno)
)
TABLESPACE users 
# in clg servers tablespace must be diffrent (stud,student)
STORAGE (INITIAL 10K NEXT 20K MAXEXTENTS 3);

------------------------------------------------------------
-- 2. Insert Sample Data
------------------------------------------------------------
-- Departments
INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH', 'DALLAS');
INSERT INTO dept VALUES (30, 'SALES', 'CHICAGO');
INSERT INTO dept VALUES (40, 'HR', 'BOSTON');

-- Employees (20 rows)
INSERT INTO emp VALUES (1001, 'KING', 'PRESIDENT', NULL, SYSDATE-5000, 5000, NULL, 10);
INSERT INTO emp VALUES (1002, 'BLAKE', 'MANAGER', 1001, SYSDATE-4000, 2850, NULL, 30);
INSERT INTO emp VALUES (1003, 'CLARK', 'MANAGER', 1001, SYSDATE-4100, 2450, NULL, 10);
INSERT INTO emp VALUES (1004, 'JONES', 'MANAGER', 1001, SYSDATE-4200, 2975, NULL, 20);
INSERT INTO emp VALUES (1005, 'SCOTT', 'ANALYST', 1004, SYSDATE-2000, 3000, NULL, 20);
INSERT INTO emp VALUES (1006, 'FORD', 'ANALYST', 1004, SYSDATE-2200, 3000, NULL, 20);
INSERT INTO emp VALUES (1007, 'SMITH', 'CLERK', 1005, SYSDATE-1800, 800, NULL, 20);
INSERT INTO emp VALUES (1008, 'ALLEN', 'SALESMAN', 1002, SYSDATE-2500, 1600, 300, 30);
INSERT INTO emp VALUES (1009, 'WARD', 'SALESMAN', 1002, SYSDATE-2600, 1250, 500, 30);
INSERT INTO emp VALUES (1010, 'MARTIN', 'SALESMAN', 1002, SYSDATE-2700, 1250, 1400, 30);
INSERT INTO emp VALUES (1011, 'TURNER', 'SALESMAN', 1002, SYSDATE-2800, 1500, 0, 30);
INSERT INTO emp VALUES (1012, 'ADAMS', 'CLERK', 1005, SYSDATE-1500, 1100, NULL, 20);
INSERT INTO emp VALUES (1013, 'JAMES', 'CLERK', 1002, SYSDATE-1600, 950, NULL, 30);
INSERT INTO emp VALUES (1014, 'MILLER', 'CLERK', 1003, SYSDATE-1700, 1300, NULL, 10);
INSERT INTO emp VALUES (1015, 'TAYLOR', 'ANALYST', 1004, SYSDATE-1900, 3100, NULL, 20);
INSERT INTO emp VALUES (1016, 'BROWN', 'CLERK', 1002, SYSDATE-1400, 1200, NULL, 30);
INSERT INTO emp VALUES (1017, 'GREEN', 'HR', 1003, SYSDATE-1300, 2000, NULL, 40);
INSERT INTO emp VALUES (1018, 'WHITE', 'HR', 1003, SYSDATE-1200, 2100, NULL, 40);
INSERT INTO emp VALUES (1019, 'BLACK', 'CLERK', 1003, SYSDATE-1100, 1000, NULL, 40);
INSERT INTO emp VALUES (1020, 'GRAY', 'CLERK', 1003, SYSDATE-1000, 1050, NULL, 40);

COMMIT;

------------------------------------------------------------
-- 3. Create Other Oracle Objects
------------------------------------------------------------

-- Sequence
CREATE SEQUENCE emp_seq START WITH 2000 INCREMENT BY 1 NOCACHE;

-- View
CREATE OR REPLACE VIEW emp_view AS
SELECT e.empno, e.ename, e.job, d.dname, d.loc
FROM emp e JOIN dept d ON e.deptno = d.deptno;

-- Synonym
CREATE SYNONYM emp_syn FOR emp;

-- Trigger
CREATE OR REPLACE TRIGGER emp_before_insert
BEFORE INSERT ON emp
FOR EACH ROW
BEGIN
   IF :NEW.empno IS NULL THEN
      SELECT emp_seq.NEXTVAL INTO :NEW.empno FROM dual;
   END IF;
END;
/

-- Procedure
CREATE OR REPLACE PROCEDURE raise_salary(p_empno NUMBER, p_percent NUMBER) IS
BEGIN
   UPDATE emp SET sal = sal + (sal * p_percent/100) WHERE empno = p_empno;
END;
/

-- Function
CREATE OR REPLACE FUNCTION get_dept_name(p_deptno NUMBER) RETURN VARCHAR2 IS
   v_name VARCHAR2(30);
BEGIN
   SELECT dname INTO v_name FROM dept WHERE deptno = p_deptno;
   RETURN v_name;
END;
/

-- Package
CREATE OR REPLACE PACKAGE emp_pkg AS
   PROCEDURE hire_emp(p_name VARCHAR2, p_job VARCHAR2, p_sal NUMBER, p_deptno NUMBER);
   FUNCTION total_emps RETURN NUMBER;
END emp_pkg;
/

CREATE OR REPLACE PACKAGE BODY emp_pkg AS
   PROCEDURE hire_emp(p_name VARCHAR2, p_job VARCHAR2, p_sal NUMBER, p_deptno NUMBER) IS
   BEGIN
      INSERT INTO emp(empno, ename, job, hiredate, sal, deptno)
      VALUES (emp_seq.NEXTVAL, p_name, p_job, SYSDATE, p_sal, p_deptno);
   END;

   FUNCTION total_emps RETURN NUMBER IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*) INTO v_count FROM emp;
      RETURN v_count;
   END;
END emp_pkg;
/
```

### 💡**How to run**

first create it all object in schema

aafter export

## Export:

### **1️⃣ Full Database Export**

```bash
exp system/manager@//localhost:1521/xepdb1 file=full_db.dmp log=full_db_export.log full=y rows=y indexes=y grants=y triggers=y constraints=y compress=n
```

✅ **Notes:**

* Exports the **entire database** (requires DBA privileges).
* Writes dump to the current working directory.
* `compress=n` keeps original extent settings for import.

---

### **2️⃣ Schema-Level Export**

```bash
exp user01/user01@//localhost:1521/xepdb1 file=user01_schema.dmp log=user01_export.log owner=user01 rows=y indexes=y grants=y triggers=y constraints=y
```

✅ **Notes:**

* Exports everything in the **user01** schema (tables, indexes, etc.).
* Works for a normal user.

---

### **3️⃣ Table-Level Export**

```bash
exp user01/user01@//localhost:1521/xepdb1 file=user01_tables.dmp log=user01_tables_export.log tables=(EMP,DEPT) rows=y indexes=y grants=y triggers=y constraints=y
```

✅ **Notes:**

* Exports only the **EMP** and **DEPT** tables (and their metadata).
* Data (`rows=y`) and related objects (indexes, triggers, constraints) are included.

---

## 🧩 **How to run**

### ✅ Step-by-step

1. **Open Command Prompt / Terminal**

   * On Windows: press `Win + R`, type `cmd`, and hit Enter.
   * On Linux/macOS: open your terminal.

2. **Go to the directory where you want the dump file saved**
   Example:

   ```bash
   cd D:\OracleBackups
   ```

3. **Run one of your export commands**

   * **Full Database Export**

     ```bash
     exp system/manager@//localhost:1521/xepdb1 file=full_db.dmp log=full_db_export.log full=y rows=y indexes=y grants=y triggers=y constraints=y compress=n
     ```

   * **Full Database Export(Output)**
        ```bash
        Microsoft Windows [Version 10.0.26200.7019]
        (c) Microsoft Corporation. All rights reserved.

        C:\Users\Admin>d:

        D:\>cd OracleBackup

        D:\OracleBackup>exp system/manager@//localhost:1521/xepdb1 file=full_db.dmp log=full_db_export.log full=y rows=y indexes=y grants=y triggers=y constraints=y compress=n

        Export: Release 21.0.0.0.0 - Production on Fri Oct 31 11:23:21 2025
        Version 21.3.0.0.0

        Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.


        Connected to: Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
        Version 21.3.0.0.0
        Export done in WE8MSWIN1252 character set and AL16UTF16 NCHAR character set
        server uses AL32UTF8 character set (possible charset conversion)

        About to export the entire database ...
        . exporting tablespace definitions
        . exporting profiles
        EXP-00058: Password Verify Function for ORA_CIS_PROFILE profile does not exist
        EXP-00000: Export terminated unsuccessfully

        ```

   * **Schema Export**

     ```bash
     exp user01/user01@//localhost:1521/xepdb1 file=user01_schema.dmp log=user01_export.log owner=user01 rows=y indexes=y grants=y triggers=y constraints=y
     ```
    
    * **Schema Export(output)**
        ```bash
        D:\OracleBackup>exp user01/user01@//localhost:1521/xepdb1 file=user01_schema.dmp log=user01_export.log owner=user01 rows=y indexes=y grants=y triggers=y constraints=y

        Export: Release 21.0.0.0.0 - Production on Fri Oct 31 11:26:02 2025
        Version 21.3.0.0.0

        Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.


        Connected to: Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
        Version 21.3.0.0.0
        Export done in WE8MSWIN1252 character set and AL16UTF16 NCHAR character set
        server uses AL32UTF8 character set (possible charset conversion)
        . exporting pre-schema procedural objects and actions
        . exporting foreign function library names for user USER01
        . exporting PUBLIC type synonyms
        . exporting private type synonyms
        . exporting object type definitions for user USER01
        About to export USER01's objects ...
        . exporting database links
        . exporting sequence numbers
        . exporting cluster definitions
        . about to export USER01's tables via Conventional Path ...
        . . exporting table                           DEPT          4 rows exported
        . . exporting table                            EMP         20 rows exported
        . exporting synonyms
        . exporting views
        . exporting stored procedures
        . exporting operators
        . exporting referential integrity constraints
        . exporting triggers
        . exporting indextypes
        . exporting bitmap, functional and extensible indexes
        . exporting posttables actions
        . exporting materialized views
        . exporting snapshot logs
        . exporting job queues
        . exporting refresh groups and children
        . exporting dimensions
        . exporting post-schema procedural objects and actions
        . exporting statistics
        Export terminated successfully without warnings.

        ```

   * **Table Export**

     ```bash
     exp user01/user01@//localhost:1521/xepdb1 file=user01_tables.dmp log=user01_tables_export.log tables=(EMP,DEPT) rows=y indexes=y grants=y triggers=y constraints=y
     ```
    
    * **Table Export(Output)**
        ```bash
        
        D:\OracleBackup>exp user01/user01@//localhost:1521/xepdb1 file=user01_tables.dmp log=user01_tables_export.log tables=(EMP,DEPT) rows=y indexes=y grants=y triggers=y constraints=y

        Export: Release 21.0.0.0.0 - Production on Fri Oct 31 11:28:36 2025
        Version 21.3.0.0.0

        Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.


        Connected to: Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
        Version 21.3.0.0.0
        Export done in WE8MSWIN1252 character set and AL16UTF16 NCHAR character set
        server uses AL32UTF8 character set (possible charset conversion)

        About to export specified tables via Conventional Path ...
        . . exporting table                            EMP         20 rows exported
        . . exporting table                           DEPT          4 rows exported
        Export terminated successfully without warnings.

        ```

5. **Check the logs**

   * go to your folder(in my case `D:\OracleBackup>`) and check all files.
   * The `.log` file (e.g., `user01_export.log`) will show details of what was exported.
   * The `.dmp` file is your actual backup dump.

---

## Import:

### **1️⃣ Full Database Import**

```bash
imp system/manager@//localhost:1521/xepdb1 file=full_db.dmp log=full_db_import.log full=y ignore=y grants=y indexes=y rows=y constraints=y
```

✅ Notes:

* `full=y` = import everything from dump.
* `ignore=y` = skip “object already exists” errors.
* Requires DBA privileges.

---

### **2️⃣ Schema-Level Import (user01 → user02)**

```bash
imp user02/user02@//localhost:1521/xepdb1 file=user01_schema.dmp log=user01_import.log fromuser=user01 touser=user02 grants=y indexes=y rows=y constraints=y triggers=y ignore=y
```

✅ Notes:

* Imports all objects that belonged to `user01` into `user02`.
* `fromuser=user01` → schema from which data was exported.
* `touser=user02` → schema you’re importing into.
* `ignore=y` lets it skip existing tables.
* `user02` must already exist in the DB with proper privileges (create session, create table, etc.).

---

### **3️⃣ Table-Level Import (user01 → user02)**

```bash
imp user02/user02@//localhost:1521/xepdb1 file=user01_tables.dmp log=user01_tables_import.log fromuser=user01 touser=user02 tables=(EMP,DEPT) grants=y indexes=y rows=y constraints=y triggers=y ignore=y
```

✅ Notes:

* Imports only EMP and DEPT tables.
* Works if the dump file was created from user01 with those tables.
* Again, `fromuser=user01` → source, `touser=user02` → target.

---

## ⚠️ Important

* The **target schema (user02)** must exist **before** you import.

  ```sql
  CREATE USER user02 IDENTIFIED BY user02;
  GRANT CONNECT, RESOURCE TO user02;
  ```
* If you get `IMP-00017: statement failed with ORA-...` → likely permission issue or object already exists.
* You can preview import without writing objects using:

  ```bash
  imp show=y file=user01_schema.dmp
  ```

---

## 🧩 **How to run**

### ✅ Step-by-step

1. **Open Command Prompt / Terminal**

   * On Windows: press `Win + R`, type `cmd`, and hit Enter.
   * On Linux/macOS: open your terminal.

2. **Go to the directory where you want the dump file saved**
   Example:

   ```bash
   cd D:\OracleBackups
   ```

3. **Run one of your import commands**

   * **1️⃣ Full Database Import**

        ```bash
        imp system/manager@//localhost:1521/xepdb1 file=full_db.dmp log=full_db_import.log full=y ignore=y grants=y indexes=y rows=y constraints=y
        ```
    * **1️⃣ Full Database Import(output)**
        ```bash
        D:\OracleBackup> imp system/manager@//localhost:1521/xepdb1 file=full_db.dmp log=full_db_import.log full=y ignore=y grants=y indexes=y rows=y constraints=y

        Import: Release 21.0.0.0.0 - Production on Fri Oct 31 11:38:47 2025
        Version 21.3.0.0.0

        Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.


        Connected to: Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
        Version 21.3.0.0.0

        Export file created by EXPORT:V21.00.00 via conventional path
        import done in WE8MSWIN1252 character set and AL16UTF16 NCHAR character set
        import server uses AL32UTF8 character set (possible charset conversion)
        IMP-00403:

        Warning: This import generated a separate SQL file "full_db_import_sys.sql" which contains DDL that failed due to a privilege issue.

        . importing SYSTEM's objects into SYSTEM
        IMP-00009: abnormal end of export file
        Import terminated successfully with warnings.

        ```
    
    * **2️⃣ Schema-Level Import (user01 → user02)**

        ```bash
        imp user02/user02@//localhost:1521/xepdb1 file=user01_schema.dmp log=user01_import.log fromuser=user01 touser=user02 grants=y indexes=y rows=y constraints=y ignore=y
        ```
    * **2️⃣ Schema-Level Import (user01 → user02)(O/P)**
        ```bash
                
        D:\OracleBackup> imp user02/user02@//localhost:1521/xepdb1 file=user01_schema.dmp log=user01_import.log fromuser=user01 touser=user02 grants=y indexes=y rows=y constraints=y ignore=y

        Import: Release 21.0.0.0.0 - Production on Fri Oct 31 11:42:03 2025
        Version 21.3.0.0.0

        Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.


        Connected to: Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
        Version 21.3.0.0.0

        Export file created by EXPORT:V21.00.00 via conventional path

        Warning: the objects were exported by USER01, not by you

        import done in WE8MSWIN1252 character set and AL16UTF16 NCHAR character set
        import server uses AL32UTF8 character set (possible charset conversion)
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE TYPE "SUBJECT_LIST" TIMESTAMP '2025-09-13:13:24:52' OID '8A0190C02B1"
        "E4C42B7ED7E1A05F2540F'   as table of varchar2(30);"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE TYPE "MARKS_LIST" TIMESTAMP '2025-09-13:13:24:52' OID '25F13B61BB044"
        "1278C0055263FCDCEDB'   as varray(5) of number(3);"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE TYPE "DEPT_OBJ" TIMESTAMP '2025-09-13:13:24:51' OID '55CA9983605E42D"
        "899DEB75CCEF944E0'   as object ("
        "    dept_id     number,"
        "    dept_name   varchar2(50),"
        "    course      varchar2(50)"
        ");"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE TYPE "DEPT_NESTED" TIMESTAMP '2025-09-13:13:24:51' OID 'E3451E599B7D"
        "434F8176E60E08B8E5F6'   as table of dept_obj;"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE SEQUENCE "EMP_SEQ" MINVALUE 1 MAXVALUE 9999999999999999999999999999 "
        "INCREMENT BY 1 START WITH 2000 NOCACHE NOORDER NOCYCLE"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        . . importing table                         "DEPT"          4 rows imported
        . . importing table                          "EMP"         20 rows imported
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE FORCE VIEW "USER02"."EMP_VIEW"                                      "
        "                                                                           "
        "           ("EMPNO","ENAME","JOB","DNAME","LOC") AS "
        "SELECT e.empno, e.ename, e.job, d.dname, d.loc"
        "FROM emp e JOIN dept d ON e.deptno = d.deptno"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE TRIGGER "USER02".emp_before_insert"
        "BEFORE INSERT ON emp"
        "FOR EACH ROW"
        "BEGIN"
        "   IF :NEW.empno IS NULL THEN"
        "      SELECT emp_seq.NEXTVAL INTO :NEW.empno FROM dual;"
        "   END IF;"
        "END;"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        Import terminated successfully with warnings.
        ```
        **Check in schema**
        ```sql
        SQL> show user;
        USER is "USER02"
        SQL> select * from tab;

        TNAME TABTYPE CLUSTERID
        _____ _______ _________
        DEPT  TABLE
        EMP   TABLE

        # user01 --> user02 table dept and emp imported

        select * from emp;

        20 rows selected.

        SQL> select * from dept;

        DEPTNO DNAME      LOC
        ______ __________ ________
            10 ACCOUNTING NEW YORK
            20 RESEARCH   DALLAS
            30 SALES      CHICAGO
            40 HR         BOSTON
        ```
    * **3️⃣ Table-Level Import (user01 → user02)**

        ```bash
        imp user02/user02@//localhost:1521/xepdb1 file=user01_tables.dmp log=user01_tables_import.log fromuser=user01 touser=user02 tables=(EMP,DEPT) grants=y indexes=y rows=y constraints=y ignore=y
        ```
    * **3️⃣ Table-Level Import (user01 → user02)(O/P)**
        ```bash
        D:\OracleBackup> imp user02/user02@//localhost:1521/xepdb1 file=user01_tables.dmp log=user01_tables_import.log fromuser=user01 touser=user02 tables=(EMP,DEPT) grants=y indexes=y rows=y constraints=y ignore=y

        Import: Release 21.0.0.0.0 - Production on Fri Oct 31 11:47:35 2025
        Version 21.3.0.0.0

        Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.


        Connected to: Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
        Version 21.3.0.0.0

        Export file created by EXPORT:V21.00.00 via conventional path

        Warning: the objects were exported by USER01, not by you

        import done in WE8MSWIN1252 character set and AL16UTF16 NCHAR character set
        import server uses AL32UTF8 character set (possible charset conversion)
        . importing USER01's objects into USER02
        . . importing table                          "EMP"
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1001
        Column 2 KING
        Column 3 PRESIDENT
        Column 4
        Column 5 22-FEB-2012:11:15:54
        Column 6 5000
        Column 7
        Column 8 10
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1002
        Column 2 BLAKE
        Column 3 MANAGER
        Column 4 1001
        Column 5 18-NOV-2014:11:15:55
        Column 6 2850
        Column 7
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1003
        Column 2 CLARK
        Column 3 MANAGER
        Column 4 1001
        Column 5 10-AUG-2014:11:15:55
        Column 6 2450
        Column 7
        Column 8 10
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1004
        Column 2 JONES
        Column 3 MANAGER
        Column 4 1001
        Column 5 02-MAY-2014:11:15:55
        Column 6 2975
        Column 7
        Column 8 20
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1005
        Column 2 SCOTT
        Column 3 ANALYST
        Column 4 1004
        Column 5 10-MAY-2020:11:15:56
        Column 6 3000
        Column 7
        Column 8 20
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1006
        Column 2 FORD
        Column 3 ANALYST
        Column 4 1004
        Column 5 23-OCT-2019:11:15:56
        Column 6 3000
        Column 7
        Column 8 20
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1007
        Column 2 SMITH
        Column 3 CLERK
        Column 4 1005
        Column 5 26-NOV-2020:11:15:56
        Column 6 800
        Column 7
        Column 8 20
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1008
        Column 2 ALLEN
        Column 3 SALESMAN
        Column 4 1002
        Column 5 27-DEC-2018:11:15:56
        Column 6 1600
        Column 7 300
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1009
        Column 2 WARD
        Column 3 SALESMAN
        Column 4 1002
        Column 5 18-SEP-2018:11:15:57
        Column 6 1250
        Column 7 500
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1010
        Column 2 MARTIN
        Column 3 SALESMAN
        Column 4 1002
        Column 5 10-JUN-2018:11:15:57
        Column 6 1250
        Column 7 1400
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1011
        Column 2 TURNER
        Column 3 SALESMAN
        Column 4 1002
        Column 5 02-MAR-2018:11:15:57
        Column 6 1500
        Column 7 0
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1012
        Column 2 ADAMS
        Column 3 CLERK
        Column 4 1005
        Column 5 22-SEP-2021:11:15:57
        Column 6 1100
        Column 7
        Column 8 20
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1013
        Column 2 JAMES
        Column 3 CLERK
        Column 4 1002
        Column 5 14-JUN-2021:11:15:58
        Column 6 950
        Column 7
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1014
        Column 2 MILLER
        Column 3 CLERK
        Column 4 1003
        Column 5 06-MAR-2021:11:15:58
        Column 6 1300
        Column 7
        Column 8 10
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1015
        Column 2 TAYLOR
        Column 3 ANALYST
        Column 4 1004
        Column 5 18-AUG-2020:11:15:59
        Column 6 3100
        Column 7
        Column 8 20
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1016
        Column 2 BROWN
        Column 3 CLERK
        Column 4 1002
        Column 5 31-DEC-2021:11:15:59
        Column 6 1200
        Column 7
        Column 8 30
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1017
        Column 2 GREEN
        Column 3 HR
        Column 4 1003
        Column 5 10-APR-2022:11:15:59
        Column 6 2000
        Column 7
        Column 8 40
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1018
        Column 2 WHITE
        Column 3 HR
        Column 4 1003
        Column 5 19-JUL-2022:11:15:59
        Column 6 2100
        Column 7
        Column 8 40
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1019
        Column 2 BLACK
        Column 3 CLERK
        Column 4 1003
        Column 5 27-OCT-2022:11:16:00
        Column 6 1000
        Column 7
        Column 8 40
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008408) violated
        Column 1 1020
        Column 2 GRAY
        Column 3 CLERK
        Column 4 1003
        Column 5 04-FEB-2023:11:16:00
        Column 6 1050
        Column 7
        Column 8 40          0 rows imported
        . . importing table                         "DEPT"
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008407) violated
        Column 1 10
        Column 2 ACCOUNTING
        Column 3 NEW YORK
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008407) violated
        Column 1 20
        Column 2 RESEARCH
        Column 3 DALLAS
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008407) violated
        Column 1 30
        Column 2 SALES
        Column 3 CHICAGO
        IMP-00019: row rejected due to ORACLE error 1
        IMP-00003: ORACLE error 1 encountered
        ORA-00001: unique constraint (USER02.SYS_C008407) violated
        Column 1 40
        Column 2 HR
        Column 3 BOSTON          0 rows imported
        IMP-00017: following statement failed with ORACLE error 1031:
        "CREATE TRIGGER "USER02".emp_before_insert"
        "BEFORE INSERT ON emp"
        "FOR EACH ROW"
        "BEGIN"
        "   IF :NEW.empno IS NULL THEN"
        "      SELECT emp_seq.NEXTVAL INTO :NEW.empno FROM dual;"
        "   END IF;"
        "END;"
        IMP-00003: ORACLE error 1031 encountered
        ORA-01031: insufficient privileges
        Import terminated successfully with warnings.
        ```

## 🔃 **SQL Loader**

### ©️ code:

```sql
create table student_csv (
    student_id      number primary key,
    name            varchar2(50),
    enrolment_no    varchar2(20),
    department      varchar2(50),
    stream          varchar2(50)
)
tablespace users
storage (
    initial 5k
    next 10k
);

sqlldr userid=user01/user01@localhost:1521/xepdb1 control=student_csv.ctl log=student_csv.log


create table student_txt (
    student_id      number primary key,
    name            varchar2(50),
    enrolment_no    varchar2(20),
    department      varchar2(50),
    stream          varchar2(50)
)
tablespace users
storage (
    initial 5k
    next 10k
);

sqlldr userid=user01/user01@localhost:1521/xepdb1 control=student_txt.ctl log=student_txt.log
```

#### important files for above code(control & log files):

file: `student_csv.ctl`

```ctl
load data
infile 'student.csv'
into table student_csv
fields terminated by ',' optionally enclosed by '"'
(
 student_id     integer external,
 name           char,
 enrolment_no   char,
 department     char,
 stream         char
)
```
file: `student_csv.log`

```log

SQL*Loader: Release 21.0.0.0.0 - Production on Wed Sep 17 11:35:07 2025
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.

Control File:   student_csv.ctl
Data File:      student.csv
  Bad File:     student.bad
  Discard File:  none specified
 
 (Allow all discards)

Number to load: ALL
Number to skip: 0
Errors allowed: 50
Bind array:     250 rows, maximum of 1048576 bytes
Continuation:    none specified
Path used:      Conventional

Table STUDENT_CSV, loaded from every logical record.
Insert option in effect for this table: INSERT

   Column Name                  Position   Len  Term Encl Datatype
------------------------------ ---------- ----- ---- ---- ---------------------
STUDENT_ID                          FIRST     *   ,  O(") CHARACTER            
NAME                                 NEXT     *   ,  O(") CHARACTER            
ENROLMENT_NO                         NEXT     *   ,  O(") CHARACTER            
DEPARTMENT                           NEXT     *   ,  O(") CHARACTER            
STREAM                               NEXT     *   ,  O(") CHARACTER            


Table STUDENT_CSV:
  8 Rows successfully loaded.
  0 Rows not loaded due to data errors.
  0 Rows not loaded because all WHEN clauses were failed.
  0 Rows not loaded because all fields were null.


Space allocated for bind array:                 322500 bytes(250 rows)
Read   buffer bytes: 1048576

Total logical records skipped:          0
Total logical records read:             8
Total logical records rejected:         0
Total logical records discarded:        0

Run began on Wed Sep 17 11:35:07 2025
Run ended on Wed Sep 17 11:35:14 2025

Elapsed time was:     00:00:07.05
CPU time was:         00:00:00.25
```

file: `student_txt.ctl`

```ctl
load data
infile 'student.txt'
into table student_txt
fields terminated by '|' optionally enclosed by '"'
(
 student_id     integer external,
 name           char,
 enrolment_no   char,
 department     char,
 stream         char
)
```

file: `student_txt.log`

```log

SQL*Loader: Release 21.0.0.0.0 - Production on Wed Sep 17 11:36:43 2025
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.

Control File:   student_txt.ctl
Data File:      student.txt
  Bad File:     student.bad
  Discard File:  none specified
 
 (Allow all discards)

Number to load: ALL
Number to skip: 0
Errors allowed: 50
Bind array:     250 rows, maximum of 1048576 bytes
Continuation:    none specified
Path used:      Conventional

Table STUDENT_TXT, loaded from every logical record.
Insert option in effect for this table: INSERT

   Column Name                  Position   Len  Term Encl Datatype
------------------------------ ---------- ----- ---- ---- ---------------------
STUDENT_ID                          FIRST     *   |  O(") CHARACTER            
NAME                                 NEXT     *   |  O(") CHARACTER            
ENROLMENT_NO                         NEXT     *   |  O(") CHARACTER            
DEPARTMENT                           NEXT     *   |  O(") CHARACTER            
STREAM                               NEXT     *   |  O(") CHARACTER            


Table STUDENT_TXT:
  10 Rows successfully loaded.
  0 Rows not loaded due to data errors.
  0 Rows not loaded because all WHEN clauses were failed.
  0 Rows not loaded because all fields were null.


Space allocated for bind array:                 322500 bytes(250 rows)
Read   buffer bytes: 1048576

Total logical records skipped:          0
Total logical records read:            10
Total logical records rejected:         0
Total logical records discarded:        0

Run began on Wed Sep 17 11:36:43 2025
Run ended on Wed Sep 17 11:36:44 2025

Elapsed time was:     00:00:00.22
CPU time was:         00:00:00.08

```

### Data Files:

file: `student.csv`

```csv
1,Akshit,001,Computer Science,MCA
2,Ravi,002,Computer Science,BCA
3,Neha,003,Electronics,BTech
4,Amit,004,Mechanical,BE
5,Kiran,005,Civil,BE
6,Divya,006,Information Tech,BSc
7,Vikas,007,Mathematics,MSc
8,Pooja,008,Physics,MSc
```

file: `student.txt`

```txt
1|Akshit|001|Computer Science|MCA
2|Ravi|002|Computer Science|BCA
3|Neha|003|Electronics|BTech
4|Amit|004|Mechanical|BE
5|Kiran|005|Civil|BE
6|Divya|006|Information Tech|BSc
7|Vikas|007|Mathematics|MSc
8|Pooja|008|Physics|MSc
9|Manish|009|Chemistry|MSc
10|Reena|010|Biotechnology|BSc
```

## 🧭 Step-by-Step: How to Run SQL*Loader

### 🧩 1. Folder Setup

Make sure **all files** are in the **same folder** (for simplicity):

```
D:\oracle_loader\
│
├── student_csv.ctl
├── student_csv.log
├── student.csv
├── student_txt.ctl
├── student_txt.log
├── student.txt
```

> Tip: Avoid spaces in folder names.

---

### ⚙️ 2. Confirm Oracle Client is Installed

Open **Command Prompt** and type:

```bash
sqlldr
```

If it shows usage instructions (not “command not found”), SQL*Loader is installed and ready.

If not, add Oracle’s `bin` directory to your PATH, for example:

```bash
set PATH=C:\oracle\product\21c\dbhome_1\bin;%PATH%
```

---

### 🗂️ 3. Create Tables in SQL*Plus

Before loading, make sure your `student_csv` and `student_txt` tables exist.

Run SQL*Plus:

```bash
sqlplus user01/user01@//localhost:1521/xepdb1
```

Then copy-paste and run:

```sql
create table student_csv (
    student_id      number primary key,
    name            varchar2(50),
    enrolment_no    varchar2(20),
    department      varchar2(50),
    stream          varchar2(50)
)
TABLESPACE users
STORAGE (INITIAL 10K NEXT 20K MAXEXTENTS 3);


create table student_txt (
    student_id      number primary key,
    name            varchar2(50),
    enrolment_no    varchar2(20),
    department      varchar2(50),
    stream          varchar2(50)
)
TABLESPACE users
STORAGE (INITIAL 10K NEXT 20K MAXEXTENTS 3);

```

> If they already exist, skip this step.

---

### 🚀 4. Run SQL*Loader Command

Go back to **Command Prompt**, navigate to the folder containing your files:

```bash
cd D:\oracle_loader
```

Then run one of these:

#### ✅ Load CSV File:

```bash
sqlldr userid=user01/user01@//localhost:1521/xepdb1 control=student_csv.ctl log=student_csv.log
```

#### ✅ Load TXT File:

```bash
sqlldr userid=user01/user01@//localhost:1521/xepdb1 control=student_txt.ctl log=student_txt.log
```

---

### 🧾 5. Verify Load Results

After it runs, check the `.log` file (like `student_csv.log`) — it will show:

```
8 Rows successfully loaded.
0 Rows not loaded due to data errors.
```

Then confirm in SQL*Plus:

```sql
SELECT * FROM student_csv;
SELECT * FROM student_txt;
```

You should see all the data rows loaded successfully.

---

### 🧱 6. Common Troubleshooting

| Problem                                   | Likely Cause                    | Fix                                                                  |
| ----------------------------------------- | ------------------------------- | -------------------------------------------------------------------- |
| `SQL*Loader-500: Unable to open file`     | Wrong path or filename          | Use full path like `infile 'D:\oracle_loader\student.csv'` in `.ctl` |
| `ORA-00942: table or view does not exist` | Table not created or wrong user | Make sure the same user owns the table                               |
| `SQL*Loader-350: Syntax error`            | Typo in `.ctl` file             | Check for missing commas or quotes                                   |
| `SQL*Loader-951: Error calling once/load` | Oracle not running              | Start Oracle service or listener                                     |

---