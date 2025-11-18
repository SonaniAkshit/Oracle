# Quick summary (in one line)

Sort area contention = too many sorts spilling to disk (TEMP) or waiting for sort memory; measure with `sorts (memory)` vs `sorts (disk)`, find offending sessions/SQL, then fix by tuning SQL, increasing PGA (correct way), or adding TEMP space.

---

## 1) Global counts — memory vs disk sorts (single-shot)

```sql
-- Global snapshot: cumulative since instance start
SELECT
  SUM(CASE WHEN name = 'sorts (memory)' THEN value END) AS memory_sorts,
  SUM(CASE WHEN name = 'sorts (disk)'   THEN value END) AS disk_sorts
FROM v$sysstat
WHERE name IN ('sorts (memory)','sorts (disk)');
```

**What it returns**
One row with two numbers. Example:

```
MEMORY_SORTS | DISK_SORTS
------------:|----------:
      150000 |     12000
```

**Interpretation**
These are cumulative counts. If `disk_sorts` is non-trivial compared with `memory_sorts`, sorts are spilling to disk frequently.

---

## 2) Sort hit ratio (simple)

```sql
-- Sort hit ratio = memory_sorts / (memory_sorts + disk_sorts) * 100
SELECT
  ROUND(
    (mem + disk) - (disk) 
    / NULLIF((mem + disk),0) * 100, 2
  ) AS bad_expression; -- placeholder: avoid confusion
```

Ignore that block — use the correct safe query below:

```sql
-- Correct sort hit ratio (safe against divide-by-zero)
SELECT
  MEM.VALUE AS memory_sorts,
  DISK.VALUE AS disk_sorts,
  ROUND(
    (NVL(MEM.VALUE,0) / NULLIF(NVL(MEM.VALUE,0) + NVL(DISK.VALUE,0), 0)) * 100,
    2
  ) AS sort_hit_ratio_percent
FROM
  (SELECT VALUE FROM v$sysstat WHERE name = 'sorts (memory')) MEM,
  (SELECT VALUE FROM v$sysstat WHERE name = 'sorts (disk'))   DISK;
```

**Output example**

```
MEMORY_SORTS | DISK_SORTS | SORT_HIT_RATIO_PERCENT
-----------: | ---------: | ---------------------:
      150000 |      12000 |                 92.59
```

**Interpretation**
~92.6% of sorts were satisfied in memory; ~7.4% required disk. Aim: as high as possible (practical target > 90–95% depending on workload).

---

## 3) Per-session sort counts (who is generating sorts)

```sql
-- Per-session sorts (memory + disk) using v$sesstat + v$statname
SELECT
  s.sid,
  s.serial#,
  s.username,
  s.program,
  SUM(CASE WHEN n.name = 'sorts (memory)' THEN ss.value ELSE 0 END) AS sorts_memory,
  SUM(CASE WHEN n.name = 'sorts (disk)'   THEN ss.value ELSE 0 END) AS sorts_disk
FROM v$session s
JOIN v$sesstat ss ON ss.sid = s.sid
JOIN v$statname n ON n.statistic# = ss.statistic#
WHERE n.name IN ('sorts (memory)','sorts (disk)')
  AND s.type = 'USER'
GROUP BY s.sid, s.serial#, s.username, s.program
ORDER BY (NVL(sorts_disk,0) + NVL(sorts_memory,0)) DESC;
```

**What it returns**
Rows per active session showing how many sorts that session has performed (since instance start or since session start, depending on stat reset).

**Use**
Identify sessions with large `sorts_disk` or large total sorts — candidate sessions to investigate.

---

## 4) Snapshot / delta technique (measure during a workload window)

`v$sysstat` and `v$sesstat` are cumulative; to measure contention during a specific window capture two snapshots and compute deltas.

