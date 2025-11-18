# Objective

Measure how efficiently the **Shared Pool** and **Redo (log buffer)** areas satisfy requests from memory (cache) rather than forcing extra work (parsing / waiting / disk I/O). Produce simple, actionable metrics (hit ratios) to guide tuning decisions.

# Purpose

1. Detect wasteful reparses, reloads or library-cache misses (shared pool).
2. Detect redo buffer pressure and log-space waits (redo log area).
3. Provide numeric indicators to decide whether to increase memory, change application behavior, or tune SQL/PLSQL.

---

# Explain each query — what it does and why

### 1) `v$librarycache` — Get/Pins hit ratios

`SUM(gethits) / SUM(gets)` and `SUM(pinhits) / SUM(pins)`

* `v$librarycache` columns:

  * `gets` = number of library cache GET requests (logical requests to find an object/statement).
  * `gethits` = number of those GETs satisfied without a miss.
  * `pins` = number of times an object was pinned (prevented from being flushed).
  * `pinhits` = pins satisfied without needing a reload.
* Why: library cache misses force reparsing/reload, causing CPU and parse overhead. Higher hit ratio = fewer reparses.
* Defensive code: `NULLIF(SUM(gets),0)` prevents divide-by-zero when no activity exists.

**Expected output (example):**

| Shared Pool Get Hit Ratio (%) | Shared Pool Pin Hit Ratio (%) |
| ----------------------------: | ----------------------------: |
|                         96.45 |                         98.12 |

**Interpretation example:** If get-hit = 96.45% → ~3.55% of library GETs missed and required extra work (parse/load).

---

### 2) `v$shared_pool_reserved` — requests vs misses

`(SUM(requests) - SUM(request_misses)) / SUM(requests)`

* `v$shared_pool_reserved` tracks requests to reserved sub-areas of the shared pool and misses there.
* Why: gives another angle on shared-pool usefulness and fragmentation/reservation effectiveness.
* Use-case: if `request_misses` is high in the reserved pool, reserved allocations (or fragmentation) may be a problem.

**Expected output (example):**

| Shared Pool Hit Ratio (%) |
| ------------------------: |
|                     93.50 |

**Interpretation:** ~6.5% of requests to reserved space missed — consider resizing or reducing allocations.

---

### 3) `v$sysstat` redo ratio — `redo entries` vs `redo buffer allocation retries`

`1 - (redo buffer allocation retries / redo entries)`

* `redo entries` = total redo records generated.
* `redo buffer allocation retries` = times session had to retry allocation due to buffer shortages (an indicator of contention/waits).
* Why: retries show the redo buffer could not immediately supply space; typical fix is increasing `LOG_BUFFER` or changing workload pattern.
* Note: both stats are cumulative since instance start — measure deltas for a period when needed.

**Expected output (example):**

| Redo Log Hit Ratio (%) |
| ---------------------: |
|                  98.30 |

**Interpretation:** ~1.7% retries — small but worth monitoring if trending upward.

---

### 4) `v$log` approximate hit ratio

`(COUNT(*) - SUM(case when status='ACTIVE' then 1 else 0 end)) / COUNT(*)`

* `v$log` rows = redo log groups; `status` can be `ACTIVE`, `INACTIVE`, etc.
* This query reports the percent of redo log groups that are not ACTIVE (i.e., free/available).
* Why: if many logs are active or switches are frequent, sessions can wait for log space.
* Caveat: this is an approximation — number of groups is small and this metric is coarse.

**Expected output (example):**

| Approx Redo Log Hit Ratio (%) |
| ----------------------------: |
|                         66.67 |

**Interpretation:** If 2 of 3 groups are not active -> 66.67% free. Low percentages with many active logs could show frequent switching.

---

### 5) `v$sysstat` select list (redo writes, space requests/waits)

* Displays raw counters: `redo writes`, `redo log space requests`, `redo log space waits`.
* Use these to see absolute wait counts; `redo log space waits` > 0 means sessions waited for space — actionable.

**Example output rows:**

|                           name |  value | con_id | class |
| -----------------------------: | -----: | -----: | ----: |
|                   redo entries | 100000 |      0 |   ... |
|        redo log space requests |   1200 |      0 |   ... |
|           redo log space waits |      5 |      0 |   ... |
| redo buffer allocation retries |    180 |      0 |   ... |
|                    redo writes |  99500 |      0 |   ... |

**Interpretation:** `redo log space waits = 5` → some sessions waited; investigate why (large transactions, commit pattern, log size).

---

# Example calculations (walk-through)

**Shared pool example**

* Gets = 2000, Get Misses = 100
  Get Hit Ratio = (2000 - 100) / 2000 * 100 = 95%

**Redo example**

* Redo Entries = 10,000, Redo Buffer Allocation Retries = 200
  Redo Hit Ratio = (1 - 200 / 10000) * 100 = 98%

---

# How to run (practical notes)

1. Use a privileged user or ensure `SELECT` on the `v$` views.
2. Remember `v$sysstat`/`v$librarycache` are cumulative since instance start. To measure activity during a workload window, capture values at T1 and T2 and subtract (delta).
3. Run these queries during normal workload and during heavy workload (e.g., test job) to compare.
4. Combine with wait-event monitoring (`v$session_wait`, AWR/ASH) and `v$sql` top offenders when you see misses/waits.

---

# Conclusion & Recommended actions

**Interpretation rules**

* **> 95% (shared pool / redo)**: healthy; few misses/retries. Continue monitoring.
* **90–95%**: acceptable but watch trends and correlate with wait events.
* **< 90%**: problem — take action.

**Actions for Shared Pool low hit ratio**

* Reduce hard parsing: bind variables, cursor reuse.
* Use cursor sharing (`CURSOR_SHARING`) carefully; prefer code fixes first.
* Increase `SHARED_POOL_SIZE` if memory available and fragmentation not the issue.
* Use `v$sql` and `v$librarycache` to find top parsed statements.

**Actions for Redo low hit ratio / retries / waits**

* Increase `LOG_BUFFER` (`ALTER SYSTEM SET log_buffer = <size> SCOPE=BOTH;`) only after analysis.
* Reduce huge single transactions; break up or commit logically to avoid huge bursts of redo.
* Ensure redo destinations and disks are not slow. Use OS metrics to confirm.
* Tune application commit frequency (balance between too-frequent commits and very large transactions).

---