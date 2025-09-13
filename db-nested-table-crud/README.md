
# 📘 Nested Table + VARRAY Example in Oracle

We’ll model a **student results system** where:

* Each student has 3 subjects (nested table)
* Each subject has up to 5 marks (VARRAY)

---

## 1. What is a Nested Table?

* A **Nested Table** is a collection in Oracle that can store **multiple elements of the same type**.
* It can **grow dynamically** and is stored in a separate storage table internally.
* Allows flexible modeling of one-to-many relationships, like a student having multiple subjects.

**Example use case:** A student has multiple subjects; each subject can have multiple marks.

---

## 2. What is a VARRAY?

* A **VARRAY (Variable-Size Array)** stores **a fixed maximum number of elements**.
* The order of elements is **preserved**.
* Suitable for storing things like marks for a subject.

---

## 3. Step 1: Create Nested Table Type for Subjects

```sql
-- Nested table for subjects
create or replace type subject_list as table of varchar2(30);
/
```

---

## 4. Step 2: Create VARRAY Type for Marks

```sql
-- VARRAY for marks (up to 5 marks per subject)
create or replace type marks_list as varray(5) of number(3);
/
```

---

## 5. Step 3: Create Student Table with Nested Table & VARRAY

```sql
create table student_results (
    student_id number primary key,
    name       varchar2(50),
    subjects   subject_list,
    marks      marks_list
) nested table subjects store as subjects_storage
TABLESPACE users
STORAGE (INITIAL 5K NEXT 10K);
```

* `subjects` → nested table of subject names
* `marks` → VARRAY of marks for each subject
* Nested table is stored internally in `subjects_storage`

---

## 6. Step 4: Simple CRUD Using SQL

### 6.1 Insert

```sql
insert into student_results
values (1, 'Akshit', subject_list('Math','Science','English'), marks_list(85,90,78));

insert into student_results
values (2, 'Hemal', subject_list('Physics','Chemistry','Math'), marks_list(80,70,75));
```

---

### 6.2 Select

#### Full student table

```sql
select * from student_results;
```

#### Expand nested subjects

```sql
select s.name, t.column_value as subject
from student_results s, table(s.subjects) t;
```

#### Expand marks

```sql
select s.name, m.column_value as mark
from student_results s, table(s.marks) m;
```

#### Join subjects and marks (aligned)

```sql
select distinct s.name, sub.column_value as subject, m.column_value as mark
from student_results s,
     table(s.subjects) sub,
     table(s.marks) m;
```

> Note: In this simple model, subjects and marks are parallel arrays. Ensure they have same length.

---

### 6.3 Update

```sql
update student_results
set subjects = subject_list('c','c++','python'),
    marks = marks_list(95,85,90)
where student_id = 1;
```

---

### 6.4 Delete

```sql
delete from student_results where student_id = 2;
```

---

### 7 CRUD with Stored Procedure

**extend the `student_results` nested table** like the `book_authors` example and include **department and its course**, while keeping the **subjects and marks** structure.

---

## 1. Create Object Type for Department

```sql
CREATE OR REPLACE TYPE dept_obj AS OBJECT (
    dept_id     NUMBER,
    dept_name   VARCHAR2(50),
    course      VARCHAR2(50)
);
/
```

---

## 2. Create Nested Table Type for Departments

```sql
CREATE OR REPLACE TYPE dept_nested AS TABLE OF dept_obj;
/
```

---

## 3. Create Nested Table for Subjects (existing)

```sql
CREATE OR REPLACE TYPE subject_list AS TABLE OF VARCHAR2(30);
/ 

CREATE OR REPLACE TYPE marks_list AS VARRAY(5) OF NUMBER(3);
/ 
```

---

## 4. Create `student_results` Table with Nested Columns

```sql
CREATE TABLE student_results (
    student_id NUMBER PRIMARY KEY,
    name       VARCHAR2(50),
    department dept_nested,
    subjects   subject_list,
    marks      marks_list
) NESTED TABLE department STORE AS dept_storage
  NESTED TABLE subjects STORE AS subjects_storage
  TABLESPACE users
  STORAGE (INITIAL 5K NEXT 10K);
```

* `department` → nested table of `dept_obj` (can store multiple departments/courses per student)
* `subjects` → nested table
* `marks` → VARRAY

