-- imp user02/user02@localhost:1521/xepdb1 file=user01_schema.dmp log=user01_import.log fromuser=user01 touser=user02

-- 1.Full Database Import
imp system/manager@localhost:1521/xepdb1 \
    file=full_db.dmp \
    log=full_db_import.log \
    full=y \
    ignore=y \
    grants=y \
    indexes=y \
    rows=y \
    constraints=y \
    triggers=y

-- 2.Schema Import
imp user02/user02@localhost:1521/xepdb1 \
    file=user01_schema.dmp \
    log=user01_import.log \
    fromuser=user02 \
    touser=user01 \
    grants=y \
    indexes=y \
    rows=y \
    constraints=y \
    triggers=y \
    ignore=y

-- 3.Table Import
imp user02/user02@localhost:1521/xepdb1 \
    file=user01_tables.dmp \
    log=user01_tables_import.log \
    fromuser=user02 \
    touser=user01 \
    tables=(EMP,DEPT) \
    grants=y \
    indexes=y \
    rows=y \
    constraints=y \
    triggers=y \
    ignore=y