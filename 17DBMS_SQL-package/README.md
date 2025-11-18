# Objective

Show how to run a SELECT built at runtime using the `DBMS_SQL` API: open cursor, parse, bind inputs, define output columns, execute, fetch rows, and close the cursor — all with proper error handling.

## Purpose

* Use when SQL text or bind values are not known at compile time.
* Useful for generic utilities, ad-hoc reporting, or schema-level tools that must work with arbitrary queries.
* Demonstrates the low-level DBMS_SQL workflow (required when dynamic SQL needs column-by-column fetch or when using REF CURSORS is not suitable).

## Key steps in the code

1. **OPEN_CURSOR** — get a numeric cursor handle.
2. **PARSE** — compile the SQL statement text in the cursor.
3. **BIND_VARIABLE** — associate PL/SQL variables with placeholders (`:deptno`).
4. **DEFINE_COLUMN** — declare the target variables and sizes for each selected column.
5. **EXECUTE** — run the parsed statement.
6. **FETCH_ROWS** / **COLUMN_VALUE** — iterate and read each column into PL/SQL variables.
7. **CLOSE_CURSOR** — always close the cursor. The script uses exception handling to guarantee closure.
8. **Error handling** — traps exceptions, prints message, closes cursor if open, then re-raises.

## How to run

* Run the script in SQL*Plus or SQL Developer as the table owner (or a user with SELECT on `emp`).
* Change `v_deptno_in` value to test different departments.
* Ensure `SET SERVEROUTPUT ON` is enabled to see DBMS_OUTPUT messages.

## Example output (for v_deptno_in = 10)

```
Row 1 -> Emp No: 101 | Name: ANKESH
Row 2 -> Emp No: 103 | Name: PARTH
Total rows fetched: 2
```

If no rows:

```
No rows found for deptno = 30
```

## Notes & best practices

* For most applications, prefer `EXECUTE IMMEDIATE` or typed `REF CURSOR`s for simpler dynamic SQL needs.
* Use `DBMS_SQL` when you need to:

  * Fetch an unknown number of columns or unknown types at runtime,
  * Work with DDL statements programmatically,
  * Bind an arbitrary list of values or handle dynamic result sets column-by-column.
* Always close DBMS_SQL cursors (use `DBMS_SQL.IS_OPEN` to check).
* Watch for SQL injection — never concatenate untrusted input into `v_query`; use bind variables as shown.
