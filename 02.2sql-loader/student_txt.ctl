LOAD DATA
INFILE 'student.txt'
INTO TABLE student_txt
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
(
 student_id     INTEGER EXTERNAL,
 name           CHAR,
 enrolment_no   CHAR,
 department     CHAR,
 stream         CHAR
)