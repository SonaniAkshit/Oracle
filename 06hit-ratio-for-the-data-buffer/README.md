# **Objective**

To measure how efficiently Oracle serves data block requests from memory instead of reading from disk. The goal is to calculate the **Data Buffer Cache Hit Ratio** using Oracle dynamic performance views and interpret the result to understand whether the database memory (buffer cache) is being used effectively.

---

# **Purpose**

1. **Identify memory efficiency**
   You want to know how often Oracle finds the required data in memory rather than doing slow physical reads. This helps assess whether the buffer cache is sized properly.

2. **Detect performance bottlenecks**
   A low hit ratio usually means Oracle is hitting the disk too often. That slows down queries. The purpose of these queries is to catch that problem early.

3. **Decide whether tuning is needed**
   Once you know the hit ratio, you can make informed decisions:

   * Increase `DB_CACHE_SIZE` if memory is clearly insufficient.
   * Tune SQL and indexes if the workload is inefficient.
   * Identify hot tables or queries that are driving physical reads.

4. **Educate students on internal behavior**
   Students should understand:

   * What buffer cache is
   * How Oracle handles logical and physical reads
   * Why hit ratio matters
   * How to run and read the queries correctly

5. **Create a baseline for monitoring**
   By running these queries regularly, you create a trendline. You can use that trend to prove whether performance is improving or getting worse.

---

## 1 — What is the Data Buffer Cache?

The data buffer cache is a region of Oracle SGA (System Global Area) that stores data blocks read from datafiles. When Oracle needs a block for a query, it checks the buffer cache first. If the block is already there, Oracle uses it directly (a **cache hit**). If not, Oracle reads the block from disk into the cache (a **physical read**), which is much slower.

Important: keeping frequently used blocks in the buffer cache reduces disk I/O and improves performance.

## 2 — What is the Buffer Cache Hit Ratio?

The buffer cache hit ratio estimates how often Oracle finds required data blocks in memory rather than having to read from disk.

A common formula:

```
Buffer Cache Hit Ratio (%) = (1 - Physical_Reads / (DB_Block_Gets + Consistent_Gets)) * 100
```

Where:

* `DB_BLOCK_GETS` = number of current-mode block accesses (usually for updates or current consistent reads).
* `CONSISTENT_GETS` = number of consistent-mode block accesses (shared, read-only).
* `PHYSICAL_READS` = number of physical reads from disk.

Interpretation:

* Higher % = more accesses served from memory (good).
* Lower % = more reads from disk (bad for performance).

Typical guidance:

* 90–99% is usually acceptable — most reads are from memory.
* Below ~90% suggests you may need to investigate (increase cache, tune SQL, add indexes, analyze hot spots).

> Note: Hit ratio is a heuristic. Very high numbers do not guarantee optimal performance; sometimes a small change in workload skews the ratio. Always correlate with response time and I/O metrics.

## 3 — Why I corrected the first query (important)

You pasted a query that used:

```sql
ROUND(((cur.value + con.value) / NULLIF((cur.value + con.value) - phy.value, 0)) * 100, 2)
```

That expression is mathematically different and incorrect for calculating "hit ratio". The correct and standard expression is `1 - (physical_reads / total_gets)` as provided above. I replaced that with the corrected and safe formula using `NULLIF(...,0)` to avoid division by zero.

## 4 — Explanation of each SQL block

### Query 1 (recommended / corrected)

* Purpose: single system-wide hit-ratio number.
* How it works:

  * Pulls `db block gets`, `consistent gets`, and `physical reads` from `v$sysstat`.
  * Computes `total_gets = db block gets + consistent gets`.
  * Uses `1 - (physical_reads / total_gets)` to compute the hit percentage.
  * Uses `NULLIF(total_gets, 0)` to avoid divide-by-zero errors, and `ROUND(...,2)` for readable output.

### Query 2 (subquery / clearer aggregation)

* Purpose: same result but safer when `v$sysstat` has multiple rows and you prefer to aggregate in one place.
* Useful if your environment has strange stat distributions or you want a single aggregated result.

