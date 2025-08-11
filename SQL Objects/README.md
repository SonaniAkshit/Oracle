## **📚 Full Roadmap – Oracle SQL & SQL\*Plus (Scratch → Advanced)**

---

### **PHASE 1 – Foundations of SQL**

**Goal:** Be able to write basic queries and understand database concepts.
**Topics:**

1. **Introduction to Databases**

   * What is a DB, DBMS, RDBMS
   * Oracle architecture basics (CDB, PDB in 21c)
   * Schema vs user
2. **SQL\*Plus Basics**

   * Connecting to Oracle (`sqlplus`, `conn`, `@service_name`)
   * SQL vs SQL\*Plus commands (`SHOW`, `DESCRIBE`, `COLUMN`, `SET LINESIZE`, etc.)
3. **Basic Data Retrieval**

   * `SELECT`, `FROM`, `WHERE`, `ORDER BY`
   * Aliases (`AS`)
   * Filtering with `BETWEEN`, `IN`, `LIKE`, `IS NULL`
4. **Basic Functions**

   * String: `UPPER`, `LOWER`, `SUBSTR`, `TRIM`
   * Number: `ROUND`, `TRUNC`, `MOD`
   * Date: `SYSDATE`, `ADD_MONTHS`, `MONTHS_BETWEEN`
5. **Basic Operators**

   * Arithmetic (`+ - * /`)
   * Comparison (`=, <, >, !=`)
   * Logical (`AND`, `OR`, `NOT`)

---

### **PHASE 2 – Data Manipulation Language (DML)**

**Goal:** Insert, update, and delete data.
**Topics:**

1. `INSERT`
2. `UPDATE`
3. `DELETE`
4. `MERGE` (UPSERT)
5. Transaction control:

   * `COMMIT`, `ROLLBACK`, `SAVEPOINT`

---

### **PHASE 3 – Data Definition Language (DDL)**

**Goal:** Create and modify database structures.
**Oracle SQL Objects Covered Here:**

1. **Tables**

   * `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`
   * Data types (Oracle-specific: `VARCHAR2`, `NUMBER`, `DATE`, `CLOB`, `BLOB`)
   * Constraints:

     * `PRIMARY KEY`
     * `FOREIGN KEY`
     * `UNIQUE`
     * `NOT NULL`
     * `CHECK`
2. **Sequences**

   * `CREATE SEQUENCE`, `NEXTVAL`, `CURRVAL`
   * Cache & no cache options
3. **Indexes**

   * B-tree index
   * Unique index
   * Composite index
   * Function-based index
4. **Views**

   * Simple view
   * Complex view
   * `WITH CHECK OPTION`, `WITH READ ONLY`
5. **Synonyms**

   * Public & private synonyms
6. **Clusters** (optional, advanced use case in Oracle)

---

### **PHASE 4 – Data Query Mastery**

**Goal:** Be proficient in complex queries.
**Topics:**

1. **Joins**

   * Inner, Left Outer, Right Outer, Full Outer
   * Cross join
   * Self join
   * Oracle proprietary `(+)` outer join syntax
2. **Subqueries**

   * Single-row, multi-row, correlated
   * `EXISTS` vs `IN`
3. **Set Operators**

   * `UNION`, `UNION ALL`, `INTERSECT`, `MINUS`
4. **Grouping & Aggregation**

   * `GROUP BY`, `HAVING`
   * Group functions: `SUM`, `AVG`, `COUNT`, `MAX`, `MIN`
   * `ROLLUP` and `CUBE`
5. **Analytical Functions**

   * `ROWNUM` vs `ROW_NUMBER()`
   * `RANK`, `DENSE_RANK`
   * `LEAD`, `LAG`
   * `PARTITION BY`

---

### **PHASE 5 – User & Security Management**

**Goal:** Manage users, roles, and privileges.
**Topics:**

1. Creating users in a PDB
2. Granting/revoking:

   * System privileges (`CREATE TABLE`)
   * Object privileges (`SELECT ON table_name`)
3. Roles (`CREATE ROLE`, `GRANT role`)
4. Quotas on tablespaces

---

### **PHASE 6 – PL/SQL Basics**

**Goal:** Write procedural code inside Oracle.
**Oracle Objects Covered Here:**

1. **Anonymous Blocks**

   * `DECLARE`, `BEGIN`, `EXCEPTION`, `END`
2. **Variables & Constants**
3. **Control Statements**

   * `IF-THEN-ELSE`
   * Loops (`LOOP`, `FOR`, `WHILE`)
4. **Cursors**

   * Implicit
   * Explicit
5. **Procedures**
6. **Functions**
7. **Packages**
8. **Triggers**
9. **Exception Handling**

---

### **PHASE 7 – Advanced Oracle Features**

**Goal:** Learn optimization, advanced object types, and performance tools.
**Topics:**

1. **Materialized Views**

   * `REFRESH FAST` vs `REFRESH COMPLETE`
2. **Partitioned Tables**
3. **Global Temporary Tables**
4. **Database Links**
5. **Advanced Indexes**

   * Bitmap index
   * Reverse key index
6. **Performance**

   * `EXPLAIN PLAN`
   * Index usage
   * Hints (`/*+ INDEX */`)

---

### **PHASE 8 – SQL\*Plus Advanced Commands**

**Goal:** Get comfortable with Oracle’s CLI environment for scripting.
**Topics:**

1. Formatting output:

   * `COLUMN`, `SET LINESIZE`, `SET PAGESIZE`, `TTITLE`
2. Spooling reports:

   * `SPOOL file_name`
3. Running scripts:

   * `@script.sql`
4. Environment control:

   * `SHOW ALL`
   * `SET FEEDBACK`, `SET SERVEROUTPUT ON`

---