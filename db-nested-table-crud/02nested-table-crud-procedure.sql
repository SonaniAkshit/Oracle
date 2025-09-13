-- 1. create object type for department
create or replace type dept_obj as object (
    dept_id     number,
    dept_name   varchar2(50),
    course      varchar2(50)
);
/

-- 2. create nested table type for department
create or replace type dept_nested as table of dept_obj;
/

-- 3. create nested table type for subjects
create or replace type subject_list as table of varchar2(30);
/

-- 4. create varray type for marks
create or replace type marks_list as varray(5) of number(3);
/

-- 5. create student_results table
create table student_results (
    student_id number primary key,
    name       varchar2(50),
    department dept_nested,
    subjects   subject_list,
    marks      marks_list
) nested table department store as dept_storage
  nested table subjects store as subjects_storage
  tablespace users
  storage (initial 5k next 10k);
/

-- 6. insert student procedure
create or replace procedure insert_student_result(
    p_student_id in number,
    p_name       in varchar2,
    p_dept_id    in number,
    p_dept_name  in varchar2,
    p_course     in varchar2,
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
        insert into student_results (student_id, name, department, subjects, marks)
        values (
            p_student_id,
            p_name,
            dept_nested(dept_obj(p_dept_id, p_dept_name, p_course)),
            subject_list(p_sub1, p_sub2, p_sub3),
            marks_list(p_m1, p_m2, p_m3)
        );

        dbms_output.put_line('new student inserted with id ' || p_student_id);
    else
        dbms_output.put_line('student already exists with id ' || p_student_id);
    end if;
end;
/

-- 7. update student procedure
create or replace procedure update_student_result(
    p_student_id in number,
    p_dept_id    in number,
    p_dept_name  in varchar2,
    p_course     in varchar2,
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
        dbms_output.put_line('student not found with id ' || p_student_id);
    else
        update student_results
        set department = dept_nested(dept_obj(p_dept_id, p_dept_name, p_course)),
            subjects   = subject_list(p_sub1, p_sub2, p_sub3),
            marks      = marks_list(p_m1, p_m2, p_m3)
        where student_id = p_student_id;

        dbms_output.put_line('student updated for id ' || p_student_id);
    end if;
end;
/

-- 8. select student procedure
create or replace procedure select_student_result(
    p_name in varchar2
) as
    v_dept dept_nested;
    v_subjects subject_list;
    v_marks marks_list;
begin
    select department, subjects, marks
    into v_dept, v_subjects, v_marks
    from student_results
    where name = p_name;

    dbms_output.put_line('student: ' || p_name);

    -- departments
    for i in 1 .. v_dept.count loop
        dbms_output.put_line('  dept: ' || v_dept(i).dept_name || ' - course: ' || v_dept(i).course);
    end loop;

    -- subjects and marks
    for i in 1 .. v_subjects.count loop
        dbms_output.put_line('  subject: ' || v_subjects(i) || ' - mark: ' || v_marks(i));
    end loop;

exception
    when no_data_found then
        dbms_output.put_line('student not found with name ' || p_name);
end;
/

-- 9. delete student procedure
create or replace procedure delete_student_result(
    p_name in varchar2
) as
begin
    delete from student_results where name = p_name;

    if sql%rowcount > 0 then
        dbms_output.put_line('student ' || p_name || ' deleted.');
    else
        dbms_output.put_line('no student found with name ' || p_name);
    end if;
end;
/

-- 10. exec examples for run procedure
exec insert_student_result(&student_id, '&name', &dept_id, '&dept_name', '&course','&sub1','&sub2','&sub3',&m1,&m2,&m3);

exec update_student_result(&student_id, &dept_id, '&dept_name', '&course','&sub1','&sub2','&sub3',&m1,&m2,&m3);

exec select_student_result('&name');

exec delete_student_result('&name');
