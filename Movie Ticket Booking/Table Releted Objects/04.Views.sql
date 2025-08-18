-- 1. Movie Revenue View
create or replace view vw_movie_revenue as
select m.movie_id,
       m.title,
       theater_report_pkg.get_movie_revenue(m.movie_id) as total_revenue
from movies m;

-- 2. Show Performance View
create or replace view vw_show_performance as
select sh.show_id,
       m.title as movie_title,
       sh.show_time,
       theater_report_pkg.get_show_tickets(sh.show_id) as tickets_sold,
       theater_report_pkg.get_show_revenue(sh.show_id) as revenue
from shows sh
join movies m on sh.movie_id = m.movie_id;

-- 3. Screen Revenue View

create or replace view vw_screen_revenue as
select s.screen_id,
       s.screen_name,
       theater_report_pkg.get_screen_revenue(s.screen_id) as total_revenue
from screens s;

-- 4. Theater Revenue View (Overall)

create or replace view vw_theater_revenue as
select theater_report_pkg.get_theater_revenue() as total_revenue
from dual;

-- 5. Top Movies by Revenue

create or replace view vw_top_movies as
select m.movie_id,
       m.title,
       theater_report_pkg.get_movie_revenue(m.movie_id) as revenue
from movies m
order by revenue desc;



-- Customer-Facing Views

-- 1. Upcoming Shows with Availability

create or replace view vw_upcoming_shows as
select sh.show_id,
       m.title as movie_title,
       sh.show_time,
       s.name as screen_name,
       customer_view_pkg.get_total_seats(sh.show_id) as total_seats,
       customer_view_pkg.get_booked_seats(sh.show_id) as booked_seats,
       customer_view_pkg.get_available_seats(sh.show_id) as available_seats,
       sh.price as ticket_price
from shows sh
join movies m on sh.movie_id = m.movie_id
join screens s on sh.screen_id = s.screen_id
where sh.show_time > systimestamp
order by sh.show_time;

-- 2. Movie-Wise Show Summary

create or replace view vw_movie_show_summary as
select m.movie_id,
       m.title,
       count(sh.show_id) as total_shows,
       sum(customer_view_pkg.get_available_seats(sh.show_id)) as total_available_seats
from movies m
left join shows sh on m.movie_id = sh.movie_id
where sh.show_time > systimestamp
group by m.movie_id, m.title;

-- 3. Screen-Wise Availability

create or replace view vw_screen_availability as
select s.screen_id,
       s.name as screen_name,
       sh.show_id,
       sh.show_time,
       customer_view_pkg.get_available_seats(sh.show_id) as available_seats
from screens s
join shows sh on s.screen_id = sh.screen_id
where sh.show_time > systimestamp
order by s.name, sh.show_time;

