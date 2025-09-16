create or replace package theater_report_pkg as
    function movie_revenue(p_movie_id in number) return number;

    procedure movie_revenue(p_movie_id in number);
end theater_report_pkg;
/

create or replace package body theater_report_pkg as

    function movie_revenue(p_movie_id in number) return number is
        v_revenue number;
    begin
        select nvl(sum(p.amount),0)
        into v_revenue
        from payments p
        join tickets t on p.ticket_id = t.ticket_id
        join shows sh on t.show_id = sh.show_id
        where sh.movie_id = p_movie_id;

        return v_revenue;
    exception
        when no_data_found then
            return 0;
    end movie_revenue;


    procedure movie_revenue(p_movie_id in number) is
        v_title   movies.title%type;
        v_revenue number;
    begin
        select title into v_title
        from movies
        where movie_id = p_movie_id;

        v_revenue := movie_revenue(p_movie_id);

        dbms_output.put_line('Movie ID   : ' || p_movie_id);
        dbms_output.put_line('Movie Name : ' || v_title);
        dbms_output.put_line('Revenue    : ' || v_revenue);
    exception
        when no_data_found then
            dbms_output.put_line('Movie not found with ID ' || p_movie_id);
    end movie_revenue;

end theater_report_pkg;
/

-- exec theater_report_pkg.movie_revenue(3);