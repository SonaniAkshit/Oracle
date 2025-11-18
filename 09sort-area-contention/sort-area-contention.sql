-- Simple, short and useful queries for Sort-area contention diagnostics

-- 1) Per-session sorts (who's generating sorts)
SELECT
  s.sid,
  s.serial#,
  s.username,
  s.program,
  SUM(CASE WHEN n.name = 'sorts (memory)' THEN ss.value ELSE 0 END) AS mem_sorts,
  SUM(CASE WHEN n.name = 'sorts (disk)'   THEN ss.value ELSE 0 END) AS disk_sorts
FROM v$session s
JOIN v$sesstat ss   ON ss.sid = s.sid
JOIN v$statname n   ON n.statistic# = ss.statistic#
WHERE n.name IN ('sorts (memory)','sorts (disk)')
  AND s.type = 'USER'
GROUP BY s.sid, s.serial#, s.username, s.program
ORDER BY (NVL(mem_sorts,0) + NVL(disk_sorts,0)) DESC;

-- 2) Global counts (cumulative since instance start)
SELECT
  NVL(SUM(CASE WHEN name = 'sorts (memory)' THEN value END),0) AS memory_sorts,
  NVL(SUM(CASE WHEN name = 'sorts (disk)'   THEN value END),0) AS disk_sorts
FROM v$sysstat
WHERE name IN ('sorts (memory)','sorts (disk)');

-- 3) Sort hit ratio (safe against divide-by-zero)
SELECT
  mem,
  disk,
  ROUND( NVL(mem,0) / NULLIF(NVL(mem,0) + NVL(disk,0), 0) * 100, 2) AS sort_hit_ratio_pct
FROM (
  SELECT
    NVL(SUM(CASE WHEN name = 'sorts (memory)' THEN value END),0) AS mem,
    NVL(SUM(CASE WHEN name = 'sorts (disk)'   THEN value END),0) AS disk
  FROM v$sysstat
  WHERE name IN ('sorts (memory)','sorts (disk)')
);

-- 4) Quick current-wait check for temp/sort I/O (who's waiting now)
SELECT sid, event, wait_class, seconds_in_wait
FROM v$session_wait
WHERE event LIKE '%direct path%' OR event LIKE '%temp%' OR event LIKE '%sort%'
ORDER BY seconds_in_wait DESC;

-- Recommended (commented) DBA actions — run only after analysis:
-- ALTER SYSTEM SET workarea_size_policy = AUTO SCOPE = BOTH;
-- ALTER SYSTEM SET pga_aggregate_target = 4G SCOPE = BOTH;  -- adjust to available RAM
-- ALTER TABLESPACE TEMP ADD TEMPFILE '/path/to/temp02.dbf' SIZE 10G AUTOEXTEND ON NEXT 1G;
-- (Do not blindly use SORT_AREA_SIZE on modern Oracle releases)
