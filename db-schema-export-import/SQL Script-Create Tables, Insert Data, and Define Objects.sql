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
