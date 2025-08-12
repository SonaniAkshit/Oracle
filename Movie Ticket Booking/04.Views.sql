-- 1. 'v_upcoming_shows' – Upcoming Show Listings

CREATE OR REPLACE VIEW v_upcoming_shows AS
SELECT s.show_id,
       m.title AS movie_title,
       t.name  AS theater_name,
       s.screen_no,
       s.show_time,
       s.price
FROM shows s
JOIN movies m   ON s.movie_id = m.movie_id
JOIN theaters t ON s.theater_id = t.theater_id
WHERE s.show_time > SYSTIMESTAMP;

-- 2️. 'v_available_seats' – Available Seats for Each Show

CREATE OR REPLACE VIEW v_available_seats AS
SELECT sh.show_id,
       t.name AS theater_name,
       s.seat_number,
       s.seat_type
FROM seats s
JOIN theaters t ON s.theater_id = t.theater_id
JOIN shows sh   ON sh.theater_id = t.theater_id
WHERE s.seat_id NOT IN (
    SELECT seat_id FROM tickets WHERE show_id = sh.show_id AND ticket_status = 'BOOKED'
);

-- 3️. 'v_customer_bookings' – Customer Booking History

CREATE OR REPLACE VIEW v_customer_bookings AS
SELECT c.customer_id,
       c.name AS customer_name,
       m.title AS movie_title,
       t.name AS theater_name,
       tk.seat_id,
       sh.show_time,
       tk.ticket_status
FROM customers c
JOIN tickets tk ON c.customer_id = tk.customer_id
JOIN shows sh   ON tk.show_id = sh.show_id
JOIN movies m   ON sh.movie_id = m.movie_id
JOIN theaters t ON sh.theater_id = t.theater_id;

-- 4️. 'v_ticket_payments' – Ticket with Payment Details

CREATE OR REPLACE VIEW v_ticket_payments AS
SELECT tk.ticket_id,
       c.name AS customer_name,
       m.title AS movie_title,
       t.name AS theater_name,
       sh.show_time,
       p.amount,
       p.payment_mode,
       p.payment_date
FROM tickets tk
JOIN customers c ON tk.customer_id = c.customer_id
JOIN shows sh    ON tk.show_id = sh.show_id
JOIN movies m    ON sh.movie_id = m.movie_id
JOIN theaters t  ON sh.theater_id = t.theater_id
JOIN payments p  ON tk.ticket_id = p.ticket_id;

-- 5️. 'v_sales_report' – Daily Sales Summary

CREATE OR REPLACE VIEW v_sales_report AS
SELECT TRUNC(p.payment_date) AS sale_date,
       COUNT(p.payment_id) AS total_tickets,
       SUM(p.amount) AS total_revenue
FROM payments p
GROUP BY TRUNC(p.payment_date)
ORDER BY sale_date DESC;

-- 6️. 'v_movie_performance' – How Movies Are Performing

CREATE OR REPLACE VIEW v_movie_performance AS
SELECT m.movie_id,
       m.title,
       COUNT(tk.ticket_id) AS tickets_sold,
       SUM(p.amount) AS total_revenue
FROM movies m
JOIN shows sh    ON m.movie_id = sh.movie_id
JOIN tickets tk  ON sh.show_id = tk.show_id
JOIN payments p  ON tk.ticket_id = p.ticket_id
GROUP BY m.movie_id, m.title;
