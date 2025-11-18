-- ===================================================================
-- Clean, corrected and well-formatted SQL script
-- Creates package + package body + procedure, checks status, recompiles
-- Run as the schema owner (or change schema => 'MCA36' where needed)
-- ===================================================================

SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON

PROMPT === 1) Create package specification ===
CREATE OR REPLACE PACKAGE emp_pkg IS
    PROCEDURE show_emp(p_empno NUMBER);
END emp_pkg;
/

PROMPT === 2) Create package body (note END emp_pkg; included) ===
CREATE OR REPLACE PACKAGE BODY emp_pkg IS
    PROCEDURE show_emp(p_empno NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Employee no: ' || p_empno);
    END show_emp;
END emp_pkg;
/

PROMPT === 3) Verify package objects exist (spec & body) ===
COLUMN object_name FORMAT A30
COLUMN object_type FORMAT A20
COLUMN status FORMAT A12
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('EMP_PKG','EMP_PKG_BODY')
ORDER BY object_type, object_name;

PROMPT === 4) Recompile PACKAGE BODY using DBMS_DDL.ALTER_COMPILE ===
BEGIN
    DBMS_OUTPUT.PUT_LINE('Recompiling PACKAGE BODY EMP_PKG ...');
    DBMS_DDL.ALTER_COMPILE(
        object_type => 'PACKAGE BODY',
        schema      => USER,         -- use current schema; replace with 'MCA36' if needed
        name        => 'EMP_PKG'
    );
    DBMS_OUTPUT.PUT_LINE('Done: PACKAGE BODY EMP_PKG');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error recompiling PACKAGE BODY EMP_PKG: ' || SQLERRM);
        RAISE;
END;
/

PROMPT === 5) Create standalone procedure ===
CREATE OR REPLACE PROCEDURE emp_proc AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Employee procedure executed successfully!');
END emp_proc;
/

PROMPT === 6) Execute the procedure to test it ===
BEGIN
    emp_proc;
END;
/

PROMPT === 7) Check the procedure status ===
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'EMP_PROC';

PROMPT === 8) Recompile PROCEDURE using DBMS_DDL.ALTER_COMPILE ===
BEGIN
    DBMS_OUTPUT.PUT_LINE('Recompiling PROCEDURE EMP_PROC ...');
    DBMS_DDL.ALTER_COMPILE(
        object_type => 'PROCEDURE',
        schema      => USER,         -- use current schema; replace with 'MCA36' if needed
        name        => 'EMP_PROC'
    );
    DBMS_OUTPUT.PUT_LINE('Done: PROCEDURE EMP_PROC');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error recompiling PROCEDURE EMP_PROC: ' || SQLERRM);
        RAISE;
END;
/

PROMPT === 9) Final status check (spec, body, procedure) ===
SELECT object_name, object_type, status, last_ddl_time
FROM user_objects
WHERE object_name IN ('EMP_PKG','EMP_PKG_BODY','EMP_PROC')
ORDER BY object_type, object_name;

PROMPT === 10) If any object is INVALID, check compile errors (example for EMP_PKG BODY) ===
-- SELECT line, position, text FROM user_errors WHERE name='EMP_PKG' AND type='PACKAGE BODY' ORDER BY sequence;
