-- customers: email must be unique (already enforced, but good to have index)
CREATE UNIQUE INDEX idx_customers_email
ON customers(email);

-- admins: username must be unique
CREATE UNIQUE INDEX idx_admins_username
ON admins(username);

-- seats: unique seat per screen (since theaters removed, use screen_id + seat_number)
CREATE UNIQUE INDEX idx_seats_unique
ON seats(screen_id, seat_number);

-- shows: unique show per screen and time
CREATE UNIQUE INDEX idx_shows_unique
ON shows(screen_id, show_time);

-- tickets: unique seat booking for each show
CREATE UNIQUE INDEX idx_tickets_unique
ON tickets(show_id, seat_id);

-- payments: one payment per ticket
CREATE UNIQUE INDEX idx_payments_ticket
ON payments(ticket_id);

-- movies: ensure no two movies have same title + release date
CREATE UNIQUE INDEX idx_movies_title_release
ON movies(title, release_date);

-- screens: ensure unique screen name and location (since theaters removed)
CREATE UNIQUE INDEX idx_screens_name_location
ON screens(name, location);

-- select all created indexes in our schema
SELECT 'INDEX NAME:  "' || index_name || '"' AS INDEXES
FROM user_indexes;
