create or REPLACE type marks_varray is varray(5) of number(3);
/

CREATE TABLE student
(
    roll_no NUMBER PRIMARY KEY,
    name    VARCHAR2(50),
    marks   marks_varray
)
TABLESPACE users
STORAGE (INITIAL 5K NEXT 10K);

-- 1. INSERT student with 5 marks
create or replace procedure insert_student(
    p_roll_no in number,
    p_name    in varchar2,
    p_m1      in number,
    p_m2      in number,
    p_m3      in number,
    p_m4      in number,
    p_m5      in number
) as
    v_exists number;
begin
    select count(*) into v_exists
    from student
    where roll_no = p_roll_no;

    if v_exists = 0 then
        insert into student (roll_no, name, marks)
        values (p_roll_no, p_name, marks_varray(p_m1, p_m2, p_m3, p_m4, p_m5));
        dbms_output.put_line('new student inserted with roll no ' || p_roll_no);
    else
        dbms_output.put_line('student already exists with roll no ' || p_roll_no);
    end if;
end;
/


-- 2. UPDATE all 5 marks for existing student
create or replace procedure update_student(
    p_roll_no in number,
    p_m1      in number,
    p_m2      in number,
    p_m3      in number,
    p_m4      in number,
    p_m5      in number
) as
    v_exists number;
begin
    select count(*) into v_exists
    from student
    where roll_no = p_roll_no;

    if v_exists = 0 then
        dbms_output.put_line('student not found with roll no ' || p_roll_no);
    else
        update student
        set marks = marks_varray(p_m1, p_m2, p_m3, p_m4, p_m5)
        where roll_no = p_roll_no;

        dbms_output.put_line('marks updated for roll no ' || p_roll_no);
    end if;
end;
/

-- 3. SELECT marks by student name
create or replace procedure select_student(
    p_name in varchar2
) as
    v_marks marks_varray;
begin
    select marks into v_marks
    from student
    where name = p_name;

    dbms_output.put_line('marks for student ' || p_name || ':');
    for i in 1 .. v_marks.count loop
        dbms_output.put_line('  subject ' || i || ': ' || nvl(to_char(v_marks(i)), 'null'));
    end loop;

exception
    when no_data_found then
        dbms_output.put_line('student not found with name ' || p_name);
end;
/

-- 4. DELETE student by name
create or replace procedure delete_student(
    p_name in varchar2
) as
begin
    delete from student where name = p_name;

    if sql%rowcount > 0 then
        dbms_output.put_line('student ' || p_name || ' deleted.');
    else
        dbms_output.put_line('no student found with name ' || p_name);
    end if;
end;
/

-- Insert student (prompts for input)
exec insert_student(&roll_no, '&name', &m1, &m2, &m3, &m4, &m5);

-- Update marks
exec update_student(&roll_no, &m1, &m2, &m3, &m4, &m5);

-- Select marks by name
exec select_student('&name');

-- Delete student by name
exec delete_student('&name');
