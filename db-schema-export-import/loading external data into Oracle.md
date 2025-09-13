Great 👍 let’s complete this fully. You now have **Export/Import (exp/imp)** with all three levels. Next, let’s cover **loading external data into Oracle** using the three classic methods:

---

# 🔹 Method 1: **SQL\*Loader (sqlldr)**

Best for **bulk loading** data (like CSV, TXT) into Oracle tables.
Needs a **control file** (`.ctl`) to define format.

**Example files:**

📄 `employee.csv`

```csv
101,John,Manager,50000
102,Sarah,Analyst,40000
103,Raj,Clerk,25000
```

📄 `employee.ctl`

```ctl
LOAD DATA
INFILE 'employee.csv'
INTO TABLE EMPLOYEE
FIELDS TERMINATED BY ','
(
  EMPNO,
  ENAME,
  JOB,
  SAL
)
```

📌 Run command:

```bash
sqlldr user01/user01@localhost:1521/xepdb1 control=employee.ctl log=employee.log bad=employee.bad
```

* `control` → control file path
* `log` → log of loaded rows
* `bad` → rejected rows

---

# 🔹 Method 2: **External Tables**

Treats external CSV/TXT file as if it’s a table, without physically loading into DB.

```sql
CREATE TABLE employee_ext (
  empno   NUMBER,
  ename   VARCHAR2(50),
  job     VARCHAR2(50),
  sal     NUMBER
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY data_dir
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY ','
  )
  LOCATION ('employee.csv')
)
REJECT LIMIT UNLIMITED;
```

* `data_dir` → must be created as Oracle directory object:

  ```sql
  CREATE OR REPLACE DIRECTORY data_dir AS '/u01/app/oracle/data';
  GRANT READ, WRITE ON DIRECTORY data_dir TO user01;
  ```

Now query directly:

```sql
SELECT * FROM employee_ext;
```

Or insert into real table:

```sql
INSERT INTO employee SELECT * FROM employee_ext;
```

---

# 🔹 Method 3: **UTL\_FILE with PL/SQL**

Use when you want to **read line by line** and load manually.

```sql
CREATE OR REPLACE DIRECTORY data_dir AS '/u01/app/oracle/data';
GRANT READ, WRITE ON DIRECTORY data_dir TO user01;
```

PL/SQL block:

```sql
DECLARE
  f   UTL_FILE.FILE_TYPE;
  v_line VARCHAR2(200);
  v_empno NUMBER;
  v_ename VARCHAR2(50);
  v_job   VARCHAR2(50);
  v_sal   NUMBER;
BEGIN
  f := UTL_FILE.FOPEN('DATA_DIR', 'employee.csv', 'R');
  LOOP
    BEGIN
      UTL_FILE.GET_LINE(f, v_line);
      -- split by comma
      v_empno := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 1));
      v_ename := REGEXP_SUBSTR(v_line, '[^,]+', 1, 2);
      v_job   := REGEXP_SUBSTR(v_line, '[^,]+', 1, 3);
      v_sal   := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 4));

      INSERT INTO employee (empno, ename, job, sal)
      VALUES (v_empno, v_ename, v_job, v_sal);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN EXIT;
    END;
  END LOOP;
  UTL_FILE.FCLOSE(f);
  COMMIT;
END;
/
```

---

## ✅ Comparison of Methods

| Method             | When to Use                     | Pros                           | Cons                     |
| ------------------ | ------------------------------- | ------------------------------ | ------------------------ |
| **SQL\*Loader**    | Large CSV/TXT bulk loads        | Fast, optimized                | Needs `.ctl` file        |
| **External Table** | Occasional queries on files     | Query directly, no load needed | File must remain on disk |
| **UTL\_FILE**      | Custom parsing, complex formats | Flexible                       | Slower, more coding      |

---

👉 You now have:

* **Export/Import** in 3 modes (Full, Schema, Table).
* **External data loading** in 3 methods (SQL\*Loader, External Tables, UTL\_FILE).

Would you like me to also **tie them together in one workflow**? For example: load CSV → store in Oracle → export that schema → import into another schema. That way you’d see how they all connect.
