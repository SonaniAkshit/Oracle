# Objective

Detect internal fragmentation (unused space inside allocated extents) for a table using `DBMS_SPACE.UNUSED_SPACE`, and inspect the extent allocation via `USER_SEGMENTS` and `USER_EXTENTS`.

### Purpose

* Find how many blocks/bytes are allocated to the table and how many of those are unused (free within the table's allocated extents).
* Decide whether you should reclaim space (shrink or move) or leave it alone.

---

### Explanation of script blocks & outputs

1. **Table create & sample inserts**
   Creates `AUTHOR` with explicit storage to illustrate extents and fragmentation and inserts a few rows so the table has some used space. In production use you’ll run the `DBMS_SPACE` block against an existing table.

2. **DBMS_SPACE.UNUSED_SPACE**

   * Inputs:

     * `segment_owner` — owner of the table (script uses `USER` to mean current schema).
     * `segment_name` — `'AUTHOR'`.
     * `segment_type` — `'TABLE'`.
   * Outputs (printed by the script):

     * `Total Blocks` — total blocks allocated to the segment (sum of blocks in all extents).
     * `Total Bytes` — total bytes allocated (blocks * block_size).
     * `Unused Blocks` — blocks in the allocated extents that are not currently used for storing data (free space inside the segment).
     * `Unused Bytes` — bytes corresponding to unused blocks.
     * `Last Used File ID` / `Last Used Block ID` / `Last Used Block` — positions of the last used block in the segment (helpful to see last allocated area).
   * Interpretation:

     * If `Unused Blocks` is large compared to `Total Blocks` (for example > 20-30%), the table is fragmented or has a lot of empty space that could be reclaimed.
     * If `Unused Blocks` is small (0 or tiny), fragmentation is not significant.

3. **USER_SEGMENTS**

   * Shows the segment-level allocation: `BYTES` and `BLOCKS`. This is the total space Oracle has allocated to the table (all extents combined).

4. **USER_EXTENTS**

   * Lists each extent for the table: `file_id`, `block_id`, `blocks`, `bytes`. This shows how many extents the table has and whether there are many small extents (many small extents can indicate fragmentation).
   * Ordering by `file_id, block_id` helps see physical distribution.

5. **Optional DBA_FREE_SPACE**

   * If you have the privilege, `DBA_FREE_SPACE` shows free space in tablespaces; useful to see whether free space is available to grow or for coalescing.

---

### Example (mock) output and how to read it

When you run the script, you might see `DBMS_OUTPUT` like:

```
--- DBMS_SPACE.UNUSED_SPACE output ---
Total Blocks        : 8
Total Bytes         : 65536
Unused Blocks       : 6
Unused Bytes        : 49152
Last Used File ID   : 1
Last Used Block ID  : 12345
Last Used Block     : 3
```

And `USER_EXTENTS` might list:

```
FILE_ID  BLOCK_ID    BLOCKS   BYTES
1        12345       8        65536
```

Interpretation:

* The table has one extent of 8 blocks (for example, 8 * 8K = 64KB).
* Only 2 blocks are used (Total 8 - Unused 6 = 2 used blocks). That means most allocated space is unused → candidate for shrink/reclaim.

---

### Actions to fix fragmentation (choose depending on your environment)

**If the table uses ASSM (automatic segment space management) and you can enable row movement:**

```sql
ALTER TABLE author ENABLE ROW MOVEMENT;
ALTER TABLE author SHRINK SPACE CASCADE;  -- cascade also compacts dependent objects (indexes)
```

* `SHRINK SPACE` compacts data and releases high-numbered blocks back to the tablespace. Use with care: it may generate some undo and is online for ASSM tables (Oracle 10g+).

**If `SHRINK` is not supported / table not ASSM or you prefer offline move:**

```sql
ALTER TABLE author MOVE;
-- If there are indexes, rebuild them afterwards
ALTER INDEX <index_name> REBUILD;
```

* `MOVE` recreates the table in a new location with no fragmentation but invalidates dependent indexes (you must rebuild them).

**If many small extents are the problem (created by bad storage parameters):**

* Consider creating the table with larger extent sizes or use locally-managed tablespaces (LMT) and ASSM.

**Index fragmentation:**

* For indexes, use `ALTER INDEX ... REBUILD;` or `ALTER INDEX ... COALESCE;`.

**Important caution**

* `ALTER TABLE ... MOVE` and `ALTER INDEX ... REBUILD` generate undo and may cause locking or require downtime depending on options. Test in non-production first.
* Always take backups or ensure recoverability before mass moves/rebuilds.

---

### Quick checklist for DBAs

1. Run `DBMS_SPACE.UNUSED_SPACE` and check `% unused = (unused_blocks / total_blocks) * 100`.
2. If `% unused` is low (< 10%), ignore — not worth action. If high (> 20–30%), consider reclamation.
3. Check table type and tablespace (ASSM? LMT?). Prefer `SHRINK` for ASSM; use `MOVE` + index rebuild for non-ASSM.
4. For indexes, run `ALTER INDEX ... REBUILD`.
5. Monitor undo and I/O; schedule maintenance windows for large tables.

---
