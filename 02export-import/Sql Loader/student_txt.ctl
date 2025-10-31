load data
infile 'student.txt'
into table student_txt
fields terminated by '|' optionally enclosed by '"'
(
 student_id     integer external,
 name           char,
 enrolment_no   char,
 department     char,
 stream         char
)
