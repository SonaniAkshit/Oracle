load data
infile 'student.csv'
into table student_csv
fields terminated by ',' optionally enclosed by '"'
(
 student_id     integer external,
 name           char,
 enrolment_no   char,
 department     char,
 stream         char
)
