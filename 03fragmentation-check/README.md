# Oracle Fragmentation Analysis — README

## Objective

Write at least three queries to find fragmentation at different levels (tablespace, extents, and row chaining). Run them, interpret results, and derive conclusions. Also demonstrate row chaining and how to resolve it.

---

## Quick summary of fragmentation types

* **Table fragmentation** — wasted space inside blocks due to many deletes/updates. Causes extra block reads.
* **Index fragmentation** — dead space inside index structures after deletes/updates. Slows index range scans.
* **Tablespace fragmentation** — free extents scattered across the tablespace. Large contiguous allocations may fail or be slow.

---

# 1 — Tablespace and extent level fragmentation (3 queries)

> Use these as your first triage. If you do not have DBA rights use `USER_` views (examples below).

### Query A — Free space summary by tablespace

```sql
-- Query A: free space and number of free extents per tablespace
SELECT tablespace_name,
       SUM(bytes)/1024/1024 AS free_mb,
       COUNT(*)           AS free_extents
FROM   dba_free_space
GROUP  BY tablespace_name
ORDER  BY tablespace_name;
```

**What it shows**

* Total free MB per tablespace and how fragmented free space is (many small extents = fragmentation).
  **If you lack privileges**
* Replace `dba_free_space` with `user_free_space` or ask DBA to run it.

---

### Query B — Largest free extent per tablespace

```sql
-- Query B: largest continuous free extent available
SELECT tablespace_name,
       MAX(bytes)/1024/1024 AS largest_free_extent_mb
FROM   dba_free_space
GROUP  BY tablespace_name;
```

**What it shows**

* If `largest_free_extent_mb` is small relative to needed allocation, large object creation or extent allocation may fail or fragment further.

---

### Query C — Allocated vs Free extents (combined)

```sql
-- Query C: combined report of allocated and free extents (alloc vs free)
SELECT tablespace_name,
       num_extents,
       total_mb,
       smallest_extent_mb,
       largest_extent_mb,
       type
FROM (
    SELECT tablespace_name,
           COUNT(*)                 AS num_extents,
           SUM(bytes)/1024/1024     AS total_mb,
           MIN(bytes)/1024/1024     AS smallest_extent_mb,
           MAX(bytes)/1024/1024     AS largest_extent_mb,
           'ALLOCATED'              AS type
    FROM   dba_extents
    GROUP  BY tablespace_name
    UNION ALL
    SELECT tablespace_name,
           COUNT(*)                 AS num_extents,
           SUM(bytes)/1024/1024     AS total_mb,
           MIN(bytes)/1024/1024     AS smallest_extent_mb,
           MAX(bytes)/1024/1024     AS largest_extent_mb,
           'FREE'                   AS type
    FROM   dba_free_space
    GROUP  BY tablespace_name
)
ORDER BY tablespace_name, type;
```

**What it shows**

* Side-by-side view of allocated extents and free extents, including smallest and largest extents. Helps you see distribution imbalance.

---

### How to run these queries

1. Connect with a user that can read dictionary views:

   ```bash
   sqlplus username/YourPassword@//localhost:1521/XEPDB1
   ```

   or run as a DBA with `CONNECT sys / AS SYSDBA`.
2. Paste the query block exactly into SQL*Plus or save into a `.sql` file and run `@file.sql` or copy past code.
3. If you get `ORA-00942` then switch to `user_` views:

   * `dba_free_space` → `user_free_space`
   * `dba_extents` → `user_extents`

---

### How to interpret results (practical rules)

* **High free_mb with many free_extents**: free space exists but is fragmented. If `free_extents` >> (expected), you have many small holes.
* **largest_free_extent_mb small**: even if free_mb is large, lack of contiguous free space may block large allocations.
* **allocated smallest_extent_mb << largest_extent_mb**: inconsistent extent sizing may indicate mixed allocation strategies or multiple objects with different storage clauses.
* **Actionable steps**

  * For tablespace fragmentation: `ALTER TABLESPACE <ts> COALESCE;` (for locally managed with uniform extents this may differ) or move large objects to a defragmented tablespace with `ALTER TABLE ... MOVE` or `CREATE TABLE AS SELECT` and swap names.
  * For free space allocation issues: consider resizing files, adding datafiles, or coalescing extents.
  * For indexes: `ALTER INDEX ... REBUILD` or `ALTER INDEX ... COALESCE` depending on need and downtime tolerance.

