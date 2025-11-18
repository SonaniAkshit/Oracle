-- ===========================================================
-- 1) Buffer cache hit ratio - recommended / corrected version
--    (System-wide / per-session aggregated stats)
-- ===========================================================
SET PAGESIZE 100
SET LINESIZE 200
COL "Buffer Cache Hit Ratio (%)" FORMAT 999.99

SELECT
    ROUND((1 - (phy.value / NULLIF((cur.value + con.value), 0))) * 100, 2)
    AS "Buffer Cache Hit Ratio (%)"
FROM
    v$sysstat cur,
    v$sysstat con,
    v$sysstat phy
WHERE
    cur.name = 'db block gets'
    AND con.name = 'consistent gets'
    AND phy.name = 'physical reads';

-- ===========================================================
-- 2) Equivalent expression — explicitly using sum into a subquery
--    (same result, sometimes clearer)
-- ===========================================================
SELECT
    ROUND((1 - (physical_reads / NULLIF(total_gets, 0))) * 100, 2)
    AS "Buffer Cache Hit Ratio (%)"
FROM (
    SELECT
        SUM(CASE WHEN name = 'db block gets' THEN value ELSE 0 END) +
        SUM(CASE WHEN name = 'consistent gets' THEN value ELSE 0 END) AS total_gets,
        SUM(CASE WHEN name = 'physical reads' THEN value ELSE 0 END) AS physical_reads
    FROM v$sysstat
    WHERE name IN ('db block gets','consistent gets','physical reads')
);

-- ===========================================================
-- 3) Per buffer pool statistics (Oracle 11gR2+ with v$buffer_pool_statistics)
--    Shows hit ratio per buffer pool
-- ===========================================================
COL buffer_pool FORMAT A30
COL "Buffer Cache Hit Ratio (%)" FORMAT 999.99
SELECT
    name AS buffer_pool,
    db_block_gets,
    consistent_gets,
    physical_reads,
    ROUND(
        ((db_block_gets + consistent_gets - physical_reads) /
         DECODE((db_block_gets + consistent_gets), 0, 1, (db_block_gets + consistent_gets))) * 100,
        2
    ) AS "Buffer Cache Hit Ratio (%)"
FROM v$buffer_pool_statistics
ORDER BY name;

-- ===========================================================
-- 4) Per-session approach (if you want values scoped to a single session,
--    you'd query SESSION statistics; below is illustrative — usually sysstat is global)
--    Note: Most installations use v$sysstat for global stats. Per-session stats require v$sesstat + v$statname.
-- ===========================================================
-- Example: get db block gets, consistent gets, physical reads for each active session:
SELECT s.sid, n.name,
       ss.value
FROM v$session s
JOIN v$sesstat ss ON ss.sid = s.sid
JOIN v$statname n   ON n.statistic# = ss.statistic#
WHERE n.name IN ('db block gets','consistent gets','physical reads')
  AND s.type = 'USER'
ORDER BY s.sid, n.name;
