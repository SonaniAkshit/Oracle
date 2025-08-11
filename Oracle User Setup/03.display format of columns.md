## **1️⃣ Basic Syntax**

```sql
COLUMN column_name FORMAT format_model
```

---

## **2️⃣ Example – Set Character Column Width**

```sql
COLUMN username FORMAT A15
COLUMN default_tablespace FORMAT A20
```

* `A15` → display width of 15 characters
* Any value longer will be **truncated** in the display (not in the database).

---

## **3️⃣ Example – Format Numbers**

```sql
COLUMN size_mb FORMAT 999,999.99
```

* `999,999.99` → adds commas and shows 2 decimal places.

---

## **4️⃣ Example – Date Format**

```sql
COLUMN created FORMAT A20
```

or for custom date formatting:

```sql
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
```

---

## **5️⃣ Apply While Viewing Tablespace & Datafile Info**

```sql
COLUMN tablespace_name FORMAT A15
COLUMN file_name FORMAT A60
COLUMN size_mb FORMAT 999,999.99

SELECT tablespace_name, file_name, bytes/1024/1024 AS size_mb
FROM dba_data_files;
```

---

💡 **Tips**:

* `COLUMN` formatting is **session-only** (reset when you exit SQL\*Plus).
* To remove formatting:

```sql
CLEAR COLUMNS
```

* If you use **SQL Developer** instead of SQL\*Plus, column formatting is done via **GUI column resizing**, not with the `COLUMN` command.

---

If you want, I can give you a **ready-made SQL\*Plus script** that sets nice formatting for **tablespace + datafile reports** so it always looks clean.
Do you want me to prepare that?
