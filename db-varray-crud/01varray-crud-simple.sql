-- 1. creating varray type

create or REPLACE type marks_varray is varray(5) of number(3);
/

-- 2. use varray type in creating table

CREATE TABLE student
(
    roll_no NUMBER PRIMARY KEY,
    name    VARCHAR2(50),
    marks   marks_varray
)
TABLESPACE users
STORAGE (INITIAL 5K NEXT 10K);

-- 3. inserting record on varray

INSERT INTO student 
VALUES (1, 'Akshit', marks_varray(78, 85, 90));

-- 4. updateting record on varray

UPDATE student
SET marks = marks_varray(78, 90, 88)
WHERE roll_no = 1;
