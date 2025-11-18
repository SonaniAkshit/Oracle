-- ===========================================================
-- analyze_cluster_table_index.sql
-- Create cluster, clustered tables, normal table & index,
-- analyze objects using DBMS_DDL.ANALYZE_OBJECT, and verify.
-- Run as the schema owner (no hard-coded schema name).
-- ===========================================================
SET SERVEROUTPUT ON
SET ECHO ON
SET TIMING ON

PROMPT === 1) Create CLUSTER (if not exists) ===
-- Drop if exists (safe clean-up; ignore errors)
BEGIN
  EXECUTE IMMEDIATE 'DROP CLUSTER emp_dept_cluster';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE CLUSTER emp_dept_cluster (
    deptno NUMBER(5)
)
SIZE 1024;
-- Note: You can specify TABLESPACE clause if needed.

PROMPT === 2) Create INDEX on CLUSTER ===
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX emp_dept_cluster_idx';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX emp_dept_cluster_idx
ON CLUSTER emp_dept_cluster;
-- Creating index on cluster is required for clustered storage access.

PROMPT === 3) Create tables in the cluster ===
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE department PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE employee PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE department (
    deptno NUMBER(5) PRIMARY KEY,
    dname  VARCHAR2(50)
)
CLUSTER emp_dept_cluster (deptno);

CREATE TABLE employee (
    empno   NUMBER(5) PRIMARY KEY,
    ename   VARCHAR2(50),
    deptno  NUMBER(5),
    salary  NUMBER(10,2)
)
CLUSTER emp_dept_cluster (deptno);

PROMPT === 4) Create normal (heap) table and index ===
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE author1 PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE author1 (
    book_id   NUMBER,
    author_id NUMBER,
    title     VARCHAR2(100),
    price     NUMBER(10,2)
)
STORAGE (
    INITIAL     5K
    NEXT        5K
    MINEXTENTS  1
    MAXEXTENTS  5
);

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX author_idx';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX author_idx
ON author1 (author_id);

PROMPT === 5) Insert a few sample rows (optional, helps stats) ===
INSERT INTO department (deptno, dname) VALUES (10, 'ACCOUNTING');
INSERT INTO department (deptno, dname) VALUES (20, 'SALES');
INSERT INTO department (deptno, dname) VALUES (30, 'IT');

INSERT INTO employee (empno, ename, deptno, salary) VALUES (1001, 'Alice', 10, 50000);
INSERT INTO employee (empno, ename, deptno, salary) VALUES (1002, 'Bob',   10, 52000);
INSERT INTO employee (empno, ename, deptno, salary) VALUES (2001, 'Carol', 20, 45000);

INSERT INTO author1 (book_id, author_id, title, price) VALUES (1, 1, 'Intro to Oracle', 299.00);
INSERT INTO author1 (book_id, author_id, title, price) VALUES (2, 2, 'Advanced SQL', 399.00);
COMMIT;

PROMPT === 6) Analyze cluster, tables and indexes using DBMS_DDL.ANALYZE_OBJECT ===
DECLARE
  v_schema VARCHAR2(30) := USER; -- current schema
BEGIN
  -- Analyze the cluster (method 'COMPUTE' used as in your example)
  DBMS_DDL.ANALYZE_OBJECT(type => 'CLUSTER', schema => v_schema, name => 'EMP_DEPT_CLUSTER', method => 'COMPUTE');
  DBMS_OUTPUT.PUT_LINE('Analyzed CLUSTER EMP_DEPT_CLUSTER');

  -- Analyze tables inside cluster
  DBMS_DDL.ANALYZE_OBJECT(type => 'TABLE',   schema => v_schema, name => 'DEPARTMENT', method => 'COMPUTE');
  DBMS_DDL.ANALYZE_OBJECT(type => 'TABLE',   schema => v_schema, name => 'EMPLOYEE',   method => 'COMPUTE');
  DBMS_OUTPUT.PUT_LINE('Analyzed TABLES DEPARTMENT, EMPLOYEE');

  -- Analyze cluster index
  DBMS_DDL.ANALYZE_OBJECT(type => 'INDEX',   schema => v_schema, name => 'EMP_DEPT_CLUSTER_IDX', method => 'COMPUTE');
  DBMS_OUTPUT.PUT_LINE('Analyzed INDEX EMP_DEPT_CLUSTER_IDX');

  -- Analyze normal table and index
  DBMS_DDL.ANALYZE_OBJECT(type => 'TABLE',   schema => v_schema, name => 'AUTHOR1',    method => 'COMPUTE');
  DBMS_DDL.ANALYZE_OBJECT(type => 'INDEX',   schema => v_schema, name => 'AUTHOR_IDX',  method => 'COMPUTE');
  DBMS_OUTPUT.PUT_LINE('Analyzed TABLE AUTHOR1 and INDEX AUTHOR_IDX');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error during ANALYZE: ' || SQLERRM);
    RAISE;
END;
/

PROMPT === 7) Verify table statistics (USER_TABLES) ===
COLUMN table_name FORMAT A20
COLUMN num_rows    FORMAT 999999
COLUMN blocks      FORMAT 999999
COLUMN last_analysed FORMAT A20 HEADING "LAST_ANALYZED"
SELECT table_name, num_rows, blocks, last_analyzed
FROM user_tables
WHERE table_name IN ('DEPARTMENT','EMPLOYEE','AUTHOR1');

PROMPT === 8) Verify index statistics (USER_INDEXES) ===
COLUMN index_name FORMAT A30
COLUMN table_name FORMAT A20
SELECT index_name, table_name, distinct_keys, leaf_blocks, last_analyzed
FROM user_indexes
WHERE index_name IN ('EMP_DEPT_CLUSTER_IDX','AUTHOR_IDX');

PROMPT === 9) Verify cluster statistics (via USER_TAB_STATISTICS or USER_TAB_COL_STATISTICS) ===
-- user_tab_statistics contains combined stats; cluster stats are often seen via tables in cluster
SELECT table_name, num_rows, blocks, last_analyzed
FROM user_tab_statistics
WHERE table_name IN ('DEPARTMENT','EMPLOYEE');

PROMPT === 10) Clean-up notes (optional)
-- To drop created objects, uncomment and run the following (example):
-- DROP INDEX emp_dept_cluster_idx;
-- DROP TABLE employee PURGE;
-- DROP TABLE department PURGE;
-- DROP CLUSTER emp_dept_cluster;
-- DROP INDEX author_idx;
-- DROP TABLE author1 PURGE;

PROMPT === Script complete ===
