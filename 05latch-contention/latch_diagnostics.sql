-- ============================================================
-- LATCH CONTENTION DIAGNOSTIC SCRIPT
-- Use: Paste in SQL*Plus or run as @latch_diagnostic.sql
-- ============================================================

SET PAGESIZE 200
SET LINESIZE 200
SET TRIMSPOOL ON

COLUMN name            FORMAT A40
COLUMN type            FORMAT A12
COLUMN gets            FORMAT 999,999,999
COLUMN misses          FORMAT 999,999,999
COLUMN sleeps          FORMAT 999,999,999
COLUMN spin_gets       FORMAT 999,999,999
COLUMN hit_ratio       FORMAT 999.99
COLUMN sleep_pct       FORMAT 999.99
COLUMN total_mb        FORMAT 999,999.99
COLUMN largest_free_mb FORMAT 999,999.99
COLUMN namespace       FORMAT A20
COLUMN program         FORMAT A30
COLUMN event           FORMAT A40
COLUMN seconds_in_wait FORMAT 999,999

---------------------------------------------------------------
-- 🔹 LRU Chain Latches (Buffer Cache Contention)
---------------------------------------------------------------
SELECT
    name,
    gets,
    misses,
    sleeps,
    ROUND(((gets - misses) / NULLIF(gets, 0)) * 100, 2) AS hit_ratio_percent
FROM
    v$latch
WHERE
    LOWER(name) LIKE '%lru%';

---------------------------------------------------------------
-- 🔹 Library Cache Latches (Parsing / SQL Shared Pool Contention)
---------------------------------------------------------------
SELECT
    name,
    gets,
    misses,
    sleeps,
    ROUND(((gets - misses) / NULLIF(gets, 0)) * 100, 2) AS hit_ratio_percent
FROM
    v$latch
WHERE
    LOWER(name) LIKE 'library cache%';

---------------------------------------------------------------
-- 🔹 Redo Latches (Log Writer and Redo Buffer Contention)
---------------------------------------------------------------
SELECT
    name,
    gets,
    misses,
    sleeps,
    ROUND(((gets - misses) / NULLIF(gets, 0)) * 100, 2) AS hit_ratio_percent
FROM
    v$latch
WHERE
    LOWER(name) LIKE '%redo%'
ORDER BY
    hit_ratio_percent DESC;

---------------------------------------------------------------
-- 🔹 Quick Overview of Any Chain-Related Latches
---------------------------------------------------------------
SELECT
    name,
    gets,
    misses,
    sleeps,
    spin_gets
FROM
    v$latch
WHERE
    LOWER(name) LIKE '%chain%';

---------------------------------------------------------------
-- 🔹 Quick Overview of Library Cache (Namespace-Level)
---------------------------------------------------------------
SELECT
    namespace,
    gets,
    gethits,
    pins
FROM
    v$librarycache;

---------------------------------------------------------------
-- 🔹 General Latch Overview Sorted by Misses
---------------------------------------------------------------
SELECT
    name,
    gets,
    misses,
    sleeps
FROM
    v$latch
ORDER BY
    misses DESC;