-- customers indexes
create index idx_customers_email on customers(email);
create index idx_customers_phone on customers(phone);

-- movies indexes
create index idx_movies_title on movies(title);
create index idx_movies_release_date on movies(release_date);

-- screens indexes
create index idx_screens_name on screens(name);
create index idx_screens_location on screens(location);

-- shows indexes
create index idx_shows_movie on shows(movie_id);
create index idx_shows_screen on shows(screen_id);
create index idx_shows_time on shows(show_time);

-- seats indexes
create index idx_seats_screen on seats(screen_id);
create index idx_seats_number on seats(seat_number);

-- tickets indexes
create index idx_tickets_customer on tickets(customer_id);
create index idx_tickets_show on tickets(show_id);
create index idx_tickets_seat on tickets(seat_id);
create index idx_tickets_status on tickets(ticket_status);

-- payments indexes
create index idx_payments_ticket on payments(ticket_id);
create index idx_payments_date on payments(payment_date);

-- admins indexes
create index idx_admins_username on admins(username);
