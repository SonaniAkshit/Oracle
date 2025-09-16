create or replace package theater_report_pkg as
    -- 1. total revenue of a movie
    function get_movie_revenue(p_movie_id in number) return number;

    -- 2. total revenue of a show
    function get_show_revenue(p_show_id in number) return number;

    -- 3. total tickets sold for a show
    function get_show_tickets(p_show_id in number) return number;

    -- 4. total revenue of a screen
    function get_screen_revenue(p_screen_id in number) return number;

    -- 5. total revenue of the theater (all movies)
    function get_theater_revenue return number;
end theater_report_pkg;
/

create or replace package body theater_report_pkg as

    -- 1. total revenue of a movie
    function get_movie_revenue(p_movie_id in number) return number is
        v_revenue number;
    begin
        select nvl(sum(p.amount),0)
        into v_revenue
        from payments p
        join tickets t on p.ticket_id = t.ticket_id
        join shows sh on t.show_id = sh.show_id
        where sh.movie_id = p_movie_id;

        return v_revenue;
    end;

    -- 2. total revenue of a show
    function get_show_revenue(p_show_id in number) return number is
        v_revenue number;
    begin
        select nvl(sum(p.amount),0)
        into v_revenue
        from payments p
        join tickets t on p.ticket_id = t.ticket_id
        where t.show_id = p_show_id;

        return v_revenue;
    end;

    -- 3. total tickets sold for a show
    function get_show_tickets(p_show_id in number) return number is
        v_count number;
    begin
        select count(*)
        into v_count
        from tickets
        where show_id = p_show_id
          and ticket_status = 'BOOKED';

        return v_count;
    end;

    -- 4. total revenue of a screen
    function get_screen_revenue(p_screen_id in number) return number is
        v_revenue number;
    begin
        select nvl(sum(p.amount),0)
        into v_revenue
        from payments p
        join tickets t on p.ticket_id = t.ticket_id
        join shows sh on t.show_id = sh.show_id
        where sh.screen_id = p_screen_id;

        return v_revenue;
    end;

    -- 5. total revenue of the theater (all movies)
    function get_theater_revenue return number is
        v_revenue number;
    begin
        select nvl(sum(amount),0)
        into v_revenue
        from payments;

        return v_revenue;
    end;

end theater_report_pkg;
/
