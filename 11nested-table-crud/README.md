# 🎓 Object, Nested Table, and VARRAY in Oracle SQL

This project demonstrates advanced **Oracle collection types** — **Object Type**, **Nested Table**, and **VARRAY** — to manage detailed student records.  
Each student has personal info, a department object, a list of subjects, and a set of marks — all stored in structured collection types.

---

## 📘 Overview

This example shows how to:
- Create an **object type** for department details.  
- Use a **nested table** for department and subject lists.  
- Use a **VARRAY** for marks.  
- Build a main table (`student_results`) using these collection types.  
- Perform **Insert, Update, Select, Delete** operations via PL/SQL procedures.

---

## 🔹Definition:

Write a procedure to update, delete and insert new element in nested table.

## 🧱 Data Model

### 1. Department Object
Defines the structure for department information.

```sql
CREATE OR REPLACE TYPE dept_obj AS OBJECT (
    dept_id     NUMBER,
    dept_name   VARCHAR2(50),
    course      VARCHAR2(50)
);
/
```

### 2. Nested Table for Departments

Holds one or more `dept_obj` entries.

```sql
CREATE OR REPLACE TYPE dept_nested AS TABLE OF dept_obj;
/
```

### 3. Nested Table for Subjects

Stores a list of subjects per student.

```sql
CREATE OR REPLACE TYPE subject_list AS TABLE OF VARCHAR2(30);
/
```

### 4. VARRAY for Marks

Stores up to 5 marks per student.

```sql
CREATE OR REPLACE TYPE marks_list AS VARRAY(5) OF NUMBER(3);
/
```

---

## 🧩 Main Table Definition

```sql
CREATE TABLE student_results (
    student_id NUMBER PRIMARY KEY,
    name       VARCHAR2(50),
    department dept_nested,
    subjects   subject_list,
    marks      marks_list
)
NESTED TABLE department STORE AS dept_storage
NESTED TABLE subjects STORE AS subjects_storage
TABLESPACE users
STORAGE (INITIAL 5K NEXT 10K);
```

### Explanation:

* `department` and `subjects` are **nested tables** stored separately in dedicated storage tables.
* `marks` is a **VARRAY**, stored inline with the main record.
* `TABLESPACE` and `STORAGE` control where and how data is physically stored.

---

## ⚙️ Stored Procedures

### 1. **Insert Student Result**

Adds a new student with department info, subjects, and marks.

```sql
EXEC insert_student_result(1, 'Riya', 101, 'Computer Science', 'BCA', 'DBMS', 'DSA', 'SQL', 88, 90, 92);
```

**Output:**

```
new student inserted with id 1
```

---

### 2. **Update Student Result**

Updates department, subjects, and marks for an existing student.

```sql
EXEC update_student_result(1, 101, 'Computer Science', 'BCA', 'DBMS', 'AI', 'Python', 90, 95, 93);
```

**Output:**

```
student updated for id 1
```

---

### 3. **Select Student Result**

Displays department, subjects, and marks for a student by name.

```sql
EXEC select_student_result('Riya');
```

**Output:**

```
student: Riya
  dept: Computer Science - course: BCA
  subject: DBMS - mark: 90
  subject: AI - mark: 95
  subject: Python - mark: 93
```

---

### 4. **Delete Student Result**

Deletes a student record by name.

```sql
EXEC delete_student_result('Riya');
```

**Output:**

```
student Riya deleted.
```

---

## 🧠 How to Run This Code

### Requirements

* Oracle Database (supports PL/SQL, Nested Tables, and Object Types)
* SQL*Plus or Oracle SQL Developer

### Steps

1. Open **SQL Developer** or **SQL*Plus**.
2. Connect to your Oracle user/schema.
3. Copy and execute the entire script.
4. Enable server output:

   ```sql
   SET SERVEROUTPUT ON;
   ```
5. Run procedures interactively:

   ```sql
   EXEC insert_student_result(&student_id, '&name', &dept_id, '&dept_name', '&course', '&sub1', '&sub2', '&sub3', &m1, &m2, &m3);
   EXEC update_student_result(&student_id, &dept_id, '&dept_name', '&course', '&sub1', '&sub2', '&sub3', &m1, &m2, &m3);
   EXEC select_student_result('&name');
   EXEC delete_student_result('&name');
   ```

   Each `&` prompts you to enter input at runtime.

---

## 📂 Example Workflow

```sql
-- Insert
EXEC insert_student_result(101, 'Akshit', 10, 'IT', 'B.Tech', 'DBMS', 'Networking', 'AI', 85, 88, 90);

-- Update
EXEC update_student_result(101, 10, 'IT', 'B.Tech', 'DBMS', 'Cloud', 'ML', 90, 93, 95);

-- Select
EXEC select_student_result('Akshit');

-- Delete
EXEC delete_student_result('Akshit');
```

---

## 🧾 Notes

* The **department** and **subjects** are stored as **nested tables** in separate storage structures.
* The **marks** are stored inline using a **VARRAY** of up to 5 numbers.
* You can modify the collection sizes or add fields (like semester, grade, etc.) as needed.
* Make sure `SERVEROUTPUT` is ON to see procedure messages.
* Ideal for learning **Oracle Object-Relational features** and **advanced PL/SQL**.

---

## 🏁 Summary

| Procedure               | Purpose                     | Example Call                                                                              |
| ----------------------- | --------------------------- | ----------------------------------------------------------------------------------------- |
| `insert_student_result` | Insert a new student record | `EXEC insert_student_result(1, 'John', 101, 'CS', 'BCA', 'SQL', 'AI', 'ML', 90, 95, 92);` |
| `update_student_result` | Update student details      | `EXEC update_student_result(1, 101, 'CS', 'BCA', 'SQL', 'Python', 'AI', 88, 90, 91);`     |
| `select_student_result` | Retrieve student info       | `EXEC select_student_result('John');`                                                     |
| `delete_student_result` | Remove student record       | `EXEC delete_student_result('John');`                                                     |

---

## 🧩 Learning Outcomes

By completing this project, you’ll understand:

* How to define and use **Object Types** in Oracle.
* How **Nested Tables** differ from **VARRAYs**.
* How to combine multiple collection types in a single table.
* How to perform CRUD operations on complex data structures using PL/SQL.

---