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

insert into student_results
values (1, 'Akshit', subject_list('Math','Science','English'), marks_list(85,90,78));

insert into student_results
values (2, 'Hemal', subject_list('Physics','Chemistry','Math'), marks_list(80,70,75));

update student_results
set subjects = subject_list('c','c++','python'),
    marks = marks_list(95,85,90)
where student_id = 1;