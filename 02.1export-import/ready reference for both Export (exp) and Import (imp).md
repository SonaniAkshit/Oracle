# 🔹 1. Full Database Export/Import

### Export

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

### Import

```bash
imp system/password@localhost:1521/xepdb1 \
file=full_db.dmp \
log=full_db_import.log \
full=y \
ignore=y \
rows=y \
indexes=y \
grants=y \
triggers=y \
constraints=y
```

---

# 🔹 2. Schema Level Export/Import

### Export

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

### Import

(from `user01` schema → `user02` schema)

```bash
imp user02/user02@localhost:1521/xepdb1 \
file=user01_schema.dmp \
log=user01_import.log \
fromuser=user01 \
touser=user02 \
ignore=y \
rows=y \
indexes=y \
grants=y \
triggers=y \
constraints=y
```

---

# 🔹 3. Table Level Export/Import

### Export

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

### Import

```bash
imp user01/user01@localhost:1521/xepdb1 \
file=user01_tables.dmp \
log=user01_tables_import.log \
fromuser=user01 \
touser=user01 \
tables=(EMP,DEPT) \
ignore=y \
rows=y \
indexes=y \
grants=y \
triggers=y \
constraints=y
```

---

## ✅ Key Parameters Recap

| Parameter       | Purpose                                      |
| --------------- | -------------------------------------------- |
| `full=y`        | Full database export/import                  |
| `owner`         | Schema to export                             |
| `fromuser`      | Source schema in dump                        |
| `touser`        | Target schema in DB                          |
| `tables`        | Specific tables to export/import             |
| `rows=y`        | Include data                                 |
| `indexes=y`     | Include indexes                              |
| `constraints=y` | Include constraints                          |
| `triggers=y`    | Include triggers                             |
| `grants=y`      | Include object grants                        |
| `ignore=y`      | Skip errors if object already exists         |
| `compress=n`    | Avoid extent compression (better for import) |

---