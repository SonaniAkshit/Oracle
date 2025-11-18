-- check_fragmentation_dbms_space.sql
-- Run as the table owner (schema that owns AUTHOR)
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 200

PROMPT === 1) Prepare: drop/create a simple AUTHOR table (adjust if already exists) ===
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE author PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE author (
    BOOK_ID   NUMBER,
    AUTHOR_ID NUMBER,
    TITLE     VARCHAR2(100),
    PRICE     NUMBER(10,2)
) STORAGE (INITIAL 5K NEXT 5K MINEXTENTS 1 MAXEXTENTS 5);
PROMPT Table AUTHOR created.

PROMPT === 2) Insert sample rows (small sample to illustrate) ===
INSERT INTO author (book_id, author_id, title, price) VALUES (1, 101, 'abc', 100);
INSERT INTO author (book_id, author_id, title, price) VALUES (2, 101, 'def', 150);
INSERT INTO author (book_id, author_id, title, price) VALUES (3, 102, 'ghi', 200);
COMMIT;
PROMPT Sample rows inserted.

PROMPT === 3) Use DBMS_SPACE.UNUSED_SPACE to get fragmentation stats ===
DECLARE
    l_total_blocks              NUMBER;
    l_total_bytes               NUMBER;
    l_unused_blocks             NUMBER;
    l_unused_bytes              NUMBER;
    l_last_used_extent_file_id  NUMBER;
    l_last_used_extent_block_id NUMBER;
    l_last_used_block           NUMBER;
BEGIN
    DBMS_SPACE.UNUSED_SPACE (
        segment_owner             => USER,        -- current schema; replace 'MCA36' if required
        segment_name              => 'AUTHOR',
        segment_type              => 'TABLE',
        total_blocks              => l_total_blocks,
        total_bytes               => l_total_bytes,
        unused_blocks             => l_unused_blocks,
        unused_bytes              => l_unused_bytes,
        last_used_extent_file_id  => l_last_used_extent_file_id,
        last_used_extent_block_id => l_last_used_extent_block_id,
        last_used_block           => l_last_used_block
    );

    DBMS_OUTPUT.PUT_LINE('--- DBMS_SPACE.UNUSED_SPACE output ---');
    DBMS_OUTPUT.PUT_LINE('Total Blocks        : ' || NVL(TO_CHAR(l_total_blocks), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Total Bytes         : ' || NVL(TO_CHAR(l_total_bytes), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Unused Blocks       : ' || NVL(TO_CHAR(l_unused_blocks), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Unused Bytes        : ' || NVL(TO_CHAR(l_unused_bytes), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Last Used File ID   : ' || NVL(TO_CHAR(l_last_used_extent_file_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Last Used Block ID  : ' || NVL(TO_CHAR(l_last_used_extent_block_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Last Used Block     : ' || NVL(TO_CHAR(l_last_used_block), 'NULL'));
END;
/
PROMPT Finished DBMS_SPACE.UNUSED_SPACE call.

PROMPT === 4) Show storage allocation from USER_SEGMENTS (allocated size) ===
COLUMN segment_name FORMAT A20
COLUMN bytes FORMAT 9999999999
SELECT segment_name, segment_type, bytes, blocks
FROM user_segments
WHERE segment_name = 'AUTHOR';

PROMPT === 5) Show extent-level details (USER_EXTENTS) ===
COLUMN file_id FORMAT 999
COLUMN block_id FORMAT 9999999
COLUMN blocks FORMAT 9999999
SELECT file_id, block_id, blocks, bytes
FROM user_extents
WHERE segment_name = 'AUTHOR'
ORDER BY file_id, block_id;

PROMPT === 6) Optional: show free extents in this tablespace (if allowed)
-- This query may require additional privileges; try it if you have access to DBA_FREE_SPACE
-- SELECT tablespace_name, file_id, block_id, blocks FROM dba_free_space WHERE tablespace_name = (SELECT tablespace_name FROM user_segments WHERE segment_name='AUTHOR');

PROMPT === Script complete. Inspect DBMS_OUTPUT and the queries above for fragmentation analysis.
