-- exp user01/user01@localhost:1521/xepdb1 file=user01_schema.dmp log=user01_export.log owner=user01 rows=y indexes=y grants=y triggers=y constraints=y

-- 1. Full Database Export

exp system/manager@localhost:1521/xepdb1 \
    file=full_db.dmp \
    log=full_db_export.log \
    full=y \
    rows=y \
    indexes=y \
    grants=y \
    triggers=y \
    constraints=y \
    compress=n


-- 2.Schema Level Export

exp user01/user01@localhost:1521/xepdb1 \
    file=user01_schema.dmp \
    log=user01_export.log \
    owner=user01 \
    rows=y \
    indexes=y \
    grants=y \
    triggers=y \
    constraints=y