```sql
-- Create a simple snapshot table (run once)
CREATE TABLE sort_snapshot (
  ts         TIMESTAMP,
  memory_sorts NUMBER,
  disk_sorts   NUMBER
);

-- Take snapshot before test
INSERT INTO sort_snapshot
SELECT SYSTIMESTAMP,
       SUM(CASE WHEN name='sorts (memory)' THEN value END),
       SUM(CASE WHEN name='sorts (disk)'   THEN value END)
FROM v$sysstat
WHERE name IN ('sorts (memory)','sorts (disk)');
COMMIT;

-- ... run your workload/tests now ...

-- Take snapshot after test
INSERT INTO sort_snapshot
SELECT SYSTIMESTAMP,
       SUM(CASE WHEN name='sorts (memory)' THEN value END),
       SUM(CASE WHEN name='sorts (disk)'   THEN value END)
FROM v$sysstat
WHERE name IN ('sorts (memory)','sorts (disk)');
COMMIT;

-- Compute deltas
WITH s AS (
  SELECT ROW_NUMBER() OVER (ORDER BY ts) rn, ts, memory_sorts, disk_sorts
  FROM sort_snapshot
)
SELECT
  s2.ts AS end_ts,
  (s2.memory_sorts - s1.memory_sorts) AS delta_memory_sorts,
  (s2.disk_sorts   - s1.disk_sorts)   AS delta_disk_sorts,
  ROUND(
    ( (s2.memory_sorts - s1.memory_sorts)
      / NULLIF( (s2.memory_sorts - s1.memory_sorts) + (s2.disk_sorts - s1.disk_sorts), 0)
    ) * 100, 2
  ) AS delta_sort_hit_ratio_pct
FROM s s1
JOIN s s2 ON s2.rn = s1.rn + 1
ORDER BY s2.ts DESC;
```

**Why**
This tells you exactly how many sorts spilled to disk during the interval and the effective hit ratio during the workload — far more useful than cumulative totals.

---

## 5) Find SQL statements that cause heavy sorts

`v$sql` contains useful counters including `sorts` (number of sorts performed by that SQL — available in many Oracle versions). Use it to find heavy-sorting SQL.

```sql
-- Top SQL by number of sorts (cumulative)
SELECT
  sql_id,
  executions,
  buffer_gets,
  disk_reads,
  sorts,
  parsing_schema_name,
  SUBSTR(sql_text,1,200) AS sql_text
FROM v$sql
WHERE sorts > 0
ORDER BY sorts DESC
FETCH FIRST 30 ROWS ONLY;
```

**What you get**
Top SQLs by sort count. Look at `sql_text` and execution plan of those SQLs to see whether sorts are avoidable (indexes, rewritten queries, limits).

---

## 6) Check TEMP and tempfiles usage — are sorts waiting on TEMP?

You need enough TEMP space and efficient TEMP files (on fast storage). A simple check for TEMP extents:

```sql
-- Show tempfiles for USERS TEMP tablespace (example — replace with your TEMP name)
SELECT tablespace_name, file_name, bytes/1024/1024 AS mb, status
FROM dba_temp_files
WHERE tablespace_name = (SELECT value FROM v$parameter WHERE name = 'user_dump_dest' /* replace */)
-- Replace with your actual TEMP tablespace name: e.g. 'TEMP'
ORDER BY file_name;
```

Better to query `DBA_TEMP_FILES` for your TEMP tablespace name (replace placeholder). If TEMP is too small or fragmented you will see sorts go to disk and potential waits.

---

## 7) Identify waits related to sorts (sessions waiting for temp I/O)

Check `v$session_wait` or `v$active_session_history` (if licensed) for events like `direct path read`, `direct path write` or `db file scattered read` during large sorts. Example:

```sql
-- Sessions currently waiting (quick look)
SELECT sid, event, p1text, p1, wait_class, seconds_in_wait
FROM v$session_wait
WHERE event LIKE '%direct path%' OR event LIKE '%sort%' OR event LIKE '%temp%';
```

**What it returns**
Sessions currently waiting on I/O related to sorting/temp usage — these are your contention victims.

---

## 8) Quick check: current PGA settings & workarea policy (modern Oracle)

`SORT_AREA_SIZE` is deprecated on modern Oracle releases. Use `PGA_AGGREGATE_TARGET` and `WORKAREA_SIZE_POLICY=AUTO`. Check current values:

```sql
SELECT name, value
FROM v$parameter
WHERE name IN ('pga_aggregate_target','workarea_size_policy','sort_area_size','hash_area_size','pga_aggregate_limit');
```

**Why**
If `workarea_size_policy` = `MANUAL`, `sort_area_size` may still be used (older DBs). If `AUTO`, Oracle auto-manages per-operation memory within the PGA.

---

## 9) Example remediation commands (what a DBA should do)

