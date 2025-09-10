1. **Full Database Export**
2. **Schema Level Export**
3. **Table Level Export**

## 🔹 1. **Full Database Export**

Exports everything in the database (all users, schemas, data, metadata).

```bash
exp system/password@localhost:1521/xepdb1 \
    file=full_db.dmp \
    log=full_db_export.log \
    full=y \
    rows=y \
    indexes=y \
    grants=y \
    triggers=y \
    constraints=y \
    compress=n
```

**Key parameters**

* `full=y` → exports the entire database
* `file` → dump file name
* `log` → log file for export messages
* `rows=y` → include table data (if `n`, only structure)
* `indexes=y` → include indexes
* `constraints=y` → include constraints (PK, FK, etc.)
* `triggers=y` → include triggers
* `grants=y` → include object/user grants
* `compress=n` → do not compress extents, makes import faster

---

## 🔹 2. **Schema Level Export**

Exports only the objects that belong to a particular user/schema.

```bash
exp user01/user01@localhost:1521/xepdb1 \
    file=user01_schema.dmp \
    log=user01_export.log \
    owner=user01 \
    rows=y \
    indexes=y \
    grants=y \
    triggers=y \
    constraints=y
```

**Key parameter**

* `owner=user01` → exports the given schema’s objects

This is the **command you already wrote**.

---

## 🔹 3. **Table Level Export**

Exports only specific tables (and optionally data, indexes, constraints).

```bash
exp user01/user01@localhost:1521/xepdb1 \
    file=user01_tables.dmp \
    log=user01_tables_export.log \
    tables=(EMP,DEPT) \
    rows=y \
    indexes=y \
    grants=y \
    triggers=y \
    constraints=y
```

**Key parameter**

* `tables=(EMP,DEPT)` → exports only these tables

---

## ✅ Summary of Useful Parameters (for all 3 methods)

| Parameter       | Purpose                                                          |
| --------------- | ---------------------------------------------------------------- |
| `file`          | Dump file name (can be multiple with `file=(f1.dmp,f2.dmp)`)     |
| `log`           | Log file to record export details                                |
| `full=y`        | Export entire database                                           |
| `owner`         | Export specific schema(s)                                        |
| `tables`        | Export specific tables                                           |
| `rows=y`        | Include data (not just structure)                                |
| `indexes=y`     | Include indexes                                                  |
| `constraints=y` | Include constraints (PK, FK, check)                              |
| `triggers=y`    | Include triggers                                                 |
| `grants=y`      | Include object privileges                                        |
| `compress=n`    | Don’t compress storage, faster import                            |
| `consistent=y`  | Ensures read-consistent export (all rows from one point in time) |

---