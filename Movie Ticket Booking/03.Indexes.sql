-- customers: email must be unique (already in table definition, but let's ensure it with a named index)
CREATE UNIQUE INDEX idx_customers_email
ON customers(email);

-- admins: username must be unique
CREATE UNIQUE INDEX idx_admins_username
ON admins(username);

-- seats: unique seat per theater (theater_id + seat_number)
CREATE UNIQUE INDEX idx_seats_unique
ON seats(theater_id, seat_number);

-- shows: unique show per theater and time
CREATE UNIQUE INDEX idx_shows_unique
ON shows(theater_id, show_time, screen_no);

-- tickets: unique seat booking for each show
CREATE UNIQUE INDEX idx_tickets_unique
ON tickets(show_id, seat_id);

-- payments: one payment per ticket
CREATE UNIQUE INDEX idx_payments_ticket
ON payments(ticket_id);

-- movies:Ensure no two movies have same title + release date
CREATE UNIQUE INDEX idx_movies_title_release
ON movies(title, release_date);

-- theaters:Ensure unique theater name and location
CREATE UNIQUE INDEX idx_theaters_name_location
ON theaters(name, location);

-- select all created index in our schema
SELECT 'INDEX NAME:  "' || index_name || '"' AS INDEXES
FROM user_indexes;