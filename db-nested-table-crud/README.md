
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

Got it! Let’s rewrite **simple CRUD procedures** for your `student_results` table using the **nested table for subjects** and **VARRAY for marks.**

---

## 1. Insert Student Procedure

```sql
create or replace procedure insert_student_result(
    p_student_id in number,
    p_name       in varchar2,
    p_sub1       in varchar2,
    p_sub2       in varchar2,
    p_sub3       in varchar2,
    p_m1         in number,
    p_m2         in number,
    p_m3         in number
) as
    v_exists number;
begin
    select count(*) into v_exists
    from student_results
    where student_id = p_student_id;

    if v_exists = 0 then
        insert into student_results (student_id, name, subjects, marks)
        values (p_student_id, p_name, subject_list(p_sub1, p_sub2, p_sub3), marks_list(p_m1, p_m2, p_m3));

        dbms_output.put_line('New student inserted with id ' || p_student_id);
    else
        dbms_output.put_line('Student already exists with id ' || p_student_id);
    end if;
end;
/
```

---

## 2. Update Marks and Subjects Procedure

```sql
create or replace procedure update_student_result(
    p_student_id in number,
    p_sub1       in varchar2,
    p_sub2       in varchar2,
    p_sub3       in varchar2,
    p_m1         in number,
    p_m2         in number,
    p_m3         in number
) as
    v_exists number;
begin
    select count(*) into v_exists
    from student_results
    where student_id = p_student_id;

    if v_exists = 0 then
        dbms_output.put_line('Student not found with id ' || p_student_id);
    else
        update student_results
        set subjects = subject_list(p_sub1, p_sub2, p_sub3),
            marks = marks_list(p_m1, p_m2, p_m3)
        where student_id = p_student_id;

        dbms_output.put_line('Subjects and marks updated for student_id ' || p_student_id);
    end if;
end;
/
```

---

## 3. Select Student Procedure

```sql
create or replace procedure select_student_result(
    p_name in varchar2
) as
    v_subjects subject_list;
    v_marks    marks_list;
begin
    select subjects, marks into v_subjects, v_marks
    from student_results
    where name = p_name;

    dbms_output.put_line('Student: ' || p_name);
    for i in 1 .. v_subjects.count loop
        dbms_output.put_line('  Subject: ' || v_subjects(i) || ' - Mark: ' || v_marks(i));
    end loop;

exception
    when no_data_found then
        dbms_output.put_line('Student not found with name ' || p_name);
end;
/
```

---

## 4. Delete Student Procedure

```sql
create or replace procedure delete_student_result(
    p_name in varchar2
) as
begin
    delete from student_results where name = p_name;

    if sql%rowcount > 0 then
        dbms_output.put_line('Student ' || p_name || ' deleted.');
    else
        dbms_output.put_line('No student found with name ' || p_name);
    end if;
end;
/
```

---

## 5. Example Execution

***Method:1***
```sql
-- Insert a student
exec insert_student_result(1, 'akshit', 'c', 'c++', 'python', 85, 90, 78);
exec insert_student_result(2, 'sunny', 'c', 'c++', 'python', 80, 70, 75);

-- Update student
exec update_student_result(1, 'C', 'C++', 'Python', 95, 85, 90);

-- Select student marks
exec select_student_result('akshit');

-- Delete student
exec delete_student_result('sunny');
```

***Method:2***
```sql
-- 1. Insert Student (prompt for input)

exec insert_student_result(&student_id,'&name','&sub1','&sub2','&sub3',&m1,&m2,&m3);

-- 2. Update Student
exec update_student_result(&student_id,'&sub1','&sub2','&sub3',&m1,&m2,&m3);

-- 3. Select Student by Name
exec select_student_result('&name');

-- 4. Delete Student by Name
exec delete_student_result('&name');
```

---

✅ This setup provides:

1. **Nested table** for subjects
2. **VARRAY** for marks
3. Simple **insert, update, select, delete** procedures
4. Output using `dbms_output.put_line`

---