### Query 3 (per buffer pool)

* Purpose: get hit ratio for each buffer pool (e.g., KEEP, RECYCLE, DEFAULT).
* Useful in systems using multiple buffer pools to understand which pool is performing well or poorly.
* Explanation of formula:

  * `(db_block_gets + consistent_gets - physical_reads)` = number of logical reads satisfied from cache.
  * Divided by `(db_block_gets + consistent_gets)` = total logical gets.
  * Use `DECODE(...,0,1,...)` to avoid division by zero.

### Query 4 (per-session stats)

* Purpose: show raw session-level stats for sessions (useful when diagnosing one session's behavior).
* Note: per-session hit ratio requires combining stats per session and then computing the ratio; raw session rows must be pivoted/aggregated to compute a per-session hit ratio.

## 5 — How to run these queries

1. Connect with a DBA user (or a user who has `SELECT` on the relevant dynamic views). Example:

   * SQL*Plus:

     ```
     sqlplus / as sysdba
     @buffer_cache_queries.sql
     ```
   * SQL Developer: paste queries and run.
   * SQLcl: same as SQL*Plus.
2. For accurate trending, capture the values at two times and subtract to get deltas (because `v$sysstat` are cumulative since instance start). Example:

   * Run the hit ratio query at time T1, then again at T2; derive activity between T1 and T2 if needed.
3. For per-session, run the per-session query and aggregate by `sid` to compute per-session ratios.

## 6 — Example calculation (walk-through)

Given:

* DB Block Gets = 1000
* Consistent Gets = 500
* Physical Reads = 50

Total gets = 1000 + 500 = 1500
Hit Ratio = (1 - 50 / 1500) * 100 = (1 - 0.0333333) * 100 = 96.6667% → rounded 96.67%

That means ~96.7% of logical requests were served from cache.

## 7 — How to interpret output & next steps

* **> 95%** — healthy; most reads in memory. Continue to monitor response time. Consider whether memory could be reallocated to other SGA components if needed.
* **90–95%** — acceptable but watch for trends. Investigate heavy physical reads by checking `v$segment_statistics`, `AWR`/`ASH` if available.
* **< 90%** — investigate:

  * Are queries performing full table scans instead of index access?
  * Are there large one-time scans (e.g., reports) that push useful blocks out of cache?
  * Is `DB_CACHE_SIZE` too small for workload? Consider increasing if you have free RAM.
  * Use `AWR`, `ASH`, `v$librarycache`, `v$sql` and `v$segment_statistics` to find hot SQL and objects.

## 8 — Extra tips for students

* `v$sysstat` values are cumulative since instance start. To measure activity for a period, capture values at start and end and subtract.
* The hit ratio is a simple metric. For real performance tuning, correlate with:

  * Average active sessions,
  * Wait events (e.g., `db file sequential read`, `db file scattered read`),
  * I/O subsystem metrics (OS-level),
  * Execution plans and SQL tuning.
* Use `ASH`/`AWR` (if licensed) to find SQL that causes lots of physical reads.
* A very high cache hit ratio does not always mean queries are optimal. Example: repeated inefficient operations that all hit cache still can be CPU-bound or memory-bound.

## 9 — Troubleshooting / corner cases

* If `DB_BLOCK_GETS + CONSISTENT_GETS = 0` → hit ratio can't be calculated; queries above handle divide-by-zero.
* Very low physical reads but very high CPU could mean CPU-bound workload — not solved by increasing cache.
* Large one-off scans (ETL, analytic reports) can temporarily reduce the ratio; look at trends over time.

## 10 — Quick checklist for action

1. Run corrected hit-ratio query.
2. If low, list top SQL by physical reads:

   ```sql
   SELECT sql_id, executions, buffer_gets, physical_reads
   FROM v$sql
   ORDER BY physical_reads DESC
   FETCH FIRST 20 ROWS ONLY;
   ```
3. Tune heavy SQL (indexes, rewrite, statistics).
4. Consider `DB_CACHE_SIZE` change only after careful sizing (measure memory available).
5. Monitor again and track weekly/daily trends.

---