CREATE TABLE student_csv(
    student_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(50),
    enrolment_no    VARCHAR2(20),
    department      VARCHAR2(50),
    stream          VARCHAR2(50)
)
tablespace users 
storage(
    INITIAL 5k
    next 10k
);

sqlldr userid=user01/user01@localhost:1521/xepdb1 control=student_csv.ctl log=student_csv.log


CREATE TABLE student_txt (
    student_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(50),
    enrolment_no    VARCHAR2(20),
    department      VARCHAR2(50),
    stream          VARCHAR2(50)
)
tablespace users
storage(
    INITIAL 5k
    next 10k
);

sqlldr userid=user01/user01@localhost:1521/xepdb1 control=student_txt.ctl log=student_txt.log