-- CREATE ADMIN MANAGEMENT PACKAGE
create or replace package admin_mgmt_pkg as
    -- Procedure declarations for admin operations
    procedure add_movie(
        p_title        in varchar2,
        p_duration     in number,
        p_release_date in date
    );

    procedure add_screen(
        p_name        in varchar2,
        p_location    in varchar2,
        p_total_seats in number
    );

    procedure add_seat(
        p_screen_id   in number,
        p_seat_number in varchar2
    );

    procedure add_show(
        p_movie_id  in number,
        p_screen_id in number,
        p_show_time in timestamp,
        p_price     in number
    );
end admin_mgmt_pkg;
/
 
-- PACKAGE BODY
create or replace package body admin_mgmt_pkg as
    
    -- add new movie
    procedure add_movie(
        p_title        in varchar2,
        p_duration     in number,
        p_release_date in date
    ) is
    begin
        insert into movies (movie_id, title, duration, release_date)
        values (seq_movies.nextval, p_title, p_duration, p_release_date);

        dbms_output.put_line('Movie added successfully.');
    end add_movie;

    -- add screen
    procedure add_screen(
        p_name        in varchar2,
        p_location    in varchar2,
        p_total_seats in number
    ) is
    begin
        insert into screens (screen_id, name, location, total_seats)
        values (seq_screens.nextval, p_name, p_location, p_total_seats);

        dbms_output.put_line('Screen added successfully.');
    end add_screen;

    -- add seat
    procedure add_seat(
        p_screen_id   in number,
        p_seat_number in varchar2
    ) is
    begin
        insert into seats (seat_id, screen_id, seat_number)
        values (seq_seats.nextval, p_screen_id, p_seat_number);

        dbms_output.put_line('Seat added successfully.');
    end add_seat;

    -- add show
    procedure add_show(
        p_movie_id  in number,
        p_screen_id in number,
        p_show_time in timestamp,
        p_price     in number
    ) is
    begin
        insert into shows (show_id, movie_id, screen_id, show_time, price)
        values (seq_shows.nextval, p_movie_id, p_screen_id, p_show_time, p_price);

        dbms_output.put_line('Show scheduled successfully.');
    end add_show;

end admin_mgmt_pkg;
/
 
commit;


-- usage:
-- -- movie/screen/seat/show management
-- exec admin_mgmt_pkg.add_movie('&title', &duration, '&release_date');
-- exec admin_mgmt_pkg.add_screen('&name', '&location', &total_seats);
-- exec admin_mgmt_pkg.add_seat(&screen_id, '&seat_number');
-- exec admin_mgmt_pkg.add_show(&movie_id, &screen_id, timestamp'&show_time', &price);

-- -- demo_records
-- -- Add movie
-- exec admin_mgmt_pkg.add_movie('Inception', 148, date'2010-07-16');

-- -- Add screen
-- exec admin_mgmt_pkg.add_screen('Screen 1', 'PVR Ahmedabad', 200);

-- -- Add seat
-- exec admin_mgmt_pkg.add_seat(1, 'A1');

-- -- Add show
-- exec admin_mgmt_pkg.add_show(1, 1, timestamp'2025-08-20 19:00:00', 250);
