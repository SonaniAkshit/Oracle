-- customers
CREATE SEQUENCE seq_customer_id
START WITH 1 INCREMENT BY 1 ;

-- movies
CREATE SEQUENCE seq_movie_id
START WITH 1 INCREMENT BY 1 ;

-- theaters
CREATE SEQUENCE seq_theater_id
START WITH 1 INCREMENT BY 1 ;

-- seats
CREATE SEQUENCE seq_seat_id
START WITH 1 INCREMENT BY 1 ;

-- shows
CREATE SEQUENCE seq_show_id
START WITH 1 INCREMENT BY 1 ;

-- tickets
CREATE SEQUENCE seq_ticket_id
START WITH 1 INCREMENT BY 1 ;

-- payments
CREATE SEQUENCE seq_payment_id
START WITH 1 INCREMENT BY 1 ;

-- admins
CREATE SEQUENCE seq_admin_id
START WITH 1 INCREMENT BY 1 ;

-- select all created sequences in our schema
SELECT 'SEQUENCE NAME:  "' || sequence_name || '"' AS SEQUENCES
FROM user_sequences;