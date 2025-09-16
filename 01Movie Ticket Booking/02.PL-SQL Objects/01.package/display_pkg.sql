-- PACKAGE SPEC
create or replace package display_pkg as
    procedure show_customers;
    procedure show_movies;
    procedure show_screens;
    procedure show_shows;
    procedure show_seats;
    procedure show_tickets;
    procedure show_payments;
    procedure show_admins;
end display_pkg;
/

-- PACKAGE BODY
create or replace package body display_pkg as

    -- 1. Customers
    procedure show_customers is
        cursor c is select * from customers;
        v_row customers%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'ID: ' || v_row.customer_id || 
                ', Name: ' || v_row.name ||
                ', Email: ' || v_row.email ||
                ', Phone: ' || v_row.phone ||
                ', Registered: ' || to_char(v_row.registered_on,'YYYY-MM-DD')
            );
        end loop;
        close c;
    end show_customers;

    -- 2. Movies
    procedure show_movies is
        cursor c is select * from movies;
        v_row movies%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'ID: ' || v_row.movie_id ||
                ', Title: ' || v_row.title ||
                ', Duration: ' || v_row.duration ||
                ', Release: ' || to_char(v_row.release_date,'YYYY-MM-DD')
            );
        end loop;
        close c;
    end show_movies;

    -- 3. Screens
    procedure show_screens is
        cursor c is select * from screens;
        v_row screens%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'ID: ' || v_row.screen_id ||
                ', Name: ' || v_row.name ||
                ', Location: ' || v_row.location ||
                ', Total Seats: ' || v_row.total_seats
            );
        end loop;
        close c;
    end show_screens;

    -- 4. Shows
    procedure show_shows is
        cursor c is select * from shows;
        v_row shows%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'ShowID: ' || v_row.show_id ||
                ', MovieID: ' || v_row.movie_id ||
                ', ScreenID: ' || v_row.screen_id ||
                ', Time: ' || to_char(v_row.show_time,'YYYY-MM-DD HH24:MI') ||
                ', Price: ' || v_row.price
            );
        end loop;
        close c;
    end show_shows;

    -- 5. Seats
    procedure show_seats is
        cursor c is select * from seats;
        v_row seats%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'SeatID: ' || v_row.seat_id ||
                ', ScreenID: ' || v_row.screen_id ||
                ', Seat No: ' || v_row.seat_number
            );
        end loop;
        close c;
    end show_seats;

    -- 6. Tickets
    procedure show_tickets is
        cursor c is select * from tickets;
        v_row tickets%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'TicketID: ' || v_row.ticket_id ||
                ', CustomerID: ' || v_row.customer_id ||
                ', ShowID: ' || v_row.show_id ||
                ', SeatID: ' || v_row.seat_id ||
                ', Status: ' || v_row.ticket_status ||
                ', Booked: ' || to_char(v_row.booking_time,'YYYY-MM-DD HH24:MI')
            );
        end loop;
        close c;
    end show_tickets;

    -- 7. Payments
    procedure show_payments is
        cursor c is select * from payments;
        v_row payments%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'PaymentID: ' || v_row.payment_id ||
                ', TicketID: ' || v_row.ticket_id ||
                ', Amount: ' || v_row.amount ||
                ', Date: ' || to_char(v_row.payment_date,'YYYY-MM-DD')
            );
        end loop;
        close c;
    end show_payments;

    -- 8. Admins
    procedure show_admins is
        cursor c is select * from admins;
        v_row admins%rowtype;
    begin
        open c;
        loop
            fetch c into v_row;
            exit when c%notfound;
            dbms_output.put_line(
                'AdminID: ' || v_row.admin_id ||
                ', Username: ' || v_row.username ||
                ', Created: ' || to_char(v_row.created_on,'YYYY-MM-DD')
            );
        end loop;
        close c;
    end show_admins;

end display_pkg;
/

-- exec display_pkg.show_customers;
-- exec display_pkg.show_movies;
-- exec display_pkg.show_screens;
-- exec display_pkg.show_shows; 
-- exec display_pkg.show_seats;
-- exec display_pkg.show_tickets;
-- exec display_pkg.show_payments;
-- exec display_pkg.show_admins;