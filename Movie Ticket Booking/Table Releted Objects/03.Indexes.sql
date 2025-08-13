create unique index idx_customers_email
on customers(email);

create unique index idx_admins_username
on admins(username);

create unique index idx_seats_unique
on seats(screen_id, seat_number);

create unique index idx_shows_unique
on shows(screen_id, show_time);

create unique index idx_tickets_unique
on tickets(show_id, seat_id);

create unique index idx_payments_ticket
on payments(ticket_id);

create unique index idx_movies_title_release
on movies(title, release_date);

create unique index idx_screens_name_location
on screens(name, location);

select 'index name:  "' || index_name || '"' as indexes
from user_indexes;
