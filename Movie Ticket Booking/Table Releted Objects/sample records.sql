-- 1. Admin (only 1)
insert into admins (admin_id, username, password)
values (seq_admins.nextval, 'admin', 'admin123');

-- 2. Customers
insert into customers (customer_id, name, email, password, phone)
values (seq_customers.nextval, 'Akshit', 'akshit@gmail.com', 'akshit123', '9876543210');

insert into customers (customer_id, name, email, password, phone)
values (seq_customers.nextval, 'Sunny', 'sunny@gmail.com', 'sunny123', '9123456780');

-- 3. Movies
insert into movies (movie_id, title, duration, release_date)
values (seq_movies.nextval,'Inception',148,date'2010-07-16');

insert into movies values (seq_movies.nextval,'Interstellar',169,date'2014-11-07');

insert into movies values (seq_movies.nextval,'Avangers',150,date'2020-09-03');

insert into movies values (seq_movies.nextval,'Avtar 1',155,date'2021-10-22');

insert into movies values (seq_movies.nextval,'Avatar 2',192,date'2022-12-16');

-- 4. Screens
insert into screens (screen_id, name, location, total_seats)
values (seq_screens.nextval,'Screen 1','PVR Ahmedabad',5);

insert into screens values (seq_screens.nextval,'Screen 2','PVR Ahmedabad',5);

insert into screens values (seq_screens.nextval,'Screen 3','PVR Ahmedabad',5);

insert into screens values (seq_screens.nextval,'Screen 4','PVR Ahmedabad',5);

insert into screens values (seq_screens.nextval,'Screen 5','PVR Ahmedabad',5);

-- 5. Shows
insert into shows (show_id, movie_id, screen_id, show_time, price)
values (seq_shows.nextval, 1, 1, timestamp'2025-08-20 12:30:00',300);

insert into shows values (seq_shows.nextval, 2, 1, timestamp'2025-08-20 15:00:00',350);

insert into shows values (seq_shows.nextval, 3, 2, timestamp'2025-08-21 19:00:00',400);

insert into shows values (seq_shows.nextval, 4, 3, timestamp'2025-08-22 18:00:00',450);

insert into shows values (seq_shows.nextval, 5, 4, timestamp'2025-08-23 20:00:00',500);

-- 6. Seats (5 per screen)
-- Screen 1
insert into seats (seat_id, screen_id, seat_number) values (seq_seats.nextval,1,'A1');
insert into seats values (seq_seats.nextval,1,'A2');
insert into seats values (seq_seats.nextval,1,'A3');
insert into seats values (seq_seats.nextval,1,'A4');
insert into seats values (seq_seats.nextval,1,'A5');

-- Screen 2
insert into seats values (seq_seats.nextval,2,'B1');
insert into seats values (seq_seats.nextval,2,'B2');
insert into seats values (seq_seats.nextval,2,'B3');
insert into seats values (seq_seats.nextval,2,'B4');
insert into seats values (seq_seats.nextval,2,'B5');

-- Screen 3
insert into seats values (seq_seats.nextval,3,'C1');
insert into seats values (seq_seats.nextval,3,'C2');
insert into seats values (seq_seats.nextval,3,'C3');
insert into seats values (seq_seats.nextval,3,'C4');
insert into seats values (seq_seats.nextval,3,'C5');

-- Screen 4
insert into seats values (seq_seats.nextval,4,'D1');
insert into seats values (seq_seats.nextval,4,'D2');
insert into seats values (seq_seats.nextval,4,'D3');
insert into seats values (seq_seats.nextval,4,'D4');
insert into seats values (seq_seats.nextval,4,'D5');

-- Screen 5
insert into seats values (seq_seats.nextval,5,'E1');
insert into seats values (seq_seats.nextval,5,'E2');
insert into seats values (seq_seats.nextval,5,'E3');
insert into seats values (seq_seats.nextval,5,'E4');
insert into seats values (seq_seats.nextval,5,'E5');

-- 7. Tickets (some booked seats for demo)
insert into tickets (ticket_id, customer_id, show_id, seat_id) values (seq_tickets.nextval, 1, 1, 1);
insert into tickets values (seq_tickets.nextval, 2, 1, 2);
insert into tickets values (seq_tickets.nextval, 1, 2, 3);
insert into tickets values (seq_tickets.nextval, 2, 3, 6);
insert into tickets values (seq_tickets.nextval, 1, 4, 11);

-- 8. Payments
insert into payments (payment_id, ticket_id, amount) values (seq_payments.nextval, 1, 300);
insert into payments values (seq_payments.nextval, 2, 300);
insert into payments values (seq_payments.nextval, 3, 350);
insert into payments values (seq_payments.nextval, 4, 400);
insert into payments values (seq_payments.nextval, 5, 450);

commit;
