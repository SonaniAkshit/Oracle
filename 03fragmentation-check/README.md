## **1. Fragmentation in Oracle Database**

**Definition:**
Fragmentation happens when the physical storage of a table or index becomes inefficient, causing wasted space or poor performance. It usually appears after lots of **INSERT, UPDATE, and DELETE** operations.

### **Types of Fragmentation**

1. **Table Fragmentation**

   * Caused when rows are inserted and deleted often.
   * Empty space (holes) gets created inside blocks that are not reused efficiently.
   * Leads to more blocks being read for the same data.

2. **Index Fragmentation**

   * Occurs when index entries are deleted or updated frequently.
   * The index structure may have “dead” space, making lookups slower.

3. **Tablespace Fragmentation**

   * Free extents (chunks of space) are scattered all over the tablespace.
   * New objects may not find a continuous extent, leading to performance issues.

---

### **How to Identify Fragmentation**

* **Table Fragmentation**

  ```sql
  SELECT table_name, blocks, empty_blocks, chain_cnt
  FROM user_tables
  WHERE table_name = 'STUDENT';
  ```

* **Index Fragmentation**

  ```sql
  ANALYZE INDEX idx_name VALIDATE STRUCTURE;
  SELECT HEIGHT, DEL_LF_ROWS, LF_ROWS
  FROM index_stats;
  ```

---

### **Fix Fragmentation**

* **Tables**

  * `ALTER TABLE table_name MOVE;`  → moves the table to fresh blocks
  * `ALTER TABLE table_name SHRINK SPACE;` (with ASSM tablespaces)
  * Export/Import the table (for full cleanup)

* **Indexes**

  * `ALTER INDEX idx_name REBUILD;`
  * `ALTER INDEX idx_name COALESCE;`

* **Tablespace**

  * Use locally managed tablespaces with automatic segment space management (ASSM) to reduce fragmentation.
  * Resize or reorganize datafiles if needed.

---

## **2. Row Chaining and Row Migration**

These are often confused but are different:

### **Row Chaining**

* **What:** When a single row is too large to fit into one data block.
* **Cause:** Wide tables with many columns or large datatypes (e.g., `LONG`, `CLOB`, `BLOB`).
* **Effect:** Oracle splits the row across multiple blocks → extra I/O to fetch the row.

### **Row Migration**

* **What:** When a row initially fits in a block but grows too large after an update.
* **Cause:** Update increases row size, and the block doesn’t have enough free space (PCTFREE too small).
* **Effect:** Row is moved to another block, but the original block still holds a pointer → causes extra I/O.

---

### **Detect Chained or Migrated Rows**

```sql
ANALYZE TABLE student COMPUTE STATISTICS;

SELECT table_name, chain_cnt
FROM user_tables
WHERE table_name = 'STUDENT';

```

---

### **Fixing Row Chaining/Migration**

* **For Row Chaining**

  * Normalize table design (split very wide tables).
  * Avoid very large datatypes in frequently accessed tables.

* **For Row Migration**

  * Rebuild the table: `ALTER TABLE student MOVE;`
  * Adjust **PCTFREE** so updates have room to expand rows.
  * Use `SHRINK SPACE` to reclaim space.

---

## **3. Best Practices to Avoid Fragmentation & Chaining**

* Use **locally managed tablespaces** with **ASSM**.
* Set **PCTFREE** properly (higher if rows update often).
* Regularly monitor `DBA_TABLES.CHAIN_CNT`.
* Rebuild heavily fragmented indexes.
* For large objects, use **securefile LOBs** or keep them in separate tablespaces.

---

👉 In short:

* **Fragmentation** = wasted space due to deletes/inserts.
* **Row Chaining** = row too big for one block.
* **Row Migration** = row moved because of update, original block keeps a pointer.

---

**step-by-step lab** with SQL that you can run in Oracle.
We’ll build one demo table `FRAGDEMO` and show both **fragmentation** and **chained rows**.

---

# **Part 1: Fragmentation Demo**

### 1. Create Table

```sql
DROP TABLE fragdemo PURGE;

CREATE TABLE fragdemo (
    id NUMBER,
    name VARCHAR2(100)
)
TABLESPACE users
STORAGE (INITIAL 10K NEXT 20K PCTINCREASE 0);
```

---

### 2. Create Fragmentation Scenario

