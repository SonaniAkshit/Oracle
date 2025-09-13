-- 1. create object type for course
create or replace type course_obj as object (
    course_id   number,
    course_name varchar2(50)
);
/

-- 2. create nested table type for courses in department
create or replace type course_nested as table of course_obj;
/

-- 3. create object type for department
create or replace type dept_obj as object (
    dept_id     number,
    dept_name   varchar2(50),
    courses     course_nested
);
/

-- 4. create nested table type for departments
create or replace type dept_nested as table of dept_obj;
/

-- 5. create nested table type for subjects
create or replace type subject_list as table of varchar2(30);
/

-- 6. create varray type for marks
create or replace type marks_list as varray(5) of number(3);
/

-- 7. create student_results table
create table student_results (
    student_id number primary key,
    name       varchar2(50),
    departments dept_nested,
    subjects   subject_list,
    marks      marks_list
) nested table departments store as dept_storage
  nested table subjects store as subjects_storage
  tablespace users
  storage (initial 5k next 10k);

-- 8. insert student procedure
create or replace procedure insert_student_result(
    p_student_id in number,
    p_name       in varchar2,
    p_dept_id    in number,
    p_dept_name  in varchar2,
    p_course1_id in number,
    p_course1_name in varchar2,
    p_course2_id in number,
    p_course2_name in varchar2,
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
        insert into student_results (student_id, name, departments, subjects, marks)
        values (
            p_student_id,
            p_name,
            dept_nested(
                dept_obj(p_dept_id, p_dept_name, course_nested(course_obj(p_course1_id, p_course1_name), course_obj(p_course2_id, p_course2_name)))
            ),
            subject_list(p_sub1, p_sub2, p_sub3),
            marks_list(p_m1, p_m2, p_m3)
        );

        dbms_output.put_line('new student inserted with id ' || p_student_id);
    else
        dbms_output.put_line('student already exists with id ' || p_student_id);
    end if;
end;
/

-- 9. update student procedure
create or replace procedure update_student_result(
    p_student_id in number,
    p_dept_id    in number,
    p_dept_name  in varchar2,
    p_course1_id in number,
    p_course1_name in varchar2,
    p_course2_id in number,
    p_course2_name in varchar2,
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
        set departments = dept_nested(
                dept_obj(p_dept_id, p_dept_name, course_nested(course_obj(p_course1_id, p_course1_name), course_obj(p_course2_id, p_course2_name)))
            ),
            subjects   = subject_list(p_sub1, p_sub2, p_sub3),
            marks      = marks_list(p_m1, p_m2, p_m3)
        where student_id = p_student_id;

        dbms_output.put_line('student updated for id ' || p_student_id);
    end if;
end;
/

-- 10. select student procedure
create or replace procedure select_student_result(
    p_name in varchar2
) as
    v_depts dept_nested;
    v_subjects subject_list;
    v_marks marks_list;
begin
    select departments, subjects, marks
    into v_depts, v_subjects, v_marks
    from student_results
    where name = p_name;

    dbms_output.put_line('student: ' || p_name);

    -- departments and courses
    for i in 1 .. v_depts.count loop
        dbms_output.put_line('  dept: ' || v_depts(i).dept_name);
        for j in 1 .. v_depts(i).courses.count loop
            dbms_output.put_line('    course: ' || v_depts(i).courses(j).course_name);
        end loop;
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

-- 11. delete student procedure
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

-- 12. exec examples
exec insert_student_result(&student_id, '&name', &dept_id, '&dept_name', &course1_id, '&course1_name', &course2_id, '&course2_name','&sub1','&sub2','&sub3',&m1,&m2,&m3);

exec update_student_result(&student_id, &dept_id, '&dept_name', &course1_id, '&course1_name', &course2_id, '&course2_name','&sub1','&sub2','&sub3',&m1,&m2,&m3);

exec select_student_result('&name');

exec delete_student_result('&name');
