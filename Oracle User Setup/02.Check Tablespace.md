## **1️⃣ See User’s Default Tablespace & Temporary Tablespace**

Run this as **SYS** or any account with DBA views access:

```sql
SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'MYUSER';
```

> Replace `MYUSER` with your username (uppercase, unless you created it in quotes).

---

## **2️⃣ See All Tablespaces & Their Datafiles**

```sql
SELECT tablespace_name, file_name, bytes/1024/1024 AS size_mb
FROM dba_data_files
ORDER BY tablespace_name;
```

This shows:

* **tablespace\_name** → logical storage name
* **file\_name** → actual `.dbf` file path on disk
* **size\_mb** → file size in MB

---

## **3️⃣ See Temporary Tablespace Files**

```sql
SELECT tablespace_name, file_name, bytes/1024/1024 AS size_mb
FROM dba_temp_files
ORDER BY tablespace_name;
```

---

## **4️⃣ See Which Tablespace a Specific Table Is In**

```sql
SELECT table_name, tablespace_name
FROM user_tables;
```

If you’re logged in as the owner, `user_tables` works.
If you want to check for another user’s tables:

```sql
SELECT owner, table_name, tablespace_name
FROM dba_tables
WHERE owner = 'MYUSER';
```

---

💡 **Note:**

* `dba_*` views need **DBA privileges** (e.g., SYS, SYSTEM, or `GRANT SELECT_CATALOG_ROLE`).
* The **default datafiles** in XE are usually inside:

  ```
  /opt/oracle/oradata/XE/XEPDB1/
  ```

  (on Linux)
  or

  ```
  C:\app\<user>\oradata\XE\XEPDB1\
  ```

  (on Windows).

---

If you want, I can also give you **a single query** that shows:
`username → default_tablespace → datafile path → size` in one shot.

Do you want me to prepare that?
