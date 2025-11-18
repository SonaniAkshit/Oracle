# Objective

Show how to create a simple PL/SQL package and a standalone procedure, check their status, and recompile them using the `DBMS_DDL.ALTER_COMPILE` API. The script demonstrates both targeted recompilation and safe checks so you can validate and fix invalid objects in your schema.

## Purpose

* Teach how to deploy package/spec + package body and a procedure.
* Show how to verify object status via `USER_OBJECTS`.
* Demonstrate programmatic recompilation using `DBMS_DDL.ALTER_COMPILE`.
* Provide a minimal test to confirm objects execute correctly.
* Give a process you can use in exams or quick maintenance tasks to restore invalid objects.

---

## Prerequisites

* Run the script as the schema owner (or change `schema => 'MCA36'` to the target schema).
* `EXECUTE` privilege on `DBMS_DDL` is normally available to the schema owner.
* Use SQL*Plus, SQL Developer, or another client that supports `SET SERVEROUTPUT ON`.

---

## How to run

1. Save the SQL script (from the previous message) as `recompile_emp_objects.sql`.
2. Connect as the target schema: `sqlplus user/pass@db` (or `sqlplus / as sysdba` if appropriate).
3. Run: `@recompile_emp_objects.sql`.
4. Watch `DBMS_OUTPUT` messages and the `USER_OBJECTS` queries for object status.

---

## What the script does — block-by-block explanation

### 1. Setup: server output and timing

```sql
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON
```

Enables `DBMS_OUTPUT.PUT_LINE` so the script can print progress messages and enables timing for commands (handy in manual runs).

---

### 2. Create package specification

```sql
CREATE OR REPLACE PACKAGE emp_pkg IS
    PROCEDURE show_emp(p_empno NUMBER);
END emp_pkg;
/
```

Defines the package interface (spec). This declares `show_emp` so other code can call it. `CREATE OR REPLACE` safely replaces any existing spec.

---

### 3. Create package body

```sql
CREATE OR REPLACE PACKAGE BODY emp_pkg IS
    PROCEDURE show_emp(p_empno NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Employee no: ' || p_empno);
    END show_emp;
END emp_pkg;
/
```

Implements the procedure declared in the spec. Note the explicit `END show_emp;` — good style and exam-friendly. The package body writes a message to server output.

---

### 4. Verify package objects exist

```sql
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('EMP_PKG','EMP_PKG_BODY')
ORDER BY object_type, object_name;
```

Checks `USER_OBJECTS` for both the package spec (`PACKAGE`) and the package implementation (`PACKAGE BODY`). `STATUS` shows `VALID` or `INVALID`.

---

### 5. Recompile PACKAGE BODY via DBMS_DDL

```plsql
BEGIN
    DBMS_OUTPUT.PUT_LINE('Recompiling PACKAGE BODY EMP_PKG ...');
    DBMS_DDL.ALTER_COMPILE(
        object_type => 'PACKAGE BODY',
        schema      => USER,
        name        => 'EMP_PKG'
    );
    DBMS_OUTPUT.PUT_LINE('Done: PACKAGE BODY EMP_PKG');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error recompiling PACKAGE BODY EMP_PKG: ' || SQLERRM);
        RAISE;
END;
/
```

Uses `DBMS_DDL.ALTER_COMPILE` to force a compilation of the package body. `schema => USER` uses the current schema — replace it with a literal schema name only if you must recompile objects in another schema. Errors are caught and printed (then re-raised), so you both see and don’t silently ignore failures.

---

### 6. Create standalone procedure

```sql
CREATE OR REPLACE PROCEDURE emp_proc AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Employee procedure executed successfully!');
END emp_proc;
/
```

A simple procedure to demonstrate creating and running a standalone object.

---

### 7. Execute the procedure (test)

```plsql
BEGIN
    emp_proc;
END;
/
```

Runs `emp_proc` so you can confirm it works. Output appears via `DBMS_OUTPUT`.

---

### 8. Check the procedure status

```sql
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'EMP_PROC';
```

Confirm the procedure is `VALID`. If it’s `INVALID`, there will be compilation errors to inspect.

---

### 9. Recompile PROCEDURE using DBMS_DDL

```plsql
BEGIN
    DBMS_OUTPUT.PUT_LINE('Recompiling PROCEDURE EMP_PROC ...');
    DBMS_DDL.ALTER_COMPILE(
        object_type => 'PROCEDURE',
        schema      => USER,
        name        => 'EMP_PROC'
    );
    DBMS_OUTPUT.PUT_LINE('Done: PROCEDURE EMP_PROC');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error recompiling PROCEDURE EMP_PROC: ' || SQLERRM);
        RAISE;
END;
/
```

Same pattern as package body recompilation. Use it whenever the object status becomes `INVALID` or you changed dependent objects.

---

### 10. Final status check and error diagnostics

```sql
SELECT object_name, object_type, status, last_ddl_time
FROM user_objects
WHERE object_name IN ('EMP_PKG','EMP_PKG_BODY','EMP_PROC')
ORDER BY object_type, object_name;
```

Shows final `VALID`/`INVALID` states and last DDL time. If any object is `INVALID`, see compilation errors:

```sql
SELECT line, position, text
FROM user_errors
WHERE name = 'EMP_PKG' AND type = 'PACKAGE BODY'
ORDER BY sequence;
```

`USER_ERRORS` contains the compilation errors and line/position to fix the code.

---

## Expected output

* `DBMS_OUTPUT` lines showing “Recompiling ...” and “Done ...” messages.
* `USER_OBJECTS` rows with `STATUS = VALID` after successful compilation.
* When executing `emp_proc` and `emp_pkg.show_emp`, you should see the text printed to server output:

  ```
  Employee procedure executed successfully!
  Employee no: 123
  ```

---

## Troubleshooting

* **Object remains INVALID after recompile**: run the `USER_ERRORS` query to see compile errors and fix code.
* **Insufficient privileges**: if running as a different user, you may lack `EXECUTE` on `DBMS_DDL` or lack rights to alter objects in another schema. Re-run as the schema owner or use a privileged account.
* **Schema name mismatch**: script uses `USER` to refer to the current schema. If you must target another schema, replace `USER` with the literal schema name (e.g., `'MCA36'`), but do that only if you have the privileges.

---

## Exam tips (concise)

* Know the difference between `PACKAGE` and `PACKAGE BODY`. Both appear in `USER_OBJECTS`.
* `DBMS_DDL.ALTER_COMPILE(object_type, schema, name)` is used to recompile programmatically. `object_type` must exactly match `USER_OBJECTS.OBJECT_TYPE` (e.g., `'PACKAGE BODY'`).
* Use `USER_ERRORS` to view compile errors.
* Use `SET SERVEROUTPUT ON` to read `DBMS_OUTPUT` messages during tests.
* Prefer `CREATE OR REPLACE` to safely update code during labs or exams.

---