create cluster cluster_screen_seats (screen_id number)
size 512
tablespace users
storage (initial 10k next 10k);

create index idx_cluster_screen_seats on cluster cluster_screen_seats;

create table screens (
    screen_id number primary key,
    name varchar2(100),
    location varchar2(150),
    total_seats number not null
) cluster cluster_screen_seats (screen_id);

create table seats (
    seat_id number primary key,
    screen_id number references screens(screen_id),
    seat_number varchar2(10),
    seat_type varchar2(20)
) cluster cluster_screen_seats (screen_id);

create cluster cluster_show_tickets (show_id number)
size 512
tablespace users
storage (initial 10k next 10k);

create index idx_cluster_show_tickets on cluster cluster_show_tickets;

create table shows (
    show_id number primary key,
    movie_id number references movies(movie_id),
    screen_id number references screens(screen_id),
    show_time timestamp,
    price number(8,2)
) cluster cluster_show_tickets (show_id);

create table tickets (
    ticket_id number primary key,
    customer_id number references customers(customer_id),
    show_id number references shows(show_id),
    seat_id number references seats(seat_id),
    booking_time timestamp default systimestamp,
    ticket_status varchar2(20) default 'booked'
) cluster cluster_show_tickets (show_id);

create cluster cluster_ticket_payments (ticket_id number)
size 512
tablespace users
storage (initial 10k next 10k);

create index idx_cluster_ticket_payments on cluster cluster_ticket_payments;

create table payments (
    payment_id number primary key,
    ticket_id number references tickets(ticket_id),
    amount number(8,2),
    payment_date date default sysdate,
    payment_mode varchar2(30)
) cluster cluster_ticket_payments (ticket_id);
