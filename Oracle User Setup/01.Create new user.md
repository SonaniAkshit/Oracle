## **Steps to Create a New User in Oracle 21c XE**

### 1️⃣ Connect to the Pluggable Database (PDB)

By default, 21c XE has:

* **CDB** → `XEPDB1` (Pluggable Database)
* **CDB\$ROOT** (Container Database root)

If you run `CREATE USER` in **CDB\$ROOT**, you’ll get:

```
ORA-65096: invalid common user or role name
```

So you need to connect to your **PDB**:

```sql
sqlplus sys as sysdba
```

Then:

```sql
ALTER SESSION SET CONTAINER = XEPDB1;
```

---

### 2️⃣ Create the User

```sql
CREATE USER myuser IDENTIFIED BY mypassword;
```

> Replace `myuser` and `mypassword` with your desired username and password.

---

### 3️⃣ Grant Required Privileges

At minimum:

```sql
GRANT CREATE SESSION TO myuser; -- Allows login
GRANT CREATE TABLE TO myuser;   -- Allows creating tables
GRANT UNLIMITED TABLESPACE TO myuser; -- Avoids quota issues
```

If you want full DBA access (be careful in production):

```sql
GRANT DBA TO myuser;
```

---

### 4️⃣ Test Login

Exit SQL\*Plus:

```sql
EXIT;
```

Then log in:

```bash
sqlplus myuser/mypassword@localhost/XEPDB1
```

---

✅ **Quick Recap**:

1. Always connect to **PDB** (`ALTER SESSION SET CONTAINER = XEPDB1;`)
2. `CREATE USER` in PDB
3. Grant privileges
4. Test login

---

If you want, I can also give you a **one-line shortcut** to create a PDB user without manually switching containers.

Do you want me to give that one-line command?
