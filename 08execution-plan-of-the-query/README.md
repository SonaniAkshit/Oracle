# Objective

To produce and analyze execution plans for SQL statements using `EXPLAIN PLAN`, `PLAN_TABLE`, and `DBMS_XPLAN.DISPLAY` / `DBMS_XPLAN.DISPLAY_CURSOR`. The goal is to list every step the optimizer chooses, show the estimated costs and cardinalities, and compare those estimates to actual runtime statistics when possible.

# Purpose

1. Teach how to generate an execution plan before running a statement.
2. Teach how to retrieve the plan stored in `PLAN_TABLE` using `DBMS_XPLAN.DISPLAY`.
3. Show how to capture the actual execution statistics and the real plan in the library cache with `DBMS_XPLAN.DISPLAY_CURSOR`.
4. Help students read each plan row and derive the execution steps, including access paths, joins, filters, and operations order.
5. Enable basic tuning: spot full table scans, index scans, sorts, and high-cost operations.

---

# Explanation of each code block and expected output

### Steps 1–3: Create sample objects and insert data

Purpose: replace dummy/placeholder DDL and give realistic, runnable tables. This ensures `EXPLAIN PLAN` produces meaningful plans. No output besides confirmation messages and number of rows inserted.

### Step 4: Ensure `PLAN_TABLE` exists

`DBMS_XPLAN.CREATE_PLAN_TABLE` creates the `PLAN_TABLE` if the schema does not already have it. `EXPLAIN PLAN` writes into this table by default.

Output: none visible; `PLAN_TABLE` will be present.

### Step 6: `EXPLAIN PLAN SET STATEMENT_ID = '...' FOR <SQL>`

What it does: stores the optimizer’s chosen execution plan into `PLAN_TABLE` with the supplied `statement_id`. It does not run the query. Use a unique `statement_id` per statement to store multiple plans for comparison.

No rows returned by the statement; confirmation text only in SQL*Plus.

### Step 7: `DBMS_XPLAN.DISPLAY(NULL, '<statement_id>', 'ALLSTATS LAST')`

What it does: formats and displays the plan stored in `PLAN_TABLE` for that `statement_id`. The `'ALLSTATS LAST'` option asks for any runtime stats if available, otherwise shows estimates. Output is a readable hierarchical plan: Id, Operation (e.g., TABLE ACCESS FULL), Object name, Predicates, Cost, Cardinality.

Example output (mocked, simplified):

```
--------------------------------------------------------------------------------
Plan hash value: 1234567890

--------------------------------------------------------------------------------
| Id | Operation                     | Name    | Rows  | Bytes | Cost |
--------------------------------------------------------------------------------
|  0 | SELECT STATEMENT              |         |   3   |  300  |   2  |
|  1 |  TABLE ACCESS FULL            | AUTHOR  |   3   |  300  |   2  |
--------------------------------------------------------------------------------
```

Meaning: optimizer chose a full table scan on `AUTHOR`. Estimated cost 2, estimated rows 3.

### Step 8: Run the actual SQL

We run `SELECT * FROM author WHERE author_id = 1;` so that the cursor is loaded into the shared pool and has execution statistics available.

Output: query result rows (the matching author row).

### Step 9: `DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST')`

What it does: displays the execution plan of the last cursor executed in your session, including actual rows processed and real timing if available. This is the authoritative view of what actually happened while the statement ran.

Example output (mocked):

```
--------------------------------------------------------------------------------
SQL_ID  : abcde12345
Plan hash value: 987654321

--------------------------------------------------------------------------------
| Id | Operation                    | Name  | Rows  | Bytes | Cost | Time     |
--------------------------------------------------------------------------------
|  0 | SELECT STATEMENT             |       |     1 |   100 |   2  |00:00:00.01|
|  1 |  TABLE ACCESS BY INDEX ROWID | AUTHOR|     1 |   100 |   2  |00:00:00.01|
|  2 |   INDEX RANGE SCAN           | A_IDX |     1 |       |   1  |00:00:00.01|
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------
   2 - access("AUTHOR"."AUTHOR_ID"=1)
   1 - filter("AUTHOR"."AUTHOR_ID"=1)
```

