-- 1️. Cluster for customers + tickets + payments
create cluster cust_ticket_pay_cluster (customer_id number)
size 1024;

-- customers table in cluster
create table customers (
    customer_id    number primary key,
    name           varchar2(25),
    email          varchar2(25) unique,
    password       varchar2(20),
    phone          varchar2(15),
    registered_on  date default sysdate
)
cluster cust_ticket_pay_cluster (customer_id);

-- tickets table in cluster
create table tickets (
    ticket_id     number primary key,
    customer_id   number references customers(customer_id),
    show_id       number,
    seat_id       number,
    booking_time  timestamp default systimestamp,
    ticket_status varchar2(20) default 'BOOKED'
)
cluster cust_ticket_pay_cluster (customer_id);

-- payments table in cluster
create table payments (
    payment_id    number primary key,
    customer_id   number references customers(customer_id),
    ticket_id     number references tickets(ticket_id),
    amount        number(8,2),
    payment_date  date default sysdate
)
cluster cust_ticket_pay_cluster (customer_id);

-- cluster index
create index idx_cust_ticket_pay_cluster
on cluster cust_ticket_pay_cluster;

-- =======================================================

-- 2️. Cluster for movies + shows + screens
create cluster movie_show_screen_cluster (movie_id number)
size 1024;

-- movies table in cluster
create table movies (
    movie_id     number primary key,
    title        varchar2(150),
    duration     number,
    release_date date
)
cluster movie_show_screen_cluster (movie_id);

-- screens table (independent, but we can still cluster by movie_id reference later if required)
create table screens (
    screen_id    number primary key,
    name         varchar2(100),
    location     varchar2(150),
    total_seats  number not null
);

-- shows table in cluster
create table shows (
    show_id      number primary key,
    movie_id     number references movies(movie_id),
    screen_id    number references screens(screen_id),
    show_time    timestamp,
    price        number(8,2)
)
cluster movie_show_screen_cluster (movie_id);

-- cluster index
create index idx_movie_show_screen_cluster
on cluster movie_show_screen_cluster;

-- =======================================================

-- 3️. Cluster for seats (per screen)
create cluster screen_seat_cluster (screen_id number)
size 512;

-- seats table in cluster
create table seats (
    seat_id      number primary key,
    screen_id    number references screens(screen_id),
    seat_number  varchar2(10)
)
cluster screen_seat_cluster (screen_id);

-- cluster index
create index idx_screen_seat_cluster
on cluster screen_seat_cluster;

-- =======================================================

-- 4️. Admins (kept standalone, no cluster needed)
create table admins (
    admin_id      number primary key,
    username      varchar2(50) unique,
    password      varchar2(100),
    created_on    date default sysdate
);


-- customer with tickets & payments
select c.name, t.ticket_id, t.ticket_status, p.amount
from customers c
join tickets t on c.customer_id = t.customer_id
join payments p on t.customer_id = p.customer_id;

-- movies with shows and screens
select m.title, s.show_id, s.show_time, sc.name as screen_name
from movies m
join shows s on m.movie_id = s.movie_id
join screens sc on s.screen_id = sc.screen_id;

-- seats per screen
select sc.name, st.seat_number
from screens sc
join seats st on sc.screen_id = st.screen_id;