---

## 5. Insert Student Procedure

```sql
CREATE OR REPLACE PROCEDURE insert_student_result(
    p_student_id IN NUMBER,
    p_name       IN VARCHAR2,
    p_dept_id    IN NUMBER,
    p_dept_name  IN VARCHAR2,
    p_course     IN VARCHAR2,
    p_sub1       IN VARCHAR2,
    p_sub2       IN VARCHAR2,
    p_sub3       IN VARCHAR2,
    p_m1         IN NUMBER,
    p_m2         IN NUMBER,
    p_m3         IN NUMBER
) AS
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM student_results
    WHERE student_id = p_student_id;

    IF v_exists = 0 THEN
        INSERT INTO student_results (student_id, name, department, subjects, marks)
        VALUES (
            p_student_id, 
            p_name,
            dept_nested(dept_obj(p_dept_id, p_dept_name, p_course)),
            subject_list(p_sub1, p_sub2, p_sub3),
            marks_list(p_m1, p_m2, p_m3)
        );

        DBMS_OUTPUT.PUT_LINE('New student inserted with id ' || p_student_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Student already exists with id ' || p_student_id);
    END IF;
END;
/
```

---

## 6. Update Student Procedure

```sql
CREATE OR REPLACE PROCEDURE update_student_result(
    p_student_id IN NUMBER,
    p_dept_id    IN NUMBER,
    p_dept_name  IN VARCHAR2,
    p_course     IN VARCHAR2,
    p_sub1       IN VARCHAR2,
    p_sub2       IN VARCHAR2,
    p_sub3       IN VARCHAR2,
    p_m1         IN NUMBER,
    p_m2         IN NUMBER,
    p_m3         IN NUMBER
) AS
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM student_results
    WHERE student_id = p_student_id;

    IF v_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Student not found with id ' || p_student_id);
    ELSE
        UPDATE student_results
        SET department = dept_nested(dept_obj(p_dept_id, p_dept_name, p_course)),
            subjects   = subject_list(p_sub1, p_sub2, p_sub3),
            marks      = marks_list(p_m1, p_m2, p_m3)
        WHERE student_id = p_student_id;

        DBMS_OUTPUT.PUT_LINE('Student updated for id ' || p_student_id);
    END IF;
END;
/
```

---

## 7. Select Student Procedure

```sql
CREATE OR REPLACE PROCEDURE select_student_result(
    p_name IN VARCHAR2
) AS
    v_dept dept_nested;
    v_subjects subject_list;
    v_marks marks_list;
BEGIN
    SELECT department, subjects, marks
    INTO v_dept, v_subjects, v_marks
    FROM student_results
    WHERE name = p_name;

    DBMS_OUTPUT.PUT_LINE('Student: ' || p_name);
    
    -- Departments
    FOR i IN 1 .. v_dept.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('  Dept: ' || v_dept(i).dept_name || ' - Course: ' || v_dept(i).course);
    END LOOP;

    -- Subjects and Marks
    FOR i IN 1 .. v_subjects.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('  Subject: ' || v_subjects(i) || ' - Mark: ' || v_marks(i));
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Student not found with name ' || p_name);
END;
/
```

---

## 8. Delete Student Procedure

```sql
CREATE OR REPLACE PROCEDURE delete_student_result(
    p_name IN VARCHAR2
) AS
BEGIN
    DELETE FROM student_results WHERE name = p_name;

    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Student ' || p_name || ' deleted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No student found with name ' || p_name);
    END IF;
END;
/
```

---

## 9. Example Execution Using `&` Prompts

```sql
-- Insert student (runtime input)
exec insert_student_result(
    &student_id, '&name', &dept_id, '&dept_name', '&course',
    '&sub1', '&sub2', '&sub3', &m1, &m2, &m3
);

-- Update student
exec update_student_result(
    &student_id, &dept_id, '&dept_name', '&course',
    '&sub1', '&sub2', '&sub3', &m1, &m2, &m3
);

-- Select student by name
exec select_student_result('&name');

-- Delete student by name
exec delete_student_result('&name');
```

---

✅ **This version includes:**

1. Nested table for **departments + course**
2. Nested table for **subjects**
3. VARRAY for **marks**
4. **Insert, Update, Select, Delete** procedures
5. Runtime input using `&` substitution variables

---