Interpretation: The optimizer used an index range scan on `A_IDX` (hypothetical index on `author_id`), accessed the table by ROWID and returned 1 row. `ALLSTATS LAST` shows actual rows and elapsed time.

Note: If no index exists, the plan will show `TABLE ACCESS FULL`. If statistics or indexes differ, the plan may change.

### Step 10: `SELECT ... FROM PLAN_TABLE WHERE statement_id = '...' ORDER BY id;`

Why: raw inspection of `PLAN_TABLE` rows helps students see columns like `id`, `operation`, `options`, `object_name`, `cardinality`, `cost`. Use this when building manual derivations or for automation.

Output: plan_table rows like:

| id | operation         | options | object_name | cardinality | cost |
| -- | ----------------- | ------- | ----------- | ----------- | ---- |
| 1  | TABLE ACCESS FULL |         | AUTHOR      | 3           | 2    |

---

# How to derive all steps from an execution plan (process)

1. Read rows ordered by `id`. Lower `id` is child operations executed earlier; top-level `SELECT STATEMENT` is the root. Indentation or `depth` indicates nesting.
2. Identify access paths:

   * `TABLE ACCESS FULL` = full scan
   * `INDEX RANGE SCAN` / `INDEX UNIQUE SCAN` = index usage
   * `TABLE ACCESS BY INDEX ROWID` = index used then table fetch
3. Identify joins:

   * `NESTED LOOPS`, `HASH JOIN`, `MERGE JOIN` show join strategy.
   * Child rows under a join node represent build and probe inputs.
4. Note `Filter`, `Access Predicates`, and `Predicates` sections. These show the WHERE clause filters and how they were applied (index-usable or post-filter).
5. Check `Rows` / `Cardinality` estimates vs `Actual Rows` (from `ALLSTATS LAST` / `DISPLAY_CURSOR`). Large differences are cardinality estimate problems and can cause bad plans.
6. Observe `Cost` for each operation. High-cost operations are candidates for tuning.
7. Review `Predicate Information` at the end for exact column predicates and bind usage.
8. If `DISPLAY_CURSOR` shows runtime stats (IO, CPU), include them in root-cause analysis.

---

# Common things to check when reading plans

* Is the plan using an index when you expect it? If not, check whether statistics exist and whether predicates are selective.
* Are there large `TABLE ACCESS FULL` steps on big tables? Consider indexing or rewriting the query.
* Are there expensive `SORT` or `HASH JOIN` steps? These can indicate memory shortcomings.
* Large mismatch between estimated rows and actual rows. Investigate stale or missing statistics or incorrect histograms.
* For joins, is the join order reasonable? Sometimes rewriting or using hints can help, but better to fix stats or query logic first.

---

# Example conclusions and recommended actions

1. If plan shows `TABLE ACCESS FULL` on a large table but your predicate has a selective equality on a column without index:

   * Create an index on that column or rewrite query.
   * Gather table statistics (`DBMS_STATS.GATHER_TABLE_STATS`) so the optimizer has correct cardinality info.

2. If `DISPLAY_CURSOR` shows actual rows << estimated rows (or vice versa):

   * Fix statistics, consider histograms for skewed data.
   * Investigate functions on columns or implicit conversions that prevent index usage.

3. If plan contains `NESTED LOOPS` with high outer rows and inner index probes:

   * Consider transform to `HASH JOIN` (via hints or optimizer parameters) only after verifying selectivities.

4. If `ALLSTATS LAST` shows heavy IO/time for certain operations:

   * Focus tuning there: indexes, partitioning, materialized views, or rewrite queries.

---

# Quick checklist for students

* Use `EXPLAIN PLAN` to get an estimate without running the statement.
* Use `DBMS_XPLAN.DISPLAY` to print the `PLAN_TABLE` entry.
* Run the actual SQL and then use `DBMS_XPLAN.DISPLAY_CURSOR` to get the real plan and runtime stats.
* Compare estimated vs actual rows first. Fix statistics if estimates are wrong.
* Tune access paths and joins after identifying high-cost operations.

---