* Insert rows, then delete many of them to create “holes” inside blocks.

```sql
BEGIN
  FOR i IN 1..1000 LOOP
    INSERT INTO fragdemo VALUES (i, RPAD('A',100,'A'));
  END LOOP;
  COMMIT;
END;
/

-- Delete every alternate row
DELETE FROM fragdemo WHERE MOD(id,2)=0;
COMMIT;
```
#### How to check what happened (useful queries)
```sql
-- total rows
SELECT COUNT(*) FROM fragdemo;

-- verify deleted evens are gone
SELECT COUNT(*) FROM fragdemo WHERE MOD(id,2) = 0;

-- basic table stats
ANALYZE TABLE fragdemo COMPUTE STATISTICS;
SELECT table_name, blocks, empty_blocks, chain_cnt
FROM user_tables
WHERE table_name = 'FRAGDEMO';

-- segment info
SELECT segment_name, bytes/1024/1024 AS mb_allocated, blocks
FROM user_segments
WHERE segment_name = 'FRAGDEMO';

```

Now blocks have free space inside, but not efficiently reusable → **fragmentation**.

---

### 3. Analyze Fragmentation

```sql
ANALYZE TABLE fragdemo COMPUTE STATISTICS;

SELECT table_name, blocks, empty_blocks, chain_cnt
FROM user_tables
WHERE table_name = 'FRAGDEMO';
```

* `BLOCKS` = total blocks allocated
* `EMPTY_BLOCKS` = completely empty blocks
* **If BLOCKS > actual needed rows → fragmentation**

---

### 4. Solve Fragmentation

Option 1: Move the table

```sql
ALTER TABLE fragdemo MOVE;
```

Option 2: Shrink space (if ASSM tablespace)

```sql
ALTER TABLE fragdemo ENABLE ROW MOVEMENT;
ALTER TABLE fragdemo SHRINK SPACE;
```

---

### 5. Re-Analyze

```sql
ANALYZE TABLE fragdemo COMPUTE STATISTICS;

SELECT table_name, blocks, empty_blocks, chain_cnt
FROM user_tables
WHERE table_name = 'FRAGDEMO';
```

You should see **fewer blocks used** now.

---

# **Part 2: Chained Row Demo**

### 1. Create Table for Chaining

We’ll use a **small block size effect** by forcing long rows.

```sql
DROP TABLE chain_demo PURGE;

CREATE TABLE chain_demo (
    id NUMBER,
    big_col VARCHAR2(4000)
);
```

---

### 2. Insert Rows that Cause Chaining

```sql
INSERT INTO chain_demo VALUES (1, RPAD('X', 4000, 'X'));
INSERT INTO chain_demo VALUES (2, RPAD('Y', 4000, 'Y'));
COMMIT;
```

Since Oracle block is usually 8K, and row overhead + other data doesn’t let 4000 bytes fit neatly, some rows will be **chained across multiple blocks**.

---

### 3. Analyze Chained Rows

First, update stats:

```sql
ANALYZE TABLE chain_demo COMPUTE STATISTICS;

SELECT table_name, chain_cnt
FROM user_tables
WHERE table_name = 'CHAIN_DEMO';
```

* `CHAIN_CNT` > 0 → some rows are chained/migrated.

---

### 4. Solve Chained Rows

* **Row Chaining** cannot always be avoided (row too big for a block).
* Solutions:

  * Normalize design (split wide row into child tables).
  * Use LOBs (`CLOB`, `BLOB`) for very large columns.
  * Increase `PCTFREE` to reduce migration.

For our test:

```sql
-- Redesign: move big column into a CLOB
CREATE TABLE chain_demo2 (
    id NUMBER,
    big_col CLOB
);

INSERT INTO chain_demo2
SELECT * FROM chain_demo;
COMMIT;
```

---

### 5. Re-Analyze

```sql
ANALYZE TABLE chain_demo2 COMPUTE STATISTICS;

SELECT table_name, chain_cnt
FROM user_tables
WHERE table_name LIKE 'CHAIN_DEMO%';
```

* You’ll see **CHAIN\_CNT reduced**, since LOB storage avoids normal row chaining.

---

✅ **Summary:**

* **Fragmentation demo**: Insert → Delete → Analyze → Shrink → Re-analyze.
* **Chained row demo**: Insert big rows → Analyze → Redesign with CLOB → Re-analyze.

---