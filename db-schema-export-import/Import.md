1. **Full Database Import**
2. **Schema Level Import**
3. **Table Level Import**

## 🔹 1. **Full Database Import**

Use when you exported with `full=y`.

```bash
imp system/password@localhost:1521/xepdb1 \
    file=full_db.dmp \
    log=full_db_import.log \
    full=y \
    ignore=y \
    grants=y \
    indexes=y \
    rows=y \
    constraints=y \
    triggers=y
```

**Notes**:

* `full=y` → imports everything from the dump.
* `ignore=y` → skips errors if objects already exist, avoids failures.

---

## 🔹 2. **Schema Import**

Your example: move objects from `user01` into `user02`.

```bash
imp user02/user02@localhost:1521/xepdb1 \
    file=user01_schema.dmp \
    log=user01_import.log \
    fromuser=user01 \
    touser=user02 \
    grants=y \
    indexes=y \
    rows=y \
    constraints=y \
    triggers=y \
    ignore=y
```

**Notes**:

* `fromuser=user01` → source schema in dump.
* `touser=user02` → target schema in current DB.

---

## 🔹 3. **Table Import**

Use when you exported specific tables with `tables=(...)`.

```bash
imp user01/user01@localhost:1521/xepdb1 \
    file=user01_tables.dmp \
    log=user01_tables_import.log \
    fromuser=user01 \
    touser=user01 \
    tables=(EMP,DEPT) \
    grants=y \
    indexes=y \
    rows=y \
    constraints=y \
    triggers=y \
    ignore=y
```

**Notes**:

* `tables` → specifies which tables to import.
* You can also remap `fromuser` to `touser` if needed.

---

## ✅ Useful Import Parameters

| Parameter       | Purpose                              |
| --------------- | ------------------------------------ |
| `file`          | Dump file to read                    |
| `log`           | Log file                             |
| `full=y`        | Import full database                 |
| `fromuser`      | Source schema in dump                |
| `touser`        | Target schema                        |
| `tables`        | Specific tables to import            |
| `rows=y`        | Load data (not just structure)       |
| `indexes=y`     | Import indexes                       |
| `constraints=y` | Import constraints                   |
| `triggers=y`    | Import triggers                      |
| `grants=y`      | Import grants                        |
| `ignore=y`      | Skip errors if object already exists |

---