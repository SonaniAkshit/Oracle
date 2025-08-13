create sequence seq_customers start with 1 increment by 1;
create sequence seq_movies start with 1 increment by 1;
create sequence seq_screens start with 1 increment by 1;
create sequence seq_shows start with 1 increment by 1;
create sequence seq_seats start with 1 increment by 1;
create sequence seq_tickets start with 1 increment by 1;
create sequence seq_payments start with 1 increment by 1;
create sequence seq_admins start with 1 increment by 1;

-- select all created sequences in our schema
select 'sequence name:  "' || sequence_name || '"' as sequences
from user_sequences;
