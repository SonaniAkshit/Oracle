---------------------------------------------------------------
-- Create STUDENT table
---------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE student PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE student (
    student_id NUMBER PRIMARY KEY,
    name       VARCHAR2(50),
    marks      NUMBER
)
STORAGE (initial 2k next 5k minextents 1 maxextents 5);

---------------------------------------------------------------
-- Create SEQUENCE
---------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE student_seq';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE student_seq
  START WITH 1
  INCREMENT BY 1;

---------------------------------------------------------------
-- Create PROCEDURE executed by DBMS_JOB
---------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_students_job AS
BEGIN
    INSERT INTO student VALUES (student_seq.NEXTVAL, 'Ankesh', 95);
    INSERT INTO student VALUES (student_seq.NEXTVAL, 'Jayesh', 90);
    INSERT INTO student VALUES (student_seq.NEXTVAL, 'Parth',  78);
    INSERT INTO student VALUES (student_seq.NEXTVAL, 'Ram',    92);
    INSERT INTO student VALUES (student_seq.NEXTVAL, 'Krishn', 88);

    COMMIT;
END;
/
SHOW ERRORS;

---------------------------------------------------------------
-- Submit job (RUN ONLY ONE TIME)
---------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    job_no NUMBER;
BEGIN
    DBMS_JOB.SUBMIT(
        job       => job_no,
        what      => 'BEGIN insert_students_job; END;',
        next_date => SYSDATE,
        interval  => NULL           -- NULL = run once
    );
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('One-time job created with JOB ID: ' || job_no);
END;
/
---------------------------------------------------------------
-- Submit job (RUN EVERY DAY)
---------------------------------------------------------------
DECLARE
    job_no NUMBER;
BEGIN
    DBMS_JOB.SUBMIT(
        job       => job_no,
        what      => 'BEGIN insert_students_job; END;',
        next_date => SYSDATE,
        interval  => 'SYSDATE + 1'    -- executes every 24 hours
    );
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Daily job created with JOB ID: ' || job_no);
END;
/

---------------------------------------------------------------
-- View job list (optional)
---------------------------------------------------------------
SELECT job, what, next_date, interval
FROM user_jobs;

---------------------------------------------------------------
-- Check table output
---------------------------------------------------------------
SELECT * FROM student ORDER BY student_id;
