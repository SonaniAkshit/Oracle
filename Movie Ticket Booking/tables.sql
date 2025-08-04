-- 1. customers Table

CREATE TABLE customers (
    customer_id   NUMBER PRIMARY KEY,
    name          VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100) UNIQUE,
    phone         VARCHAR2(15)
)
TABLESPACE your_tablespace_name
STORAGE (
    INITIAL 64K
    NEXT 64K
    MINEXTENTS 1
    MAXEXTENTS 1
);


-- 2. shows Table

CREATE TABLE shows (
    show_id       NUMBER PRIMARY KEY,
    show_date     DATE NOT NULL,
    total_seats   NUMBER CHECK (total_seats > 0 AND total_seats <= 50)
)
TABLESPACE your_tablespace_name
STORAGE (
    INITIAL 64K
    NEXT 64K
    MINEXTENTS 1
    MAXEXTENTS 1
);

-- 3. tickets Table

CREATE TABLE tickets (
    ticket_id     NUMBER PRIMARY KEY,
    customer_id   NUMBER REFERENCES customers(customer_id),
    show_id       NUMBER REFERENCES shows(show_id),
    seat_number   NUMBER,
    booking_time  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
TABLESPACE your_tablespace_name
STORAGE (
    INITIAL 64K
    NEXT 64K
    MINEXTENTS 1
    MAXEXTENTS 1
);

-- 4. transactions Table

CREATE TABLE transactions (
    trans_id        NUMBER PRIMARY KEY,
    ticket_id       NUMBER REFERENCES tickets(ticket_id),
    amount          NUMBER(10,2) CHECK (amount >= 0),
    payment_status  VARCHAR2(20) CHECK (payment_status IN ('Paid', 'Failed')),
    trans_time      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
TABLESPACE your_tablespace_name
STORAGE (
    INITIAL 64K
    NEXT 64K
    MINEXTENTS 1
    MAXEXTENTS 1
);