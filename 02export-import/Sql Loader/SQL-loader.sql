create table student_csv (
    student_id      number primary key,
    name            varchar2(50),
    enrolment_no    varchar2(20),
    department      varchar2(50),
    stream          varchar2(50)
)
tablespace users
storage (
    initial 5k
    next 10k
);

sqlldr userid=user01/user01@localhost:1521/xepdb1 control=student_csv.ctl log=student_csv.log


create table student_txt (
    student_id      number primary key,
    name            varchar2(50),
    enrolment_no    varchar2(20),
    department      varchar2(50),
    stream          varchar2(50)
)
tablespace users
storage (
    initial 5k
    next 10k
);

sqlldr userid=user01/user01@localhost:1521/xepdb1 control=student_txt.ctl log=student_txt.log
