# 📘 VARRAY in Oracle SQL

This project demonstrates how to use **VARRAY (Variable-size array)** data type in Oracle SQL to store and manage multiple marks for each student.
The code defines a **custom collection type**, creates a table that uses it, and provides **stored procedures** for inserting, updating, retrieving, and deleting student records.

---

## 📖 What is a VARRAY?

A **VARRAY (Variable-size Array)** is an Oracle collection type that can hold a fixed maximum number of elements in a **single database column**.
It allows you to store multiple related values together, such as a list of marks, phone numbers, or scores.

### ✅ Key Points:

* VARRAY must have a **maximum size** defined at creation.
* Elements are **stored in order** (index starts from 1).
* Useful when you know the maximum number of items and want to store them together as one field.

### 🔹Definition:

Write a procedure to update, delete and insert new element in varray.

### Example:

```sql
TYPE marks_varray IS VARRAY(5) OF NUMBER(3);
```

This defines a `marks_varray` that can store **up to 5 numbers**, each having up to **3 digits**.

---

## 🧩 Database Setup

### 1. Create the VARRAY Type

```sql
CREATE OR REPLACE TYPE marks_varray IS VARRAY(5) OF NUMBER(3);
/
```

This defines a reusable data type for holding up to five marks.

### 2. Create the Student Table

```sql
CREATE TABLE student (
    roll_no NUMBER PRIMARY KEY,
    name    VARCHAR2(50),
    marks   marks_varray
)
TABLESPACE users
STORAGE (INITIAL 5K NEXT 10K);
```

The `marks` column is of type `marks_varray`.
Each record will store a student’s roll number, name, and a set of five marks.

---

## ⚙️ Stored Procedures

### 1. **Insert Student**

Adds a new student with 5 marks. If the roll number already exists, it skips insertion.

```sql
EXEC insert_student(1, 'Akshit', 78, 85, 92, 88, 90);
```

**Output Example:**

```
new student inserted with roll no 1
```

---

### 2. **Update Student Marks**

Updates all 5 marks for an existing student.

```sql
EXEC update_student(1, 80, 89, 90, 92, 88);
```

**Output Example:**

```
marks updated for roll no 1
```

---

### 3. **Select Student Marks by Name**

Displays all marks of a student by their name.

```sql
EXEC select_student('Akshit');
```

**Output Example:**

```
marks for student Akshit:
  subject 1: 80
  subject 2: 89
  subject 3: 90
  subject 4: 92
  subject 5: 88
```

---

### 4. **Delete Student by Name**

Removes a student’s record from the table.

```sql
EXEC delete_student('Akshit');
```

**Output Example:**

```
student Akshit deleted.
```

---

## 🧠 How to Run This Code

### Prerequisites:

* Oracle Database (any version supporting PL/SQL)
* SQL*Plus or SQL Developer

### Steps:

1. **Open SQL*Plus or SQL Developer.**
2. **Connect** to your Oracle user/schema.
3. **Copy and paste** the entire script into the editor and execute it.
4. **Enable output** (in SQL*Plus):

   ```sql
   SET SERVEROUTPUT ON;
   ```
5. **Run the procedures** interactively using:

   ```sql
   EXEC insert_student(&roll_no, '&name', &m1, &m2, &m3, &m4, &m5);
   EXEC update_student(&roll_no, &m1, &m2, &m3, &m4, &m5);
   EXEC select_student('&name');
   EXEC delete_student('&name');
   ```

   The ampersands (`&`) prompt you for input values during execution.

---

## 📂 Example Workflow

```sql
-- Insert a new record
EXEC insert_student(101, 'Ram', 76, 85, 89, 91, 87);

-- Update marks
EXEC update_student(101, 80, 88, 90, 93, 89);

-- View marks
EXEC select_student('Ram');

-- Delete record
EXEC delete_student('Ram');
```

---

## 🧾 Notes

* The `marks_varray` can store **exactly 5 marks** per student.
* If you need more or fewer marks, modify the `VARRAY(5)` size and related procedures.
* `DBMS_OUTPUT.PUT_LINE` displays messages; ensure `SERVEROUTPUT` is enabled.
* This script is ideal for **learning PL/SQL collections** and **procedural database programming**.

---

## 🏁 Summary

| Procedure        | Purpose                           | Example Call                                          |
| ---------------- | --------------------------------- | ----------------------------------------------------- |
| `insert_student` | Insert a new student record       | `EXEC insert_student(1, 'John', 90, 85, 88, 92, 95);` |
| `update_student` | Update marks for existing student | `EXEC update_student(1, 91, 86, 89, 93, 96);`         |
| `select_student` | View marks by student name        | `EXEC select_student('John');`                        |
| `delete_student` | Delete student record             | `EXEC delete_student('John');`                        |

---