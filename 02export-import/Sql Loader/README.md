# **SQL\*Loader?**

SQL\*Loader is an Oracle utility that allows you to **load external data files into database tables**. It is useful when you have data stored outside Oracle (like CSV, TXT, or other flat files) and you want to quickly insert it into tables.

You provide:

1. **A control file (.ctl)** → tells Oracle how to read the file.
2. **A data file (.csv / .txt / etc.)** → contains the actual data.
3. **A log file** → shows results of loading.

Then you run the loader with:

```bash
sqlldr userid=username/password@dbname control=file.ctl log=file.log
```

---

# **What Data Formats Can SQL\*Loader Load?**

SQL\*Loader supports several types of external data:

1. **Delimited data** → e.g., CSV (comma-separated), TXT (pipe `|` separated).
2. **Fixed-width data** → columns are defined by position, not by delimiters.
3. **Stream, Variable, and Binary data** → more advanced formats.

Most common use cases: **CSV** and **TXT**.

---

# **Example 1: Loading CSV Data**

### Step 1: Create Table

```sql
CREATE TABLE student_csv (
    student_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(50),
    enrolment_no    VARCHAR2(20),
    department      VARCHAR2(50),
    stream          VARCHAR2(50)
);
```

### Step 2: Create Data File (student.csv)

```csv
1,Akshit,ENR001,Computer Science,MCA
2,Ravi,ENR002,Computer Science,BCA
3,Neha,ENR003,Electronics,BTech
4,Amit,ENR004,Mechanical,BE
5,Kiran,ENR005,Civil,BE
6,Divya,ENR006,Information Tech,BSc
7,Vikas,ENR007,Mathematics,MSc
8,Pooja,ENR008,Physics,MSc
9,Manish,ENR009,Chemistry,MSc
10,Reena,ENR010,Biotechnology,BSc
```

### Step 3: Control File (student\_csv.ctl)

```ctl
LOAD DATA
INFILE 'student.csv'
INTO TABLE student_csv
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
 student_id     INTEGER EXTERNAL,
 name           CHAR,
 enrolment_no   CHAR,
 department     CHAR,
 stream         CHAR
)
```

### Step 4: Run SQL\*Loader

```bash
sqlldr userid=your_user/your_pass@orcl control=student_csv.ctl log=student_csv.log
```

---

# **Example 2: Loading TXT Data (Pipe-delimited)**

### Step 1: Create Table

```sql
CREATE TABLE student_txt (
    student_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(50),
    enrolment_no    VARCHAR2(20),
    department      VARCHAR2(50),
    stream          VARCHAR2(50)
);
```

### Step 2: Create Data File (student.txt)

```
1|Akshit|ENR001|Computer Science|MCA
2|Ravi|ENR002|Computer Science|BCA
3|Neha|ENR003|Electronics|BTech
4|Amit|ENR004|Mechanical|BE
5|Kiran|ENR005|Civil|BE
6|Divya|ENR006|Information Tech|BSc
7|Vikas|ENR007|Mathematics|MSc
8|Pooja|ENR008|Physics|MSc
9|Manish|ENR009|Chemistry|MSc
10|Reena|ENR010|Biotechnology|BSc
```

### Step 3: Control File (student\_txt.ctl)

```ctl
LOAD DATA
INFILE 'student.txt'
INTO TABLE student_txt
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
(
 student_id     INTEGER EXTERNAL,
 name           CHAR,
 enrolment_no   CHAR,
 department     CHAR,
 stream         CHAR
)
```

### Step 4: Run SQL\*Loader

```bash
sqlldr userid=your_user/your_pass@orcl control=student_txt.ctl log=student_txt.log
```

---

# **What SQL\*Loader Can Load**

* **Delimited text files**: CSV, TXT, tab-delimited, pipe-delimited, etc.
* **Fixed-width files**: where fields are in fixed positions (e.g., first 10 chars = student\_id).
* **Data streams** with variable length records.
* **Binary files** (with proper control file setup).

❌ It **cannot directly load JSON or XML** as structured data. For those, Oracle provides **External Tables** and **JSON/XML functions**.

---

✅ That’s the **end-to-end flow**: what SQL\*Loader is, supported formats, two working examples (CSV + TXT), and what it can/can’t load.