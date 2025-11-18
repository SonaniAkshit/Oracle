-- ============================================
-- explain_plan_manual_fixed.sql  (SAFE VERSION)
-- ============================================

-- 1) Clean up previous tables
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE author PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE publisher PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE emp_frag PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 2) Create sample tables
CREATE TABLE author (
    book_id    NUMBER PRIMARY KEY,
    author_id  NUMBER,
    title      VARCHAR2(100),
    price      NUMBER(10,2)
)
storage (initial 10k next 20k minextents 1 maxextents 2);

CREATE TABLE publisher (
    publisher_id NUMBER PRIMARY KEY,
    name         VARCHAR2(100),
    country      VARCHAR2(50)
)
storage (initial 10k next 20k minextents 1 maxextents 2);

CREATE TABLE emp_frag (
    emp_id   NUMBER PRIMARY KEY,
    dept_id  NUMBER,
    name     VARCHAR2(50),
    salary   NUMBER(10,2)
)
storage (initial 10k next 20k minextents 1 maxextents 2);

-- 3) Insert sample data
INSERT INTO author VALUES (1, 1, 'Intro to SQL', 299);
INSERT INTO author VALUES (2, 2, 'Advanced Oracle', 499);
INSERT INTO author VALUES (3, 1, 'PL/SQL Cookbook', 349);
COMMIT;

INSERT INTO publisher VALUES (10, 'Acme Books', 'India');
INSERT INTO publisher VALUES (11, 'Global Press', 'US');
COMMIT;

INSERT INTO emp_frag VALUES (101, 10, 'Aarti', 45000);
INSERT INTO emp_frag VALUES (102, 10, 'Ravi', 48000);
INSERT INTO emp_frag VALUES (103, 20, 'Meena', 52000);
COMMIT;

-- 4) Ensure PLAN_TABLE exists
BEGIN
  DBMS_XPLAN.CREATE_PLAN_TABLE;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 5) Clear old plans
DELETE FROM plan_table;
COMMIT;

-- 6) Explain the queries
EXPLAIN PLAN SET STATEMENT_ID='EP_AUTHOR_ALL'
FOR SELECT * FROM author;

EXPLAIN PLAN SET STATEMENT_ID='EP_AUTHOR_BY_AUTHORID'
FOR SELECT * FROM author WHERE author_id = 1;

EXPLAIN PLAN SET STATEMENT_ID='EP_PUBLISHER_ALL'
FOR SELECT * FROM publisher;

EXPLAIN PLAN SET STATEMENT_ID='EP_EMP_FRAG_SAL'
FOR SELECT emp_id, name FROM emp_frag WHERE salary > 45000;

COMMIT;

-- 7) Manual PLAN_TABLE reader (SAFE – no invalid columns!)
SET LINESIZE 200
SET PAGESIZE 200

COLUMN id FORMAT 999
COLUMN operation FORMAT A30
COLUMN options FORMAT A15
COLUMN object_name FORMAT A25
COLUMN cost FORMAT 9999
COLUMN cardinality FORMAT 99999
COLUMN depth FORMAT 99

SELECT
    LPAD(' ', depth*2) || operation AS operation,
    options,
    object_name,
    cardinality,
    cost,
    id,
    depth,
    parent_id
FROM plan_table
WHERE statement_id = 'EP_AUTHOR_BY_AUTHORID'
ORDER BY id;

-- View all plan ids created
SELECT DISTINCT statement_id FROM plan_table;
