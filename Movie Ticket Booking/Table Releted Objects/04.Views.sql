-- 1. v_upcoming_shows – Upcoming Show Listings
create or replace view v_upcoming_shows as
select s.show_id,
       m.title as movie_title,
       sc.name  as screen_name,
       sc.location,
       s.show_time,
       s.price
from shows s
join movies m on s.movie_id = m.movie_id
join screens sc on s.screen_id = sc.screen_id
where s.show_time > systimestamp;

-- 2. v_available_seats – Available Seats for Each Show
create or replace view v_available_seats as
select sh.show_id,
       sc.name as screen_name,
       s.seat_number
from shows sh
join screens sc on sh.screen_id = sc.screen_id
join seats s on s.screen_id = sc.screen_id
left join tickets tk on tk.show_id = sh.show_id 
                     and tk.seat_id = s.seat_id 
                     and tk.ticket_status = 'BOOKED'
where tk.ticket_id is null;

-- 3. v_customer_bookings – Customer Booking History
create or replace view v_customer_bookings as
select c.customer_id,
       c.name as customer_name,
       m.title as movie_title,
       sc.name as screen_name,
       s.seat_number,
       sh.show_time,
       tk.ticket_status
from customers c
join tickets tk on c.customer_id = tk.customer_id
join shows sh on tk.show_id = sh.show_id
join movies m on sh.movie_id = m.movie_id
join screens sc on sh.screen_id = sc.screen_id
join seats s on tk.seat_id = s.seat_id;

-- 4. v_ticket_payments – Ticket with Payment Details
create or replace view v_ticket_payments as
select tk.ticket_id,
       c.name as customer_name,
       m.title as movie_title,
       sc.name as screen_name,
       sh.show_time,
       p.amount,
       p.payment_date
from tickets tk
join customers c on tk.customer_id = c.customer_id
join shows sh on tk.show_id = sh.show_id
join movies m on sh.movie_id = m.movie_id
join screens sc on sh.screen_id = sc.screen_id
join payments p on tk.ticket_id = p.ticket_id;

-- 5. v_sales_report – Daily Sales Summary
create or replace view v_sales_report as
select trunc(p.payment_date) as sale_date,
       count(p.payment_id) as total_tickets,
       sum(p.amount) as total_revenue
from payments p
group by trunc(p.payment_date)
order by sale_date desc;

-- 6. v_movie_performance – How Movies Are Performing
create or replace view v_movie_performance as
select m.movie_id,
       m.title,
       count(tk.ticket_id) as tickets_sold,
       sum(p.amount) as total_revenue
from movies m
join shows sh on m.movie_id = sh.movie_id
join tickets tk on sh.show_id = tk.show_id
join payments p on tk.ticket_id = p.ticket_id
group by m.movie_id, m.title;
