-- dynamic_dbms_sql_emp.sql
-- Demonstrates dynamic SQL with DBMS_SQL (open/parse/bind/define/execute/fetch/close)
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON

-- Prepare sample table/data (run once if not present)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE emp PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE emp (
    empno  NUMBER,
    ename  VARCHAR2(50),
    deptno NUMBER
)
STORAGE (initial 1k next 10k minextents 1 maxextents 5);

INSERT INTO emp (empno, ename, deptno) VALUES (101, 'ANKESH', 10);
INSERT INTO emp (empno, ename, deptno) VALUES (102, 'JAYESH', 20);
INSERT INTO emp (empno, ename, deptno) VALUES (103, 'PARTH', 10);
COMMIT;

-- =========================
-- Dynamic query using DBMS_SQL
-- =========================
DECLARE
    v_cursor_id    PLS_INTEGER;           -- DBMS_SQL cursor handle
    v_query        VARCHAR2(4000);        -- dynamic SQL text
    v_deptno_in    NUMBER := 10;         -- input deptno (change as needed)
    v_empno        NUMBER;               -- output column 1
    v_ename        VARCHAR2(50);         -- output column 2
    v_rows         INTEGER := 0;         -- fetched row counter
    v_status       INTEGER;
BEGIN
    -- Build SQL dynamically (bind placeholder used)
    v_query := 'SELECT empno, ename FROM emp WHERE deptno = :deptno ORDER BY empno';

    -- Open a new DBMS_SQL cursor
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;

    -- Parse the SQL statement (NATIVE uses the current SQL engine)
    DBMS_SQL.PARSE(v_cursor_id, v_query, DBMS_SQL.NATIVE);

    -- Bind the input variable to the placeholder
    DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':deptno', v_deptno_in);

    -- Define the columns to fetch: numeric + varchar
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_empno);        -- NUMBER column
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_ename, 50);    -- VARCHAR2 column (length specified)

    -- Execute the statement
    v_status := DBMS_SQL.EXECUTE(v_cursor_id);

    -- Fetch loop
    LOOP
        EXIT WHEN DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0;
        v_rows := v_rows + 1;

        -- Retrieve column values into variables
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_empno);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_ename);

        -- Output the row
        DBMS_OUTPUT.PUT_LINE('Row ' || v_rows || ' -> Emp No: ' || v_empno || ' | Name: ' || v_ename);
    END LOOP;

    IF v_rows = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No rows found for deptno = ' || v_deptno_in);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total rows fetched: ' || v_rows);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Ensure cursor is closed even on error
        IF DBMS_SQL.IS_OPEN(v_cursor_id) = 1 THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/
