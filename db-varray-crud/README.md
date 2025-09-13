## 🔹 What is a VARRAY in Oracle?

* **VARRAY (Variable Size Array)** is a type of collection in Oracle.
* It stores a **fixed-size ordered set of elements** of the same data type.
* Unlike tables, VARRAY elements are stored **sequentially in memory** for fast access.
* Can be stored inside a table column (as an object type).
* Useful when the number of items is known and usually not very large (e.g., phone numbers, marks of a student).

---

## 🔹 Steps to Work with VARRAY

### 1. Create a VARRAY Type

Example: Store **marks of a student** (max 5 subjects).

```sql
CREATE OR REPLACE TYPE marks_varray IS VARRAY(5) OF NUMBER(3);
```

This creates a VARRAY type that can hold up to **5 numbers** (each max 3 digits).

---

### 2. Create a Table Using VARRAY with Tablespace and Storage Clause

We attach the VARRAY type to a column inside a table.

```sql
CREATE TABLE student
(
    roll_no NUMBER PRIMARY KEY,
    name    VARCHAR2(50),
    marks   marks_varray
)
TABLESPACE users
STORAGE (INITIAL 100K NEXT 50K);
```

Here:

* `TABLESPACE users` → Stores the table in the USERS tablespace.
* `STORAGE` clause → Defines space allocation.

---

### 3. Insert Records into VARRAY

You insert data into VARRAY columns by calling the constructor of the type.

```sql
INSERT INTO student VALUES (1, 'Akshit', marks_varray(78, 85, 90));
INSERT INTO student VALUES (2, 'Ravi', marks_varray(60, 72, 81, 95));
```

---

### 4. Update a Specific Element in VARRAY

Updating requires assigning the whole array or modifying an index.

```sql
-- Update the 2nd subject mark for roll_no = 1
UPDATE student s
SET s.marks(2) = 88
WHERE s.roll_no = 1;
```

---

### 5. Delete an Element in VARRAY

VARRAY is a fixed-size ordered collection. You cannot "delete" an index directly, but you can set it to `NULL` or replace the whole array.

```sql
-- Set 3rd subject mark to NULL for roll_no = 2
UPDATE student s
SET s.marks(3) = NULL
WHERE s.roll_no = 2;
```

---

### 6. Add (Insert) a New Element

If the array is not full (size < max defined), you can extend it by reassigning values.

```sql
-- Add a 4th subject mark to roll_no = 1
UPDATE student s
SET s.marks = marks_varray(78, 88, 90, 92)
WHERE s.roll_no = 1;
```

---

## 🔹 Simple Problem Definition

**Problem:**
A university wants to store students’ marks for up to 5 subjects. Instead of creating 5 separate columns (`mark1`, `mark2`, ...), we use a **VARRAY**.

**Solution:**

1. Define a `marks_varray` type (size 5).
2. Create a `student` table with a `marks` column of this type, including tablespace and storage.
3. Perform operations:

   * Insert new student records with marks.
   * Update specific subject marks.
   * Delete (set NULL) marks for a subject.
   * Add new marks if a student takes another subject.

---

Let’s build a **stored procedure** in Oracle PL/SQL that allows you to **insert, update, and delete elements in a VARRAY**.

We’ll use the same **student / marks\_varray** example.

---

## 🔹 Step 1: Create VARRAY and Table

```sql
-- VARRAY type
CREATE OR REPLACE TYPE marks_varray IS VARRAY(5) OF NUMBER(3);

-- Table with VARRAY column
CREATE TABLE student
(
    roll_no NUMBER PRIMARY KEY,
    name    VARCHAR2(50),
    marks   marks_varray
);
```

---

## 🔹 Step 2: Create Procedure for Insert, Update, Delete

We’ll write one procedure with a **mode parameter** (`'INSERT'`, `'UPDATE'`, `'DELETE'`) to handle all operations.

```sql
CREATE OR REPLACE PROCEDURE manage_student_marks(
    p_roll_no   IN NUMBER,
    p_name      IN VARCHAR2 DEFAULT NULL,
    p_position  IN NUMBER   DEFAULT NULL,
    p_value     IN NUMBER   DEFAULT NULL,
    p_action    IN VARCHAR2
) AS
    v_marks marks_varray;
BEGIN
    -- Fetch existing marks into variable
    SELECT marks INTO v_marks
    FROM student
    WHERE roll_no = p_roll_no
    FOR UPDATE;

    -- Perform action
    IF UPPER(p_action) = 'INSERT' THEN
        -- Insert new mark at given position
        v_marks.EXTEND;
        v_marks(v_marks.COUNT) := p_value;

    ELSIF UPPER(p_action) = 'UPDATE' THEN
        -- Update existing mark at given position
        v_marks(p_position) := p_value;

    ELSIF UPPER(p_action) = 'DELETE' THEN
        -- "Delete" by setting element NULL
        v_marks(p_position) := NULL;

    END IF;

    -- Save changes back
    UPDATE student
    SET marks = v_marks
    WHERE roll_no = p_roll_no;

    DBMS_OUTPUT.PUT_LINE('Action ' || p_action || ' completed for Roll No ' || p_roll_no);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- If student not found, allow insert of whole record
        IF UPPER(p_action) = 'INSERT' THEN
            INSERT INTO student (roll_no, name, marks)
            VALUES (p_roll_no, p_name, marks_varray(p_value));
            DBMS_OUTPUT.PUT_LINE('New student inserted with first mark.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('No record found for Roll No ' || p_roll_no);
        END IF;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```

---

## 🔹 Step 3: How to Use the Procedure

### Insert a new student with first mark

```sql
EXEC manage_student_marks(1, 'Akshit', NULL, 85, 'INSERT');
```

### Add another mark for roll\_no = 1

```sql
EXEC manage_student_marks(1, NULL, NULL, 90, 'INSERT');
```

### Update 2nd subject mark

```sql
EXEC manage_student_marks(1, NULL, 2, 95, 'UPDATE');
```

### Delete (set NULL) for 1st subject mark

```sql
EXEC manage_student_marks(1, NULL, 1, NULL, 'DELETE');
```

---

⚡ This procedure handles **insert, update, and delete on VARRAY elements** dynamically.