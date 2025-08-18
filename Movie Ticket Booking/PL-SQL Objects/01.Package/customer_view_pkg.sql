create or replace package customer_view_pkg as
    -- 1. get total seats of a show
    function get_total_seats(p_show_id in number) return number;

    -- 2. get booked seats of a show
    function get_booked_seats(p_show_id in number) return number;

    -- 3. get available seats of a show
    function get_available_seats(p_show_id in number) return number;
end customer_view_pkg;
/

create or replace package body customer_view_pkg as

    -- 1. total seats in the screen of a show
    function get_total_seats(p_show_id in number) return number is
        v_total number;
    begin
        select s.total_seats
        into v_total
        from shows sh
        join screens s on sh.screen_id = s.screen_id
        where sh.show_id = p_show_id;

        return v_total;
    end;

    -- 2. booked seats of a show
    function get_booked_seats(p_show_id in number) return number is
        v_booked number;
    begin
        select count(*)
        into v_booked
        from tickets
        where show_id = p_show_id
          and ticket_status = 'BOOKED';

        return v_booked;
    end;

    -- 3. available seats of a show
    function get_available_seats(p_show_id in number) return number is
        v_available number;
    begin
        v_available := get_total_seats(p_show_id) - get_booked_seats(p_show_id);
        return v_available;
    end;

end customer_view_pkg;
/

