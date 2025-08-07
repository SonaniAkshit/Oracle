--- Tables

--- 1. `customers`

CREATE TABLE customers (
    customer_id    NUMBER PRIMARY KEY,
    name           VARCHAR2(25),
    email          VARCHAR2(25) UNIQUE,
    phone          VARCHAR2(15),
    registered_on  DATE DEFAULT SYSDATE
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);


--- 2. `movies`

CREATE TABLE movies (
    movie_id     NUMBER PRIMARY KEY,
    title        VARCHAR2(150),
    duration     NUMBER,
    release_date DATE
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);

--- 3. `theaters`

CREATE TABLE theaters (
    theater_id   NUMBER PRIMARY KEY,
    name         VARCHAR2(100),
    location     VARCHAR2(150),
    total_seats  NUMBER
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);

-- 4. `shows`

CREATE TABLE shows (
    show_id      NUMBER PRIMARY KEY,
    movie_id     NUMBER REFERENCES movies(movie_id),
    theater_id   NUMBER REFERENCES theaters(theater_id),
    show_time    TIMESTAMP,
    screen_no    NUMBER,
    price        NUMBER(8,2)
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);

--- 5. `seats`

CREATE TABLE seats (
    seat_id      NUMBER PRIMARY KEY,
    theater_id   NUMBER REFERENCES theaters(theater_id),
    seat_number  VARCHAR2(10),
    seat_type    VARCHAR2(20)  -- e.g., Regular, Premium, VIP
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);


--- 6. `tickets`

CREATE TABLE tickets (
    ticket_id     NUMBER PRIMARY KEY,
    customer_id   NUMBER REFERENCES customers(customer_id),
    show_id       NUMBER REFERENCES shows(show_id),
    seat_id       NUMBER REFERENCES seats(seat_id),
    booking_time  TIMESTAMP DEFAULT SYSTIMESTAMP,
    ticket_status VARCHAR2(20) DEFAULT 'BOOKED'
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);


--- 7. `payments`

CREATE TABLE payments (
    payment_id    NUMBER PRIMARY KEY,
    ticket_id     NUMBER REFERENCES tickets(ticket_id),
    amount        NUMBER(8,2),
    payment_date  DATE DEFAULT SYSDATE,
    payment_mode  VARCHAR2(30) -- UPI, Card, Cash, etc.
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);


--- 8. `admins`

CREATE TABLE admins (
    admin_id      NUMBER PRIMARY KEY,
    username      VARCHAR2(50) UNIQUE,
    password      VARCHAR2(100),
    created_on    DATE DEFAULT SYSDATE
)
TABLESPACE users
STORAGE (
    INITIAL 10K
    NEXT 20K
    MINEXTENTS 1
    MAXEXTENTS 2
);
