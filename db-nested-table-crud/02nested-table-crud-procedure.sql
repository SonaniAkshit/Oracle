create or replace type subject_list as table of varchar2(30);
/

create or replace type marks_list as varray(5) of number(3);
/

create table student_results (
    student_id number primary key,
    name       varchar2(50),
    subjects   subject_list,
    marks      marks_list
) nested table subjects store as subjects_storage
TABLESPACE users
STORAGE (INITIAL 5K NEXT 10K);

-- 1. INSERT student with subject & marks
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

-- 2. Update Marks and Subjects Procedure

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

-- 3. Select Student Procedure
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

-- 4. Delete Student Procedure

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


-- 1. Insert Student (prompt for input)

exec insert_student_result(&student_id,'&name','&sub1','&sub2','&sub3',&m1,&m2,&m3);

-- 2. Update Student
exec update_student_result(&student_id,'&sub1','&sub2','&sub3',&m1,&m2,&m3);

-- 3. Select Student by Name
exec select_student_result('&name');

-- 4. Delete Student by Name
exec delete_student_result('&name');
