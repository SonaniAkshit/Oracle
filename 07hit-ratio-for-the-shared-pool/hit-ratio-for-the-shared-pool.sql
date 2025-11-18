-- ======================================================
-- SHARED POOL: Get Hit Ratios from v$librarycache
-- ======================================================
SET PAGESIZE 100
SET LINESIZE 200
COL "Shared Pool Get Hit Ratio (%)" FORMAT 999.99
COL "Shared Pool Pin Hit Ratio (%)" FORMAT 999.99

SELECT
    ROUND((SUM(gethits) / NULLIF(SUM(gets),0)) * 100, 2) AS "Shared Pool Get Hit Ratio (%)",
    ROUND((SUM(pinhits) / NULLIF(SUM(pins),0)) * 100, 2) AS "Shared Pool Pin Hit Ratio (%)"
FROM v$librarycache;


-- ======================================================
-- SHARED POOL: Alternate view from v$shared_pool_reserved
-- (shows requests vs misses for the reserved area)
-- ======================================================
COL "Shared Pool Hit Ratio (%)" FORMAT 999.99

SELECT
    ROUND(
        ((SUM(requests) - SUM(request_misses)) / NULLIF(SUM(requests),0)) * 100,
        2
    ) AS "Shared Pool Hit Ratio (%)"
FROM v$shared_pool_reserved;


-- ======================================================
-- REDO LOG: Hit ratio using v$sysstat (redo entries vs allocation retries)
-- ======================================================
COL "Redo Log Hit Ratio (%)" FORMAT 999.99

SELECT
    ROUND(
        (1 - (SUM(CASE WHEN name = 'redo buffer allocation retries' THEN value ELSE 0 END)
               / NULLIF(SUM(CASE WHEN name = 'redo entries' THEN value ELSE 0 END),0)
              )
        ) * 100,
        2
    ) AS "Redo Log Hit Ratio (%)"
FROM v$sysstat
WHERE name IN ('redo entries', 'redo buffer allocation retries');


-- ======================================================
-- REDO LOG: Approximate active-log percentage (how many redo logs are NOT active)
-- (useful to understand log usage; active logs may indicate log switches/waits)
-- ======================================================
COL "Approx Redo Log Hit Ratio (%)" FORMAT 999.99

SELECT
    ROUND(
        (
            (COUNT(*) - SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END))
            / NULLIF(COUNT(*),0)
        ) * 100,
        2
    ) AS "Approx Redo Log Hit Ratio (%)"
FROM v$log;


-- ======================================================
-- REDO LOG: Important redo-related sysstat values for diagnosing waits
-- ======================================================
SELECT name, value, con_id, class
FROM v$sysstat
WHERE name IN ('redo writes', 'redo log space requests', 'redo log space waits', 'redo entries', 'redo buffer allocation retries')
ORDER BY name;
