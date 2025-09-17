LOAD DATA
INFILE 'student.csv'
INTO TABLE student_csv
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
 student_id     INTEGER EXTERNAL,
 name           CHAR,
 enrolment_no   CHAR,
 department     CHAR,
 stream         CHAR
)