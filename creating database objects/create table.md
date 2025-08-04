**1. Create a sequence**
First, a sequence will be created to generate unique product IDs. 

```sql
 create sequence p_id_seq
    increment by 1
    minvalue 1
    maxvalue 10
    start with 1;
```