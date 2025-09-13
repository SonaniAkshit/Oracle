# 📘 VARRAY in Oracle – With Examples and CRUD using Procedures

## 1. What is a VARRAY?

* **VARRAY (Variable-Size Array)** is an Oracle collection type.
* It allows you to store a **fixed maximum number** of elements (like an array in programming).
* All elements must be of the **same data type** (e.g., numbers, strings).
* Unlike nested tables, a VARRAY preserves the **order** of elements.

👉 Example use case:
A student table where each student has up to 5 subject marks. Instead of creating 5 separate columns, we can store them in a single VARRAY column.

---

## 2. Creating a VARRAY Type

First, create a VARRAY type to store marks:

```sql
-- Create a VARRAY type for 5 marks
create or replace type marks_varray as varray(5) of number;
/
```

This means: each student can have **up to 5 marks** stored as numbers.

---

## 3. Creating a Table with VARRAY

Now, use the VARRAY type in a table:

```sql
create table student (
    roll_no number primary key,
    name    varchar2(50),
    marks   marks_varray
);
```

Here:

* `roll_no` → student ID
* `name` → student name
* `marks` → array of marks (up to 5)

---

## 4. Simple CRUD Operations

### Insert

```sql
-- Insert student with 3 marks
insert into student values (1, 'Akshit', marks_varray(85, 90, 78));

-- Insert student with full 5 marks
insert into student values (2, 'Hemal', marks_varray(88, 76, 92, 80, 95));
```

### Select

```sql
-- See all data
select * from student;

-- Show one student’s marks
select s.name, column_value as mark
from student s, table(s.marks)
where s.roll_no = 1;
```

### Update

```sql
-- Update full marks array
update student
set marks = marks_varray(90, 85, 88, 92, 80)
where roll_no = 1;
```

### Delete

```sql
-- Delete a student
delete from student where roll_no = 2;
```

---

## 5. CRUD with Stored Procedure

To make it easier, we wrap insert, update, delete, and select in a single procedure.

```sql
create or replace procedure manage_student_records(
    p_roll_no   in number default null,
    p_name      in varchar2 default null,
    p_m1        in number default null,
    p_m2        in number default null,
    p_m3        in number default null,
    p_m4        in number default null,
    p_m5        in number default null,
    p_action    in varchar2
) as
    v_marks marks_varray;
begin
    case upper(p_action)
        when 'INSERT' then
            insert into student(roll_no, name, marks)
            values (p_roll_no, p_name, marks_varray(p_m1, p_m2, p_m3, p_m4, p_m5));
            dbms_output.put_line('Inserted student ' || p_name);

        when 'UPDATE' then
            update student
            set marks = marks_varray(p_m1, p_m2, p_m3, p_m4, p_m5)
            where roll_no = p_roll_no;
            dbms_output.put_line('Updated marks for roll no ' || p_roll_no);

        when 'DELETE' then
            delete from student where name = p_name;
            dbms_output.put_line('Deleted student ' || p_name);

        when 'SELECT' then
            select marks into v_marks
            from student
            where name = p_name;

            dbms_output.put_line('Marks for student ' || p_name || ':');
            for i in 1 .. v_marks.count loop
                dbms_output.put_line('  Subject ' || i || ': ' || nvl(to_char(v_marks(i)), 'null'));
            end loop;

        else
            dbms_output.put_line('Invalid action: ' || p_action);
    end case;
end;
/
```

---

## 6. Running the Procedure

### Insert student

```sql
exec manage_student_records(1, 'Akshit', 85, 90, 78, 88, 92, 'insert');
exec manage_student_records(2, 'Hemal', 80, 70, 95, 85, 88, 'insert');
```

### Update marks

```sql
exec manage_student_records(1, null, 90, 95, 85, 80, 100, 'update');
```

### Select student marks

```sql
exec manage_student_records(null, 'Akshit', null, null, null, null, null, 'select');
```

### Delete student

```sql
exec manage_student_records(null, 'Hemal', null, null, null, null, null, 'delete');
```

---

✅ With this setup, you can demonstrate:

* How VARRAY works
* How to use it inside a table
* Simple CRUD with SQL
* Advanced CRUD with stored procedures

---