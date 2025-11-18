select type_name from user_types;

-- 1. drop the student_results table
drop table student_results cascade constraints purge;

-- 2. drop object types and nested types example
drop type dept_nested force;
