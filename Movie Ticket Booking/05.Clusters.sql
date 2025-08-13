-- 1️. 'cluster_theater_screens' - Tables: theaters & screens

CREATE CLUSTER cluster_theater_screens (theater_id NUMBER)
SIZE 512
TABLESPACE users
STORAGE (INITIAL 10K NEXT 10K);

CREATE INDEX idx_cluster_theater_screens ON CLUSTER cluster_theater_screens;

CREATE TABLE theaters (
    theater_id NUMBER PRIMARY KEY,
    name VARCHAR2(20),
    location VARCHAR2(100),
    total_seats NUMBER
) CLUSTER cluster_theater_screens (theater_id);

CREATE TABLE screens (
    screen_id NUMBER PRIMARY KEY,
    theater_id NUMBER REFERENCES theaters(theater_id),
    total_seats NUMBER NOT NULL
) CLUSTER cluster_theater_screens (theater_id);

-- 2️. 'cluster_theater_seats' - Tables: theaters & seats

CREATE CLUSTER cluster_theater_seats (theater_id NUMBER)
SIZE 512
TABLESPACE users
STORAGE (INITIAL 10K NEXT 10K);

CREATE INDEX idx_cluster_theater_seats ON CLUSTER cluster_theater_seats;

CREATE TABLE seats (
    seat_id NUMBER PRIMARY KEY,
    theater_id NUMBER REFERENCES theaters(theater_id),
    seat_number VARCHAR2(10),
    seat_type VARCHAR2(20)
) CLUSTER cluster_theater_seats (theater_id);

-- 3️. cluster_show_tickets - Tables: shows & tickets

CREATE CLUSTER cluster_show_tickets (show_id NUMBER)
SIZE 512
TABLESPACE users
STORAGE (INITIAL 10K NEXT 10K);

CREATE INDEX idx_cluster_show_tickets ON CLUSTER cluster_show_tickets;

CREATE TABLE shows (
    show_id NUMBER PRIMARY KEY,
    movie_id NUMBER REFERENCES movies(movie_id),
    theater_id NUMBER REFERENCES theaters(theater_id),
    show_time TIMESTAMP,
    screen_no NUMBER,
    price NUMBER(8,2)
) CLUSTER cluster_show_tickets (show_id);

CREATE TABLE tickets (
    ticket_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES customers(customer_id),
    show_id NUMBER REFERENCES shows(show_id),
    seat_id NUMBER REFERENCES seats(seat_id),
    booking_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    ticket_status VARCHAR2(20) DEFAULT 'BOOKED'
) CLUSTER cluster_show_tickets (show_id);

-- 4️. cluster_ticket_payments - Tables: tickets & payments

CREATE CLUSTER cluster_ticket_payments (ticket_id NUMBER)
SIZE 512
TABLESPACE users
STORAGE (INITIAL 10K NEXT 10K);

CREATE INDEX idx_cluster_ticket_payments ON CLUSTER cluster_ticket_payments;

CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    ticket_id NUMBER REFERENCES tickets(ticket_id),
    amount NUMBER(8,2),
    payment_date DATE DEFAULT SYSDATE,
    payment_mode VARCHAR2(30)
) CLUSTER cluster_ticket_payments (ticket_id);
