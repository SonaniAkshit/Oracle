-- Show scheduled before movie release

create or replace trigger trg_show_before_release
before insert or update on shows
for each row
declare
    v_release_date date;
begin
    select release_date
    into v_release_date
    from movies
    where movie_id = :new.movie_id;

    if :new.show_time < v_release_date then
        dbms_output.put_line('show time is before the movie release date.');
    end if;
end;
/


-- More tickets booked than seats available

create or replace trigger trg_ticket_over_capacity
after insert on tickets
for each row
declare
    v_total_seats number;
    v_booked_seats number;
begin
    select s.total_seats
    into v_total_seats
    from shows sh
    join screens s on sh.screen_id = s.screen_id
    where sh.show_id = :new.show_id;

    select count(*)
    into v_booked_seats
    from tickets
    where show_id = :new.show_id
      and ticket_status = 'BOOKED';

    if v_booked_seats > v_total_seats then
        dbms_output.put_line('more tickets booked than seats in this screen.');
    end if;
end;
/

-- Seat double booking

create or replace trigger trg_seat_double_booking
after insert on tickets
for each row
declare
    v_count number;
begin
    select count(*)
    into v_count
    from tickets
    where show_id = :new.show_id
      and seat_id = :new.seat_id
      and ticket_status = 'BOOKED';

    if v_count > 1 then
        dbms_output.put_line('this seat is already booked for the show.');
    end if;
end;
/

-- Seat not belonging to the show’s screen

create or replace trigger trg_seat_wrong_screen
after insert on tickets
for each row
declare
    v_show_screen_id number;
    v_seat_screen_id number;
begin
    select screen_id
    into v_show_screen_id
    from shows
    where show_id = :new.show_id;

    select screen_id
    into v_seat_screen_id
    from seats
    where seat_id = :new.seat_id;

    if v_show_screen_id <> v_seat_screen_id then
        dbms_output.put_line('this seat is not in the same screen of the show.');
    end if;
end;
/


-- Payment amount mismatch

create or replace trigger trg_payment_mismatch
after insert on payments
for each row
declare
    v_price number;
begin
    select sh.price
    into v_price
    from tickets t
    join shows sh on t.show_id = sh.show_id
    where t.ticket_id = :new.ticket_id;

    if :new.amount <> v_price then
        dbms_output.put_line('payment amount not matching with ticket price.');
    end if;
end;
/

-- Unrealistic movie duration

create or replace trigger trg_movie_invalid_duration
after insert or update on movies
for each row
begin
    if :new.duration <= 0 then
        dbms_output.put_line('movie duration should be more than zero.');
    elsif :new.duration > 400 then
        dbms_output.put_line('movie duration is too long, please check again.');
    end if;
end;
/
