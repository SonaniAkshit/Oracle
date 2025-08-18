-- 1.MOVIES
-- movie duration error
create or replace trigger trg_movie_invalid_duration
before insert or update on movies
for each row
begin
    if :new.duration <= 0 then
        raise_application_error(-20006, 'movie duration should be more than zero');
    elsif :new.duration > 400 then
        raise_application_error(-20007, 'movie duration is too long, please check again');
    end if;
end;
/

-- duplicate movie error
create or replace trigger trg_duplicate_movie_date
before insert on movies
for each row
declare
    v_count number;
begin
    select count(*)
    into v_count
    from movies
    where title = :new.title
      and release_date = :new.release_date;

    if v_count > 0 then
        raise_application_error(-20008, 'this movie is already released on the same date');
    end if;
end;
/


-- 2.SCREENS
-- seat over capacity error
create or replace trigger trg_seat_over_capacity
before insert on seats
for each row
declare
    v_total_seats number;
    v_existing_seats number;
begin
    select total_seats
    into v_total_seats
    from screens
    where screen_id = :new.screen_id;

    select count(*)
    into v_existing_seats
    from seats
    where screen_id = :new.screen_id;

    if v_existing_seats + 1 > v_total_seats then
        raise_application_error(-20009, 'cannot add more seats: screen capacity exceeded');
    end if;
end;
/

-- duplicate seat error
create or replace trigger trg_duplicate_seat
before insert or update on seats
for each row
declare
    v_count number;
begin
    select count(*)
    into v_count
    from seats
    where screen_id = :new.screen_id
      and seat_number = :new.seat_number
      and seat_id <> nvl(:new.seat_id, -1);

    if v_count > 0 then
        raise_application_error(-20010, 'seat number already exists in this screen');
    end if;
end;
/

-- 3.SHOWS
-- show scheduled before movie release error
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
        raise_application_error(-20001, 'show time is before the movie release date');
    end if;
end;
/

-- dublicate show time error
create or replace trigger trg_duplicate_show
before insert on shows
for each row
declare
    v_count number;
begin
    select count(*)
    into v_count
    from shows
    where movie_id  = :new.movie_id
      and screen_id = :new.screen_id
      and show_time = :new.show_time;

    if v_count > 0 then
        raise_application_error(-20011, 'this show already exists (same movie, screen, and time)');
    end if;
end;
/

-- id errors
create or replace trigger trg_show_invalid_fk
before insert or update on shows
for each row
declare
    v_count number;
begin
    -- check movie_id exists
    select count(*) into v_count
    from movies
    where movie_id = :new.movie_id;

    if v_count = 0 then
        raise_application_error(-20012, 'Invalid movie_id: movie does not exist');
    end if;

    -- check screen_id exists
    select count(*) into v_count
    from screens
    where screen_id = :new.screen_id;

    if v_count = 0 then
        raise_application_error(-20013, 'Invalid screen_id: screen does not exist');
    end if;
end;
/


-- 4.TICKETS
-- more tickets booked than seats available
create or replace trigger trg_ticket_over_capacity
before insert on tickets
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

    if v_booked_seats + 1 > v_total_seats then
        raise_application_error(-20002, 'more tickets booked than seats available');
    end if;
end;
/

-- seat double booking
create or replace trigger trg_seat_double_booking
before insert on tickets
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

    if v_count > 0 then
        raise_application_error(-20003, 'this seat is already booked for the show');
    end if;
end;
/

-- seat not belonging to the show’s screen
create or replace trigger trg_seat_wrong_screen
before insert on tickets
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
        raise_application_error(-20004, 'this seat is not in the same screen as the show');
    end if;
end;
/

-- id error
create or replace trigger trg_ticket_invalid_fk
before insert or update on tickets
for each row
declare
    v_count number;
begin
    -- check show_id exists
    select count(*) into v_count
    from shows
    where show_id = :new.show_id;

    if v_count = 0 then
        raise_application_error(-20014, 'Invalid show_id: show does not exist');
    end if;

    -- check seat_id exists
    select count(*) into v_count
    from seats
    where seat_id = :new.seat_id;

    if v_count = 0 then
        raise_application_error(-20015, 'Invalid seat_id: seat does not exist');
    end if;
end;
/

-- 5.SEAT
create or replace trigger trg_seat_invalid_fk
before insert or update on seats
for each row
declare
    v_count number;
begin
    select count(*) into v_count
    from screens
    where screen_id = :new.screen_id;

    if v_count = 0 then
        raise_application_error(-20016, 'Invalid screen_id: screen does not exist');
    end if;
end;
/

--6.PAYMENTS
-- payment amount mismatch
create or replace trigger trg_payment_mismatch
before insert on payments
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
        raise_application_error(-20005, 'payment amount does not match ticket price');
    end if;
end;
/

create or replace trigger trg_payment_invalid_fk
before insert or update on payments
for each row
declare
    v_count number;
begin
    select count(*) into v_count
    from tickets
    where ticket_id = :new.ticket_id;

    if v_count = 0 then
        raise_application_error(-20017, 'Invalid ticket_id: ticket does not exist');
    end if;
end;
/
