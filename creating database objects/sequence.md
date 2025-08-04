## sequence in oracle

**1. Creating a sequence**

###### Syntax

```sql
CREATE SEQUENCE sequence_name
[INCREMENT BY n]
[START WITH n]
[MAXVALUE n | NOMAXVALUE]
[MINVALUE n | NOMINVALUE]
[CYCLE | NOCYCLE]
[CACHE n | NOCACHE]
[ORDER | NOORDER];
```

These parameters control the behavior of the sequence:

- sequence_name: The name for your sequence.
- INCREMENT BY n: Sets the step between sequence numbers (default is 1).
- START WITH n: Defines the initial value.
- MAXVALUE n | NOMAXVALUE: Specifies the upper limit (or no limit).
- MINVALUE n | NOMINVALUE: Specifies the lower limit (or no limit).
- CYCLE | NOCYCLE: Determines if the sequence restarts after reaching a limit.
- CACHE n | NOCACHE: Configures how many values are stored in memory for performance (default is 20).
- ORDER | NOORDER: Guarantees sequence numbers are generated in the order of requests (default is NOORDER). 

###### Exmaple

```sql
 create sequence p_id_seq
    increment by 1
    minvalue 1
    maxvalue 10
    start with 1;
```

###### view created sequence

```sql
 select sequence_name from user_sequences;
```
```
SEQUENCE_NAME
--------------
P_ID_SEQ
```
```sql
select * from user_sequences;
```
```
SEQUENCE_NAME
-----------------------------------------------------------------------
 MIN_VALUE| MAX_VALUE|INCREMENT_BY|C|O|CACHE_SIZE|LAST_NUMBER|S|E|S|S|K
----------|----------|------------|-|-|----------|-----------|-|-|-|-|-
P_ID_SEQ
         1|        10|           1|N|N|        20|          1|N|N|N|N|N
```

**2. Using sequences**

Use the `CURRVAL` and `NEXTVAL` pseudocolumns to get values from a sequence. 
- NEXTVAL: Retrieves and increments the sequence.
- CURRVAL: Returns the last value retrieved by NEXTVAL in the current session. 

###### Example

```sql
select p_id_seq.nextval from dual;
```
```
   NEXTVAL
----------
         5
```
```sql
select p_id_seq.currval from dual;
```
```
   CURRVAL
----------
         5
```
**3. Altering a sequence**
Use the `ALTER SEQUENCE` statement to change existing sequence properties. 

###### problem of maxvalue
```sql
 select p_id_seq.nextval from dual;

   NEXTVAL
----------
        10

SQL> select p_id_seq.nextval from dual;
select p_id_seq.nextval from dual
*
ERROR at line 1:
ORA-08004: sequence P_ID_SEQ.NEXTVAL exceeds MAXVALUE and cannot be instantiated

```

###### Example
```sql
alter sequence p_id_seq maxval 20;
```

**4. Dropping a sequence**

The `DROP SEQUENCE` statement removes a sequence. 

###### Example

```sql
drop sequence p_id_seq;
```

**Other useful data dictionary views**

- ALL_SEQUENCES: This view displays information about all sequences accessible to the current user, including sequences owned by other schemas to which you have been granted access.
- DBA_SEQUENCES: This view shows information about all sequences in the entire database, regardless of ownership.

```sql
SELECT sequence_owner, sequence_name FROM all_sequences;
```

```
SEQUENCE_OWNER
-------------------------
SEQUENCE_NAME
-------------------------
SYS
DM$EXPIMP_ID_SEQ

SYS
SCHEDULER$_JOBSUFFIX_S

SYS
PLSQL_CODE_COVERAGE_RUNNUMBER

XDB
XDB$NAMESUFF_SEQ

MDSYS
TMP_COORD_OPS

MDSYS
SAMPLE_SEQ

MDSYS
SDO_WS_CONFERENCE_IDS

MDSYS
SDO_GEOR_SEQ

MDSYS
SDO_NDM_ID_SEQ

EXTRAUSER
P_ID_SEQ


10 rows selected.
```