**1. Don’t blindly set `SORT_AREA_SIZE`**
`SORT_AREA_SIZE` is deprecated. Instead:

```sql
-- set auto workarea policy and increase PGA (example values; size depends on server RAM)
ALTER SYSTEM SET workarea_size_policy = AUTO SCOPE = BOTH;
ALTER SYSTEM SET pga_aggregate_target = 4G SCOPE = BOTH;   -- adjust to available memory
```

**2. If using MANUAL policy (old installations) and you must increase per-session area**

```sql
ALTER SYSTEM SET sort_area_size = 10485760 SCOPE = BOTH; -- 10M (not recommended on modern DBs)
```

**3. Add or enlarge TEMP files (if TEMP full / slow)**

```sql
ALTER TABLESPACE TEMP ADD TEMPFILE '/path/to/temp02.dbf' SIZE 10G AUTOEXTEND ON NEXT 1G;
-- or increase existing tempfile:
ALTER DATABASE TEMPFILE '/path/to/temp01.dbf' RESIZE 20G;
```

**4. Tune SQL (the best fix often)**

* Add appropriate indexes to avoid sorts (ORDER BY, GROUP BY).
* Avoid `ORDER BY`/`GROUP BY` over unindexed large sets if possible.
* Limit data (use WHERE), push predicates early (filter before sort).
* Consider materialized views or pre-sorted staging tables for repeated heavy sorts.

**5. Use parallelism for large reports**

```sql
ALTER SESSION ENABLE PARALLEL DML;
-- or use hint /*+ parallel(t,4) */ for heavy queries after testing
```

**6. Monitor and adjust temp file placement**

* Put TEMP on fast disks (SSD), ensure proper striping.
* Use multiple TEMP files across different disks for better parallel temp I/O.

---

## 10) How to act as a DBA — step-by-step troubleshooting playbook

1. **Measure**: run the global and delta snapshots to confirm the problem window and actual disk sorts (`disk_sorts` delta).
2. **Find offenders**: run per-session and top-v$sql queries to identify heavy sorting sessions and SQL.
3. **Check waits**: inspect `v$session_wait` for temp/direct-path I/O waits during the time.
4. **Inspect SQL plans**: for the top sorting SQL get the execution plan (`EXPLAIN PLAN` / `DBMS_XPLAN.DISPLAY_CURSOR`) and see why optimizer chooses a sort (lack of index / full scan / large GROUP BY).
5. **Quick fixes** (fastest wins):

   * Tune/rewite offending SQL (add index, push predicate).
   * Add TEMP space or move TEMP to faster disks.
   * Increase PGA (if safe) and set `workarea_size_policy = AUTO`.
6. **If still needed**:

   * Consider increasing `PGA_AGGREGATE_TARGET` or configuring `pga_aggregate_limit`.
   * Consider creating pre-aggregated tables or materialized views for repetitive heavy sorts.
   * Use parallel execution for large batch/reporting jobs.
7. **Monitor**: capture another delta snapshot; verify `disk_sorts` reduced and `sort_hit_ratio_pct` improved.

---

## 11) Example outputs & what to conclude

* **Case A (good)**:

  * `sort_hit_ratio_pct = 98%`, few waits in `v$session_wait` → memory is fine, little or no contention.
* **Case B (warning)**:

  * `sort_hit_ratio_pct = 85%`, a few heavy sessions show large `sorts_disk` → tune those SQLs, consider modest PGA increase.
* **Case C (bad)**:

  * `sort_hit_ratio_pct < 70%`, many sessions waiting on temp I/O, frequent `direct path write/read` events → immediate action: increase TEMP, tune SQL, increase PGA carefully, check I/O subsystem.

---

## 12) Final conclusion (short, direct)

Sort area contention shows up as a high number of disk sorts and wait events for temp I/O. Start by measuring with `v$sysstat` and the snapshot/delta method to confirm the problem during the target window. Then identify the sessions and SQL causing the sorts. The correct fixes are, in order of likely effectiveness: **tune SQL and add indexes**, **ensure sufficient and fast TEMP space**, and **use modern PGA settings (`workarea_size_policy = AUTO` + appropriate `pga_aggregate_target`)** rather than relying on deprecated `SORT_AREA_SIZE`. Monitor after each change and iterate.

---