---

# 2 — Row chaining demonstration and detection

Row chaining happens when a row cannot fit into a single block and continues in another block (multi-block row). This typically appears for wide rows or when addresses are padded. Oracle exposes chaining counts via `USER_TABLES.CHAIN_CNT` after computing stats.

### Step-by-step demo script (run as your normal user)

**1. Clean slate**

```sql
DROP TABLE student_chain PURGE;
```

**2. Create table**

```sql
CREATE TABLE student_chain (
    student_id      NUMBER,
    student_name    VARCHAR2(20),
    student_address VARCHAR2(4000)
)
TABLESPACE stud
STORAGE (INITIAL 10K NEXT 20K);
```

**3. Insert sample rows**

```sql
-- insert 20 rows (example)
INSERT INTO student_chain VALUES (1, 'raj', 'ahmedabad');
INSERT INTO student_chain VALUES (2, 'kunal', 'surat');
-- ... continue until 20 rows ...
COMMIT;
```

**4. Force chaining by updating addresses to very large values**

```sql
UPDATE student_chain
SET student_address = RPAD('house no. 12, shree krupa ...', 4000, 'x')
WHERE student_id = 1;
-- repeat updates for many rows (IDs 1..20)
COMMIT;
```

**5. Analyze and get chain count**

```sql
ANALYZE TABLE student_chain COMPUTE STATISTICS;

SELECT table_name, chain_cnt
FROM   user_tables
WHERE  table_name = 'STUDENT_CHAIN';
```

* `CHAIN_CNT` > 0 shows chained rows exist.
---

## Fixing chaining (recommended approach)

Create a new table with an appropriate column type and move data. Example converts large `VARCHAR2(4000)` to `CLOB` to avoid chaining for large text.

**1. Create new table**

```sql
CREATE TABLE student_chain_new (
    student_id      NUMBER,
    student_name    VARCHAR2(20),
    student_address CLOB
)
TABLESPACE stud
STORAGE (INITIAL 10K NEXT 20K);
```

**2. Copy data**

```sql
INSERT INTO student_chain_new(student_id, student_name, student_address)
SELECT student_id, student_name, student_address
FROM   student_chain;
COMMIT;
```

**3. Analyze and get chain count**

```sql
ANALYZE TABLE student_chain_new COMPUTE STATISTICS;

SELECT table_name, chain_cnt
FROM   user_tables
WHERE  table_name = 'STUDENT_CHAIN_NEW';
```

**Expected result**

* `STUDENT_CHAIN` shows a positive `CHAIN_CNT` (chaining present).
* `STUDENT_CHAIN_NEW` should show `CHAIN_CNT` = 0 or reduced, indicating chaining resolved.

**Alternative fixes**

* Use `ALTER TABLE ... MOVE` to rebuild rows into contiguous blocks.
* Use `SHRINK SPACE` for tables with row movement allowed, but be careful with LOBs and dependencies.
* For indexes, `ALTER INDEX ... REBUILD`.

---

# How to analyze results and draw conclusions

* **Tablespace fragmentation conclusion**

  * If `free_mb` is low and `largest_free_extent_mb` is very small, your tablespace is severely fragmented. Conclusion: add datafile or coalesce extents or move big objects.
  * If `free_mb` is high but split into many small `free_extents`, you still can run into allocation issues for big extents. Conclusion: coalesce or re-create large objects.

* **Extent distribution conclusion**

  * If `allocated` extents have many tiny `smallest_extent_mb` while `largest_extent_mb` is large, allocation sizes are inconsistent. Conclusion: review storage clauses, set uniform extent sizes where possible.

* **Row chaining conclusion**

  * If `chain_cnt` > 0 and column definitions allow very wide rows, you likely have chained rows. Conclusion: convert wide columns to `CLOB`, move rows with `ALTER TABLE ... MOVE` or recreate table and copy data.

---

## Final notes and practical tips

* Always test fixes on a dev instance before production.
* `ANALYZE TABLE ... COMPUTE STATISTICS` is okay for quick checks. 
* Chaining can be introduced by very wide `VARCHAR2` or frequent updates that expand row length. Prefer LOBs for very large text.
* For production cleanups schedule maintenance windows for `MOVE` or `REBUILD` operations.
---