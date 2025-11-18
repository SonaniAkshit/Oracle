# **Objective**

Schedule a background job using `DBMS_JOB` that automatically inserts five new student records into the `STUDENT` table.

## **Purpose**

* Demonstrate automated task execution in Oracle.
* Show how to create a job that runs once or repeatedly.
* Practice using sequences, stored procedures, and DBMS_JOB scheduling.

---

# 🧠 **How the System Works**

## **1. STUDENT table**

Stores basic student info:

* ID (primary key)
* Name
* Marks

Storage parameters are defined for exam purposes.

## **2. Sequence (student_seq)**

Automatically generates unique student_id values.

Example values:

```
1, 2, 3, 4, 5 ...
```

## **3. Procedure: insert_students_job**

This is the logic that DBMS_JOB will execute.
It inserts **five records** into the STUDENT table.

```sql
INSERT INTO student VALUES (student_seq.NEXTVAL, 'Ankesh', 95);
...
```

After all inserts, a `COMMIT` finalizes the changes.

---

# ⏳ **4. Submitting the Job**

### **A. Run only ONE time**

Job fires immediately and NEVER runs again.

```sql
interval => NULL
```

### **B. Run EVERY day**

Repeats once every 24 hours.

```sql
interval => 'SYSDATE + 1'
```

Oracle evaluates the interval expression after each execution.

---

# 📤 **5. Check job status**

`USER_JOBS` shows:

* job number
* next run time
* interval

Example:

```
JOB   WHAT                           NEXT_DATE        INTERVAL
----  ------------------------------  ---------------- -------------
123   BEGIN insert_students_job; END  20-NOV-25 12:30  SYSDATE+1
```

---

# 📌 **6. Check final inserted rows**

After job runs:

```sql
SELECT * FROM student ORDER BY student_id;
```

Example output:

```
STUDENT_ID   NAME     MARKS
-----------  -------  ------
1            Ankesh     95
2            Jayesh     90
3            Parth      78
4            Ram        92
5            Krishn     88
```

---

# ✔ Final Conclusion

This exercise shows how to automate repetitive data insertion using `DBMS_JOB`.
You learned how to:

* Create a table and sequence
* Write the procedure that performs the task
* Schedule one-time and recurring jobs
* Check job status
* Verify inserted data

This is exactly the style expected in DBA practicals and university exams.

---