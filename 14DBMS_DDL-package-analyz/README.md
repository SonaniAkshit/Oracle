# Objective

Analyze cluster, tables and indexes in your schema using the `DBMS_DDL.ANALYZE_OBJECT` API and verify statistics were recorded.

### Purpose

* Produce optimizer statistics for clustered and non-clustered objects so the optimizer can make better execution plans.
* Demonstrate how to analyze clusters, tables and indexes programmatically.
* Show how to confirm statistics using `USER_TABLES`, `USER_INDEXES` and `USER_TAB_STATISTICS`.

### Explanation of each script block

1. **Create cluster**

   ```sql
   CREATE CLUSTER emp_dept_cluster (deptno NUMBER(5)) SIZE 1024;
   ```

   Creates a cluster that stores rows from multiple tables together based on the `deptno` key. Clusters can improve join performance for co-located rows but add complexity.

2. **Create index on cluster**

   ```sql
   CREATE INDEX emp_dept_cluster_idx ON CLUSTER emp_dept_cluster;
   ```

   Cluster index is needed to access rows in the cluster.

3. **Create tables inside cluster**

   ```sql
   CREATE TABLE department (...) CLUSTER emp_dept_cluster (deptno);
   CREATE TABLE employee   (...) CLUSTER emp_dept_cluster (deptno);
   ```

   Tables stored in the cluster share storage keyed by `deptno`.

4. **Create normal (heap) table and index**

   ```sql
   CREATE TABLE author1 (...);
   CREATE INDEX author_idx ON author1(author_id);
   ```

   A normal non-clustered table and an index to compare stats behavior.

5. **Insert sample data**
   Adds a few rows to make statistics meaningful.

6. **Analyze objects with `DBMS_DDL.ANALYZE_OBJECT`**

   ```plsql
   DBMS_DDL.ANALYZE_OBJECT(type => 'TABLE'|'INDEX'|'CLUSTER', schema => USER, name => 'OBJ', method => 'COMPUTE');
   ```

   `method => 'COMPUTE'` collects basic statistics (row counts, blocks). This uses the older `ANALYZE` mechanism via `DBMS_DDL`. The script runs it for cluster, tables and indexes.

7. **Verify statistics**

   * `USER_TABLES` — shows `NUM_ROWS`, `BLOCKS`, `LAST_ANALYZED`.
   * `USER_INDEXES` — shows `DISTINCT_KEYS`, `LEAF_BLOCKS`, `LAST_ANALYZED`.
   * `USER_TAB_STATISTICS` — alternative place to view collected stats for tables/partitions (may show cluster-related combined stats).

### Expected output

* `DBMS_OUTPUT` lines confirming analysis completion for each object.
* `USER_TABLES` rows with `LAST_ANALYZED` populated and `NUM_ROWS` reflecting the inserted rows.
* `USER_INDEXES` rows with `LAST_ANALYZED` populated.

### Important notes & best practice (must-know for exam / production)

* `ANALYZE` and `DBMS_DDL.ANALYZE_OBJECT` are older methods; **the recommended modern approach is `DBMS_STATS`** (e.g., `DBMS_STATS.GATHER_TABLE_STATS`) because it’s more comprehensive and supports incremental statistics, histograms and improved defaults.

  * Example modern command:

    ```plsql
    EXEC DBMS_STATS.GATHER_TABLE_STATS(user, 'EMPLOYEE');
    EXEC DBMS_STATS.GATHER_INDEX_STATS(user, 'EMP_DEPT_CLUSTER_IDX');
    ```
* Use `USER_TAB_STATISTICS`, `DBA_TABLES`, `DBA_INDEXES` or `DBA_TAB_STATISTICS` if you need cluster-wide/DBA-level views.
* Clusters are less common in modern designs; evaluate benefits vs complexity. Clusters can improve join performance for small, co-located datasets; they can be harmful if used incorrectly.
* When running on large production objects, prefer `DBMS_STATS` with appropriate options (`estimate_percent`, `cascade`, `degree`) rather than `ANALYZE`.

### Troubleshooting

* If `LAST_ANALYZED` remains `NULL`, ensure you committed after analyze (script does implicit commit) and that you analyzed the correct schema and object names (case sensitivity: unquoted names are upper-cased).
* Check `USER_ERRORS` only for compile errors (not relevant here).
* If you need sample data for real testing, insert more rows to simulate production workloads before running stats.

---